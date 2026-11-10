import SwiftUI

// MARK: - Color hex

extension Color {
    init(hex: UInt32, opacity: Double = 1.0) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255.0,
            green: Double((hex >> 8) & 0xFF) / 255.0,
            blue: Double(hex & 0xFF) / 255.0,
            opacity: opacity
        )
    }
}

// MARK: - Theme (iOS system palette used by the prototype)

enum Theme {
    static let blue = Color(hex: 0x007AFF)
    static let purple = Color(hex: 0x5856D6)
    static let green = Color(hex: 0x34C759)
    static let red = Color(hex: 0xFF3B30)
    static let orange = Color(hex: 0xFF9500)

    static let background = Color(hex: 0xF2F2F7)
    static let gray = Color(hex: 0x8E8E93)
    static let lightGray = Color(hex: 0xAEAEB2)
    static let chevron = Color(hex: 0xC7C7CC)
    static let fieldBorder = Color(hex: 0xE5E5EA)
    static let secondaryLabel = Color(hex: 0x3C3C43)
    static let editFill = Color(hex: 0xF0F7FF)

    static var gradient: LinearGradient {
        LinearGradient(
            colors: [blue, purple],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var softGradient: LinearGradient {
        LinearGradient(
            colors: [Color(hex: 0xE8F0FF), Color(hex: 0xF0E8FF)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Formatting

private let pesoFormatter: NumberFormatter = {
    let f = NumberFormatter()
    f.numberStyle = .decimal
    f.usesGroupingSeparator = true
    f.groupingSeparator = ","
    f.maximumFractionDigits = 0
    return f
}()

func peso(_ n: Int) -> String {
    "₱" + (pesoFormatter.string(from: NSNumber(value: n)) ?? "\(n)")
}

private let shortDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en_US")
    f.dateFormat = "MMM d, yyyy"
    return f
}()

private let longDateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.locale = Locale(identifier: "en_US")
    f.dateFormat = "EEEE, MMMM d"
    return f
}()

enum DateUtil {
    static var cal: Calendar { Calendar.current }

    static var today: Date { cal.startOfDay(for: Date()) }

    static func addDays(_ d: Date, _ n: Int) -> Date {
        cal.date(byAdding: .day, value: n, to: cal.startOfDay(for: d)) ?? d
    }

    static func daysBetween(_ a: Date, _ b: Date) -> Int {
        let diff = cal.dateComponents(
            [.day],
            from: cal.startOfDay(for: a),
            to: cal.startOfDay(for: b)
        ).day ?? 1
        return max(1, diff)
    }

    static func daysLeft(_ end: Date) -> Int {
        cal.dateComponents([.day], from: today, to: cal.startOfDay(for: end)).day ?? 0
    }

    static func fmt(_ d: Date) -> String { shortDateFormatter.string(from: d) }

    static func headerDate(_ d: Date = Date()) -> String { longDateFormatter.string(from: d) }
}
