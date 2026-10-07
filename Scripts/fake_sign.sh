#!/bin/bash
# FakeSign в стиле Telegram (build-system/fake-codesigning):
# самоподписной сертификат + CMS-подписанный embedded.mobileprovision + codesign.
# Устройству это не предъявляется (GBox заменяет подпись и профиль своим
# личным сертификатом), но подписанту на устройстве нужен полностью
# сформированный бандл — как у Telegram. Голый бинарник без LC_CODE_SIGNATURE
# и без embedded.mobileprovision GBox на новых iOS молча отваливает.
# Скрипт никогда не роняет сборку: при проблеме откат на ad-hoc подпись.
# Важно: только абсолютные пути, никакого cd (runner вызывает с относительным .app).
set -uo pipefail

APP_REL="${1:-}"
BUILD_NUM="${2:-1}"
BUNDLE_ID="${3:-com.esyle.thepvz}"
TEAM="THEPVZ2024"
IDN="Apple Distribution: ThePVZ FakeSign ($TEAM)"
WORK=/tmp/thepvz-fakesign

warn() { echo "::warning::$1"; }

# Абсолютный путь СРАЗУ, до любых операций.
case "$APP_REL" in
  /*) APP_ABS="$APP_REL" ;;
  *) APP_ABS="$(pwd)/$APP_REL" ;;
esac

if [ -z "$APP_REL" ] || [ ! -d "$APP_ABS" ]; then
  warn "fake_sign: .app не найден ($APP_REL), пропускаю"
  exit 0
fi

APP_NAME="$(basename "$APP_ABS" .app)"
BIN="$APP_ABS/$APP_NAME"
if [ ! -f "$BIN" ]; then
  warn "fake_sign: бинарник не найден ($BIN), пропускаю"
  exit 0
fi

rm -rf "$WORK" && mkdir -p "$WORK"

# Версия каждой сборки растёт (как BUILD_NUMBER у Telegram):
# повторная установка того же CFBundleVersion иногда даёт vague-ошибку installd.
if command -v plutil >/dev/null 2>&1; then
  plutil -replace CFBundleVersion -string "$BUILD_NUM" "$APP_ABS/Info.plist" 2>/dev/null || warn "fake_sign: не смог проставить CFBundleVersion"
fi
chmod +x "$BIN" 2>/dev/null || true
find "$APP_ABS" -name '.gitkeep' -delete 2>/dev/null || true
rm -f "$APP_ABS/Resources/Fonts/OFL.txt" 2>/dev/null || true

# 1. Ключ + самоподписной серт (тот же трюк с префиксом, что у Telegram).
# Важно: EKU codeSigning, иначе codesign не видит identity ("no identity found").
if ! openssl req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes \
  -keyout "$WORK/fake.key" -out "$WORK/fake.cer" \
  -subj "/CN=$IDN/OU=SELFSIGNED/C=US" \
  -addext "keyUsage=critical,digitalSignature" \
  -addext "extendedKeyUsage=codeSigning" >/dev/null 2>&1; then
  warn "fake_sign: openssl req не удался, откат на ad-hoc"
  codesign --force --sign - --entitlements "$WORK/ent.plist" --timestamp=none "$APP_ABS" 2>/dev/null || codesign --force --sign - --deep --timestamp=none "$APP_ABS" || true
  exit 0
fi
openssl x509 -in "$WORK/fake.cer" -outform DER -out "$WORK/fake.der" 2>/dev/null || true
openssl pkcs12 -export -inkey "$WORK/fake.key" -in "$WORK/fake.cer" -out "$WORK/fake.p12" \
  -passout pass:thepvz -name "$IDN" 2>/dev/null || true

# 2. embedded.mobileprovision (XML plist -> CMS SignedData, как у Telegram).
if ! python3 - "$BUNDLE_ID" "$TEAM" "$WORK" <<'PYEOF'
import plistlib, sys, uuid, datetime
bundle_id = sys.argv[1]
team = sys.argv[2]
work = sys.argv[3]
cert_der = open(work + '/fake.der', 'rb').read()
prov = {
    'AppIDName': 'ThePVZ',
    'ApplicationIdentifierPrefix': [team],
    'CreationDate': datetime.datetime.now(),
    'ExpirationDate': datetime.datetime.now() + datetime.timedelta(days=365),
    'Platform': ['iOS'],
    'IsXcodeManaged': False,
    'DeveloperCertificates': [cert_der],
    'Entitlements': {
        'application-identifier': team + '.' + bundle_id,
        'keychain-access-groups': [team + '.' + bundle_id],
        'get-task-allow': False,
    },
    'Name': 'ThePVZ FakeSign',
    'TeamIdentifier': [team],
    'TeamName': 'ThePVZ FakeSign',
    'TimeToLive': 365,
    'UUID': str(uuid.uuid4()).upper(),
    'Version': 1,
}
with open(work + '/prov.plist', 'wb') as f:
    plistlib.dump(prov, f, fmt=plistlib.FMT_XML)
with open(work + '/ent.plist', 'wb') as f:
    plistlib.dump(prov['Entitlements'], f, fmt=plistlib.FMT_XML)
print('provision+entitlements written')
PYEOF
then
  warn "fake_sign: не собрал provision, откат на ad-hoc"
  if [ -f "$WORK/ent.plist" ]; then
    codesign --force --sign - --entitlements "$WORK/ent.plist" --timestamp=none "$APP_ABS" 2>/dev/null || codesign --force --sign - --deep --timestamp=none "$APP_ABS" || true
  else
    codesign --force --sign - --deep --timestamp=none "$APP_ABS" || true
  fi
  exit 0
fi

sign_provision() {
  # $1 = backend (cms|smime). Возвращает 0 если plist реально внутри.
  # -nodetach = opaque/attached подпись (без него получается detached без контента).
  if [ "$1" = "smime" ]; then
    openssl smime -sign -binary -nodetach -in "$WORK/prov.plist" -signer "$WORK/fake.cer" -inkey "$WORK/fake.key" \
      -outform DER -out "$WORK/embedded.mobileprovision" 2>/dev/null || return 1
  else
    openssl cms -sign -binary -nodetach -in "$WORK/prov.plist" -signer "$WORK/fake.cer" -inkey "$WORK/fake.key" \
      -outform DER -out "$WORK/embedded.mobileprovision" 2>/dev/null || return 1
  fi
  grep -a -q "$BUNDLE_ID" "$WORK/embedded.mobileprovision" 2>/dev/null
}

if sign_provision cms; then
  echo "fake_sign: provision attached (cms)"
elif sign_provision smime; then
  echo "fake_sign: provision attached (smime fallback)"
else
  warn "fake_sign: provision без контента, откат на ad-hoc"
  if [ -f "$WORK/ent.plist" ]; then
    codesign --force --sign - --entitlements "$WORK/ent.plist" --timestamp=none "$APP_ABS" 2>/dev/null || codesign --force --sign - --deep --timestamp=none "$APP_ABS" || true
  else
    codesign --force --sign - --deep --timestamp=none "$APP_ABS" || true
  fi
  exit 0
fi
cp "$WORK/embedded.mobileprovision" "$APP_ABS/embedded.mobileprovision"

# 3. Импорт в temp-keychain (как ImportCertificates.py у Telegram).
KC="thepvz-fake.keychain"
security delete-keychain "$KC" >/dev/null 2>&1 || true
if security create-keychain -p thepvz "$KC" >/dev/null 2>&1; then
  OLDKC=$(security list-keychains -d user 2>/dev/null | tr -d '"' | xargs)
  # shellcheck disable=SC2086
  security list-keychains -d user -s "$KC" $OLDKC >/dev/null 2>&1 || true
  security set-keychain-settings -lut 3600 "$KC" >/dev/null 2>&1 || true
  security unlock-keychain -p thepvz "$KC" >/dev/null 2>&1 || true
  ls -la "$WORK" | head -n 12
  security import "$WORK/fake.p12" -k "$KC" -P thepvz -T /usr/bin/codesign -T /usr/bin/security 2>&1 | head -n 5 || true
  security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k thepvz "$KC" >/dev/null 2>&1 || true
  echo "fake_sign: identities в keychain:"
  security find-identity -v -p codesigning "$KC" 2>&1 | head -n 5 || true
else
  warn "fake_sign: keychain не создался, пробую login-keychain"
fi

# 4. Подпись.
if codesign --force --sign "$IDN" --entitlements "$WORK/ent.plist" --timestamp=none "$APP_ABS" 2>"$WORK/sign-err.log"; then
  echo "fake_sign: подписано $IDN"
  codesign -dv "$APP_ABS" 2>&1 | head -n 5 || true
else
  warn "fake_sign: codesign identity не удался, откат на ad-hoc ($(head -c 300 "$WORK/sign-err.log"))"
  codesign --force --sign - --entitlements "$WORK/ent.plist" --timestamp=none "$APP_ABS" 2>/dev/null || codesign --force --sign - --deep --timestamp=none "$APP_ABS" || true
fi
exit 0
