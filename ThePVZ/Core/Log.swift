import Foundation

public enum Log {
    public static func info(_ s: String) {
        NSLog("[ThePVZ][INFO] %@", s)
    }

    public static func warn(_ s: String) {
        NSLog("[ThePVZ][WARN] %@", s)
    }

    public static func error(_ s: String) {
        NSLog("[ThePVZ][ERROR] %@", s)
    }
}
