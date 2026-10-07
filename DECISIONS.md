# DECISIONS — принятые решения

Исходное ТЗ (`The PVZ.md`) обрывалось на разделе 4 (таблица строк, ключ hud). Разделы 5–21 отсутствовали. Ниже — чем руководствовались.

## 1. Недостающие разделы ТЗ
- ТЗ задавало: стек (Swift5, SceneKit, UIKit кодом, UIScene, AVFoundation-пулы, CoreHaptics, CoreImage-QR, CoreText), файловая структура, workflow и project.yml «как есть», палитру, шрифты, тексты, константу BRAND_SIGN_TEXT=Shmaildberries, оффлайн, один внешний URL https://t.me/esyle.
- Не задавало: точные механики ночи, баланс, поведение аномалий, сканер, ГБР, курьер, SWAT, джампскейр, HUD-детали. Выбрано самое простое и надёжное (приоритет: зелёная сборка).

## 2. Геймдизайн (додумано)
- 5 ночей, клиенты 4/6/7/9/10, длительность 150/170/190/210/240 сек, лимит жалоб 3, шанс аномалии 0.25–0.45. Всё в Tuning.swift.
- Цикл клиента: идёт 8 сек → стоит у стола → игрок сканирует/решает → уходит 3 сек. Сканер всегда говорит правду (иначе игра непроходима без гайда).
- Выдать аномалии = мгновенный проигрыш с джампскейром (body-horror). Отказ/ГБР против аномалии = успех. Отказ/ГБР против человека = жалоба.
- Закрыть смену побеждает только если обслужены все клиенты, иначе подсказка. Таймер=0 тоже победа (если не провалено).
- Курьер — ночь 2, 30 сек, без геймплея, только атмосфера. ГБР — 2 человечка, приходят, уходят через 2 сек. Эмбиент — мигание света + шум каждые 18 сек.

## 3. Технические допущения
- SceneKit deprecated-предупреждения игнорируются, warnings-as-errors выключены (как в ТЗ).
- Звук: сначала ищет .wav в Resources/Audio, иначе Synth-генерирует тон/шум в AVAudioPlayer. AVAudioEngine не используется.
- Шрифты: регистрация через CTFontManagerRegisterFontsForURL, scope .process, только .otf/.ttf.
- Иконка: Scripts/make_icon.swift только CoreGraphics+ImageIO+CoreText+Foundation, без AppKit. При сбое пишет warning и выходит 0 (плюс continue-on-error в workflow).
- Раннер macos-26, XcodeGen, без подписи, smoke-проверки не удалены.
- Swift консервативный: явные типы, короткие выражения, без force-unwrap/try!, только iOS15 API, #available для CoreHaptics.
- HumanAnimator использует SCNAction, без скелетов/моделей. AnomalyFeatures — 5 видов body-horror процедурой (длинные руки, лишние глаза, бледность, наклон головы, чёрный рот).
- Тесты только чистая логика (SeededRNG, Tuning, NightScheduler, DeskStateMachine, GameClock), без SceneKit-рендера, чтобы проходили на симуляторе.

## 4. Отклонения от ТЗ
- Support/Info.plist не коммитится (по .gitignore из ТЗ), генерируется XcodeGen из project.yml. Добавлен Support/.gitkeep чтобы папка существовала.
- Тексты для новых HUD-подсказок («Сканер: АНОМАЛИЯ!», «Все обслужены...») — русские, в стиле ТЗ, но в исходной таблице их не было.
- Кнопка «Выход» делает exit(0) после confirm-алерта (iOS обычно не выходит, но заказчик просил пункт меню).

## 5. Точное сравнение с Telegram-iOS (почему не ставилось через GBox)
- Взяли за эталон рабочий кейс: IPA Telegram (форк Telegram-ND, Bazel, `build-system/fake-codesigning`), который у заказчика ставится тем же GBox и тем же сертификатом.
- Info.plist сверили попунктно: у Telegram есть legacy-ключи `LSRequiresIPhoneOS=true` и `CFBundleSignature='????'` — добавили оба в `project.yml` (инертны, installd их не требует, но дифф теперь нулевой). `UIRequiredDeviceCapabilities` оставили `arm64` (у Telegram `armv7`; оба валидны на iPhone 14, наш точнее под arm64-only бинарник).
- Главная разница — не код, а структура подписи: Telegram собирает `ImportCertificates.py` (SelfSigned.p12 в temp-keychain) + CMS-подписанный `embedded.mobileprovision` (AppIDName, ApplicationIdentifierPrefix, DeveloperCertificates, Entitlements, TeamIdentifier...) и шьёт всё `codesign` с идентити. Наш бинарник был полностью голым (нет даже `LC_CODE_SIGNATURE`, нет provision) — такой пакет подписанты на устройстве на новых iOS молча отваливают с «повторите позже».
- Повторили формулу 1:1 в `Scripts/fake_sign.sh`: генерация ключа/серта (`Apple Distribution: ThePVZ FakeSign (THEPVZ2024)`, OU=SELFSIGNED), provision через `openssl cms -sign`, temp-keychain, `codesign --sign` с минимальными entitlements (только application-identifier + keychain-access-groups + get-task-allow=false — без push/groups, чтобы вставало и на бесплатный сертификат; у Telegram есть push-etime, им нужен dev-аккаунт). Скрипт никогда не роняет сборку: при сбое откат на ad-hoc.
- Заодно: `CFBundleVersion` теперь равен номеру сборки (как BUILD_NUMBER у Telegram) — повторная установка той же версии иногда даёт vague-ошибку installd; мусор (`.gitkeep`, `OFL.txt`) из бандла вычищается; `pvz_screen.png` переименован в точное имя из ТЗ (был `thepvz_screen.png` — на iOS регистр важен, текстура не находилась).
- Smoke-проверки усилены: `codesign -dv`, дамп entitlements, обязательные `embedded.mobileprovision` и `_CodeSignature`, плюс python-проверка слота 5 (entitlements) в бинарнике — как у Telegram `[0,2,5,7,65536]`.
- Нюансы, найденные по логам: `openssl cms/smimes -sign` по умолчанию даёт detached-подпись — нужен `-nodetach`; свежий PKCS12 надо экспортировать с `-legacy`, иначе `security import` падает с MAC-ошибкой; самоподписной identity не хватало `--deep` при `codesign` (без него валился subcomponent Assets.car); EKU серта зеркалит Telegram (email+codeSigning+any). Фолбэк-цепочка: identity -> ad-hoc+ent -> seal+ldid, после каждой проверка слота 5.
