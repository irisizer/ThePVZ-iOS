import Foundation

public enum Strings {
    public static let play: String = "Играть"
    public static let settings: String = "Настройки"
    public static let exitGame: String = "Выход"
    public static let credit: String = "by esyle  •  t.me/esyle"
    public static let exitTitle: String = "Выйти из игры?"
    public static let stay: String = "Остаться"
    public static let exitConfirm: String = "Выйти"
    public static let tabSound: String = "Звук"
    public static let tabGraphics: String = "Графика"
    public static let back: String = "Назад"
    public static let reset: String = "Сбросить"
    public static let pauseWarning: String = "Прогресс текущей ночи будет потерян"
    public static let continueGame: String = "Продолжить"
    public static let toMenu: String = "В главное меню"
    public static let retryNight: String = "Повторить ночь"
    public static let nextNight: String = "Следующая ночь"
    public static let overTitle: String = "СМЕНА ПРОВАЛЕНА"
    public static let winTitle: String = "СМЕНА ЗАКРЫТА"
    public static let finalTitle: String = "ВЫ ПЕРЕЖИЛИ ВСЕ 5 НОЧЕЙ"
    public static let failAnomaly: String = "Аномалия добралась до вас."
    public static let failComplaints: String = "Слишком много жалоб. Вы уволены."
    public static let hudComplaints: String = "ЖАЛОБЫ"
    public static let hudGBR: String = "ГБР в пути"
    public static let hudCloseShift: String = "Закрыть смену"
    public static let hudWaybill: String = "НАКЛАДНАЯ"
    public static let actIssue: String = "Выдать"
    public static let actReject: String = "Отказ"
    public static let actGBR: String = "ГБР"
    public static let actScan: String = "Сканировать"
    public static let pauseTitle: String = "Пауза"
    public static let settingsTitle: String = "Настройки"

    public static func night(_ n: Int) -> String {
        return "НОЧЬ \(n)"
    }
}
