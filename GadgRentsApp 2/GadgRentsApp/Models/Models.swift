import SwiftUI

// MARK: - Status

enum RentalStatus: String, Codable, CaseIterable, Identifiable {
    case active = "Active"
    case upcoming = "Upcoming"
    case overdue = "Overdue"
    case completed = "Completed"

    var id: String { rawValue }
}

// MARK: - Categories (emoji icons, same as the prototype)

enum ProductCategory {
    static let all: [String] = [
        "iPhones", "Lenses", "Batteries", "Microphones",
        "Lights", "Tripods", "Chargers", "Bags"
    ]

    static let icons: [String: String] = [
        "iPhones": "📱", "Lenses": "🔭", "Batteries": "🔋", "Microphones": "🎙",
        "Lights": "💡", "Tripods": "📷", "Chargers": "⚡", "Bags": "🎒"
    ]

    static func icon(_ category: String) -> String {
        icons[category] ?? "📦"
    }
}

// MARK: - Product

struct Product: Identifiable, Codable, Equatable, Hashable {
    var id: String
    var name: String
    var category: String
    var pricePerDay: Int
    var available: Bool
    var totalRentals: Int
    var rating: Double
    var description: String = ""
}

// MARK: - Rental

struct Rental: Identifiable, Codable, Equatable {
    var id: String
    var productId: String
    var productName: String
    var category: String
    var customerName: String
    var customerPhone: String
    var customerEmail: String
    var customerAddress: String
    var pricePerDay: Int
    var startDate: Date
    var endDate: Date
    var quantity: Int
    var totalCost: Int
    var status: RentalStatus
    var note: String
    var returned: Bool
}

// MARK: - Profile

struct Profile: Codable, Equatable {
    var name: String = "Joshua"
    var emoji: String = "👑"
    var role: String = "Owner"
    var business: String = "GadgRents"
    var location: String = "Metro Manila, Philippines"
    var phone: String = "+63 917 000 0001"
    var email: String = "admin@gadgrents.ph"
    var memberSince: String = "January 2024"

    static let emojis = ["👑", "👤", "🧑‍💼", "😎", "🤙", "🦁", "🔥", "⚡", "🎯", "💼"]
}

// MARK: - Seed data (same records as the Figma prototype)

enum Seed {

    static var products: [Product] {
        [
            Product(id: "p1", name: "iPhone 16 Pro Max", category: "iPhones", pricePerDay: 1600, available: false, totalRentals: 47, rating: 4.9, description: "Top-of-the-line iPhone with A18 Pro chip, 6.9\" display, and pro camera system."),
            Product(id: "p2", name: "iPhone 15 Pro", category: "iPhones", pricePerDay: 1200, available: true, totalRentals: 83, rating: 4.8, description: "Titanium design with A17 Pro chip and Action button."),
            Product(id: "p3", name: "iPhone 14 Plus", category: "iPhones", pricePerDay: 850, available: true, totalRentals: 124, rating: 4.6, description: "6.7\" display with all-day battery life. Great value."),
            Product(id: "p4", name: "Sony FE 24-70mm f/2.8 GM", category: "Lenses", pricePerDay: 2000, available: false, totalRentals: 39, rating: 4.9, description: "Professional G Master zoom lens for Sony E-mount cameras."),
            Product(id: "p5", name: "Canon RF 50mm f/1.2L", category: "Lenses", pricePerDay: 1700, available: true, totalRentals: 28, rating: 4.8, description: "Fast prime lens with exceptional sharpness and bokeh."),
            Product(id: "p6", name: "NP-FZ100 Battery Kit ×4", category: "Batteries", pricePerDay: 450, available: true, totalRentals: 201, rating: 4.7, description: "4x genuine Sony NP-FZ100 batteries with dual USB-C charger."),
            Product(id: "p7", name: "Rode Wireless GO II", category: "Microphones", pricePerDay: 1000, available: false, totalRentals: 66, rating: 4.8, description: "Dual-channel wireless mic system, 200m range, on-board recording."),
            Product(id: "p8", name: "Aputure Amaran 200x LED", category: "Lights", pricePerDay: 1400, available: true, totalRentals: 31, rating: 4.7, description: "200W bi-color LED panel with Bowens mount and app control."),
            Product(id: "p9", name: "Manfrotto 055 Carbon Tripod", category: "Tripods", pricePerDay: 700, available: true, totalRentals: 58, rating: 4.6, description: "Carbon fibre tripod, 170cm max height, 9kg payload."),
            Product(id: "p10", name: "Anker 747 GaN Charger", category: "Chargers", pricePerDay: 280, available: true, totalRentals: 312, rating: 4.5, description: "150W 4-port GaN charger, charges laptops and phones simultaneously."),
            Product(id: "p11", name: "Peak Design Backpack 45L", category: "Bags", pricePerDay: 580, available: true, totalRentals: 89, rating: 4.8, description: "45L carry-on camera backpack, weather-resistant, modular interior.")
        ]
    }

    private static func rental(
        _ id: String, _ productId: String, _ productName: String, _ category: String,
        _ customer: String, _ phone: String, _ email: String, _ address: String,
        price: Int, start: Int, end: Int, qty: Int = 1,
        status: RentalStatus, note: String, returned: Bool
    ) -> Rental {
        let s = DateUtil.addDays(DateUtil.today, start)
        let e = DateUtil.addDays(DateUtil.today, end)
        return Rental(
            id: id, productId: productId, productName: productName, category: category,
            customerName: customer, customerPhone: phone, customerEmail: email, customerAddress: address,
            pricePerDay: price, startDate: s, endDate: e, quantity: qty,
            totalCost: price * DateUtil.daysBetween(s, e) * qty,
            status: status, note: note, returned: returned
        )
    }

    static var rentals: [Rental] {
        [
            rental("r1", "p1", "iPhone 16 Pro Max", "iPhones", "Jamie Chen", "+63 917 882 3341", "jamie.chen@email.com", "Makati City, Metro Manila", price: 1600, start: -2, end: 3, status: .active, note: "Handle with care.", returned: false),
            rental("r2", "p4", "Sony FE 24-70mm f/2.8 GM", "Lenses", "Sam Rivera", "+63 918 554 9902", "sam.rivera@email.com", "Quezon City, Metro Manila", price: 2000, start: -5, end: -1, status: .overdue, note: "Needs lens cap returned.", returned: false),
            rental("r3", "p7", "Rode Wireless GO II", "Microphones", "Taylor Kim", "+63 919 771 4430", "taylor.kim@email.com", "Pasig City, Metro Manila", price: 1000, start: 4, end: 7, status: .upcoming, note: "", returned: false),
            rental("r4", "p9", "Manfrotto 055 Carbon Tripod", "Tripods", "Jordan Lee", "+63 920 340 8812", "jordan.lee@email.com", "Taguig City, Metro Manila", price: 700, start: -10, end: -4, status: .completed, note: "", returned: true),
            rental("r5", "p6", "NP-FZ100 Battery Kit ×4", "Batteries", "Morgan White", "+63 921 990 2233", "morgan.white@email.com", "Mandaluyong, Metro Manila", price: 450, start: -1, end: 2, qty: 2, status: .active, note: "2 kits requested.", returned: false),
            rental("r6", "p11", "Peak Design Backpack 45L", "Bags", "Casey Park", "+63 922 663 5577", "casey.park@email.com", "Pasay City, Metro Manila", price: 580, start: 2, end: 6, status: .upcoming, note: "Traveling to Cebu shoot.", returned: false),
            rental("r7", "p2", "iPhone 15 Pro", "iPhones", "Riley Santos", "+63 923 441 7788", "riley.santos@email.com", "Antipolo, Rizal", price: 1200, start: -3, end: 1, status: .active, note: "For content creation project.", returned: false),
            rental("r8", "p8", "Aputure Amaran 200x LED", "Lights", "Drew Reyes", "+63 924 559 3344", "drew.reyes@email.com", "Las Piñas, Metro Manila", price: 1400, start: -7, end: -2, status: .completed, note: "Studio shoot in BGC.", returned: true)
        ]
    }
}
