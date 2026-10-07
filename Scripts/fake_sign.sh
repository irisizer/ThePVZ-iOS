#!/bin/bash
# FakeSign в стиле Telegram (build-system/fake-codesigning):
# самоподписной сертификат + CMS-подписанный embedded.mobileprovision + codesign.
# Устройству это не предъявляется (GBox заменяет подпись и профиль своим
# личным сертификатом), но подписанту на устройстве нужен полностью
# сформированный бандл — как у Telegram. Голый бинарник без LC_CODE_SIGNATURE
# и без embedded.mobileprovision GBox на новых iOS молча отваливает.
# Скрипт никогда не роняет сборку: при проблеме откат на ad-hoc подпись.
set -uo pipefail

APP_PATH="${1:-}"
BUILD_NUM="${2:-1}"
BUNDLE_ID="${3:-com.esyle.thepvz}"
TEAM="THEPVZ2024"
IDN="Apple Distribution: ThePVZ FakeSign ($TEAM)"
WORK=/tmp/thepvz-fakesign

warn() { echo "::warning::$1"; }

if [ -z "$APP_PATH" ] || [ ! -d "$APP_PATH" ]; then
  warn "fake_sign: .app не найден ($APP_PATH), пропускаю"
  exit 0
fi

APP_NAME="$(basename "$APP_PATH" .app)"
BIN="$APP_PATH/$APP_NAME"
if [ ! -f "$BIN" ]; then
  warn "fake_sign: бинарник не найден ($BIN), пропускаю"
  exit 0
fi

rm -rf "$WORK" && mkdir -p "$WORK"
cd "$WORK" || exit 0

# Версия каждой сборки растёт (как BUILD_NUMBER у Telegram):
# повторная установка того же CFBundleVersion иногда даёт vague-ошибку installd.
if command -v plutil >/dev/null 2>&1; then
  plutil -replace CFBundleVersion -string "$BUILD_NUM" "$APP_PATH/Info.plist" 2>/dev/null || warn "fake_sign: не смог проставить CFBundleVersion"
fi
chmod +x "$BIN" 2>/dev/null || true
find "$APP_PATH" -name '.gitkeep' -delete 2>/dev/null || true
rm -f "$APP_PATH/Resources/Fonts/OFL.txt" 2>/dev/null || true

# 1. Ключ + самоподписной серт (тот же трюк с префиксом, что у Telegram).
if ! openssl req -x509 -newkey rsa:2048 -sha256 -days 3650 -nodes \
  -keyout fake.key -out fake.cer \
  -subj "/CN=$IDN/OU=SELFSIGNED/C=US" >/dev/null 2>&1; then
  warn "fake_sign: openssl req не удался, откат на ad-hoc"
  codesign --force --sign - --deep --timestamp=none "$APP_PATH" || true
  exit 0
fi
openssl x509 -in fake.cer -outform DER -out fake.der 2>/dev/null || true
openssl pkcs12 -export -inkey fake.key -in fake.cer -out fake.p12 \
  -passout pass:thepvz -name "$IDN" 2>/dev/null || true

# 2. embedded.mobileprovision (XML plist -> CMS SignedData, как у Telegram).
if ! python3 - "$BUNDLE_ID" "$TEAM" <<'PYEOF'
import plistlib, sys, uuid, datetime
bundle_id = sys.argv[1]
team = sys.argv[2]
cert_der = open('/tmp/thepvz-fakesign/fake.der', 'rb').read()
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
with open('/tmp/thepvz-fakesign/prov.plist', 'wb') as f:
    plistlib.dump(prov, f, fmt=plistlib.FMT_XML)
with open('/tmp/thepvz-fakesign/ent.plist', 'wb') as f:
    plistlib.dump(prov['Entitlements'], f, fmt=plistlib.FMT_XML)
print('provision+entitlements written')
PYEOF
then
  warn "fake_sign: не собрал provision, откат на ad-hoc"
  codesign --force --sign - --deep --timestamp=none "$APP_PATH" || true
  exit 0
fi

if ! openssl cms -sign -binary -in prov.plist -signer fake.cer -inkey fake.key \
  -outform DER -out embedded.mobileprovision 2>/dev/null; then
  warn "fake_sign: cms-sign не удался, откат на ad-hoc"
  codesign --force --sign - --deep --timestamp=none "$APP_PATH" || true
  exit 0
fi
cp embedded.mobileprovision "$APP_PATH/embedded.mobileprovision"

# 3. Импорт в temp-keychain (как ImportCertificates.py у Telegram).
KC="thepvz-fake.keychain"
security delete-keychain "$KC" >/dev/null 2>&1 || true
if security create-keychain -p thepvz "$KC" >/dev/null 2>&1; then
  OLDKC=$(security list-keychains -d user | tr -d ' "')
  security list-keychains -d user -s "$KC" $OLDKC >/dev/null 2>&1 || true
  security set-keychain-settings "$KC" >/dev/null 2>&1 || true
  security unlock-keychain -p thepvz "$KC" >/dev/null 2>&1 || true
  security import fake.p12 -k "$KC" -P thepvz -T /usr/bin/codesign -T /usr/bin/security >/dev/null 2>&1 || true
  security set-key-partition-list -S apple-tool:,apple:,codesign: -s -k thepvz "$KC" >/dev/null 2>&1 || true
else
  warn "fake_sign: keychain не создался, пробую login-keychain"
fi

# 4. Подпись.
if codesign --force --sign "$IDN" --entitlements ent.plist --timestamp=none "$APP_PATH" 2>/tmp/fake-sign-err.log; then
  echo "fake_sign: подписано $IDN"
  codesign -dv "$APP_PATH" 2>&1 | head -n 5 || true
else
  warn "fake_sign: codesign identity не удался ($(head -c 300 /tmp/fake-sign-err.log)), откат на ad-hoc"
  codesign --force --sign - --deep --timestamp=none "$APP_PATH" || true
fi
exit 0
