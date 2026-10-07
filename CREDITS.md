# CREDITS

- Код, сцена, звуки (синтезированные), иконка — оригинальные, созданы для проекта ThePVZ. Лицензия: все права у заказчика (если не указано иное).
- Шрифт Gotham Pro — коммерческий, в репозиторий НЕ включён. Может быть добавлен только заказчиком при наличии лицензии. Фолбэки: Montserrat (OFL), Avenir Next (системный Apple), системный шрифт.
- Шрифт `ThePVZ/Resources/Fonts/Montserrat.ttf` — Montserrat Project Authors (Julieta Ulanovsky, Sol Matas, Juan Pablo del Peral, Jacques Le Bailly), лицензия SIL Open Font License 1.1. Источник: https://github.com/google/fonts (ofl/montserrat). Файл `OFL.txt` рядом. Можно использовать, встраивать и менять под OFL.
- Аудио `ThePVZ/Resources/Audio/*.wav` (click, scan, success, fail, alarm, ambient, jumpscare, gbr, courier) — сгенерированы скриптом для проекта (sine/noise, 22050 Гц, mono 16-bit), CC0 / все права у заказчика. Внешних сэмплов из интернета нет, чтобы не тащить чужие лицензии и не раздувать IPA.
- Модели людей/коробок/стеллажей/примерочной — процедурные SceneKit (`HumanFactory`, `PropsBuilder`, `RoomBuilder`). Внешних .scn/.dae/.usdz нет: случайные модели из интернета ломают сборку (вес, риг, треугольники >250к, несовместимые лицензии). Если нужны внешние — клади CC0 low-poly с указанием автора в этот файл.
- Скриншот `ThePVZ/Resources/Textures/pvz_screen.png` — предоставляет заказчик (скриншот сайта ПВЗ). Без него используется процедурная заглушка (CoreGraphics). Права на скриншот — у заказчика.
- Внешних пакетов (SPM/CocoaPods) — нет. Игра полностью офлайн.
- Единственный внешний переход: https://t.me/esyle (кнопка credit).
- Apple frameworks: SceneKit, UIKit, AVFoundation, CoreHaptics, CoreImage, CoreText — © Apple.
