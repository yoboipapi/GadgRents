import SwiftUI
import Combine

// MARK: - Persistence (UserDefaults, mirrors the prototype's localStorage)

private enum Store {
    static func load<T: Decodable>(_ key: String) -> T? {
        guard let data = UserDefaults.standard.data(forKey: key) else { return nil }
        return try? JSONDecoder().decode(T.self, from: data)
    }

    static func save<T: Encodable>(_ value: T, key: String) {
        if let data = try? JSONEncoder().encode(value) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

// MARK: - AppData

final class AppData: ObservableObject {

    @Published var products: [Product] {
        didSet { Store.save(products, key: "gr_products") }
    }

    @Published var rentals: [Rental] {
        didSet { Store.save(rentals, key: "gr_rentals") }
    }

    @Published var activityIds: [String] {
        didSet { Store.save(activityIds, key: "gr_activity") }
    }

    @Published var profile: Profile {
        didSet { Store.save(profile, key: "gr_profile") }
    }

    init() {
        let seededRentals = Seed.rentals
        products = Store.load("gr_products") ?? Seed.products
        rentals = Store.load("gr_rentals") ?? seededRentals
        activityIds = Store.load("gr_activity") ?? seededRentals.map { $0.id }
        profile = Store.load("gr_profile") ?? Profile()
    }

    // MARK: Derived values

    var activeRentals: [Rental] { rentals.filter { $0.status == .active } }
    var overdueRentals: [Rental] { rentals.filter { $0.status == .overdue } }
    var upcomingRentals: [Rental] { rentals.filter { $0.status == .upcoming } }
    var completedRentals: [Rental] { rentals.filter { $0.status == .completed } }

    /// Revenue ignores upcoming rentals (same as the prototype).
    var processedRentals: [Rental] { rentals.filter { $0.status != .upcoming } }
    var totalRevenue: Int { processedRentals.reduce(0) { $0 + $1.totalCost } }

    var availableCount: Int { products.filter { $0.available }.count }
    var uniqueCustomers: Int { Set(rentals.map { $0.customerName }).count }

    var activityRentals: [Rental] {
        activityIds.compactMap { id in rentals.first { $0.id == id } }
    }

    func rental(id: String) -> Rental? { rentals.first { $0.id == id } }
    func product(id: String) -> Product? { products.first { $0.id == id } }

    // MARK: Activity log

    private func pushActivity(_ id: String) {
        activityIds.removeAll { $0 == id }
        activityIds.insert(id, at: 0)
    }

    func removeActivity(_ id: String) {
        activityIds.removeAll { $0 == id }
    }

    func clearActivity() {
        activityIds = []
    }

    // MARK: Rentals

    func addRental(_ rental: Rental) {
        rentals.insert(rental, at: 0)
        if rental.status == .active {
            setAvailability(productId: rental.productId, available: false)
        }
        pushActivity(rental.id)
    }

    func updateRental(_ updated: Rental) {
        if let i = rentals.firstIndex(where: { $0.id == updated.id }) {
            rentals[i] = updated
        }
        pushActivity(updated.id)
    }

    func markReturned(_ id: String) {
        guard let i = rentals.firstIndex(where: { $0.id == id }) else { return }
        rentals[i].returned = true
        rentals[i].status = .completed
        setAvailability(productId: rentals[i].productId, available: true)
        pushActivity(id)
    }

    // MARK: Products

    func setAvailability(productId: String, available: Bool) {
        if let i = products.firstIndex(where: { $0.id == productId }) {
            products[i].available = available
        }
    }

    func toggleAvailability(_ id: String) {
        if let i = products.firstIndex(where: { $0.id == id }) {
            products[i].available.toggle()
        }
    }

    func addProduct(_ product: Product) {
        products.insert(product, at: 0)
    }

    func updateProduct(_ updated: Product) {
        if let i = products.firstIndex(where: { $0.id == updated.id }) {
            products[i] = updated
        }
        for i in rentals.indices where rentals[i].productId == updated.id {
            rentals[i].productName = updated.name
            rentals[i].category = updated.category
            rentals[i].pricePerDay = updated.pricePerDay
            rentals[i].totalCost = updated.pricePerDay
                * DateUtil.daysBetween(rentals[i].startDate, rentals[i].endDate)
        }
    }
}
