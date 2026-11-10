import SwiftUI

/// Mirrors the prototype's screen state machine (Dashboard / Rentals / Inventory / Settings tabs,
/// plus detail + form screens that hide the glass tab bar).
struct RootView: View {

    private enum Screen: Equatable {
        case dashboard, rentals, inventory, settings
        case rentalDetail, productDetail, profile
        case addRental, addProduct, editProduct
    }

    @StateObject private var data = AppData()

    @State private var screen: Screen = .dashboard
    @State private var activeTab: AppTab = .dashboard
    @State private var selectedRentalId: String?
    @State private var selectedProductId: String?
    @State private var rentalReturnScreen: Screen = .dashboard

    private func screenFor(_ tab: AppTab) -> Screen {
        switch tab {
        case .dashboard: return .dashboard
        case .rentals: return .rentals
        case .inventory: return .inventory
        case .settings: return .settings
        }
    }

    private var showsTabBar: Bool {
        switch screen {
        case .dashboard, .rentals, .inventory, .settings: return true
        default: return false
        }
    }

    private var tabForScreen: AppTab {
        switch screen {
        case .rentals: return .rentals
        case .inventory: return .inventory
        case .settings: return .settings
        default: return .dashboard
        }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Theme.background.ignoresSafeArea()

            content

            if showsTabBar {
                GlassTabBar(active: tabForScreen, onNav: handleNav)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .environmentObject(data)
        .tint(Theme.blue)
        .preferredColorScheme(.light)
    }

    // MARK: Screens

    @ViewBuilder
    private var content: some View {
        switch screen {
        case .dashboard:
            DashboardView(
                onNav: handleNav,
                onRental: openRental,
                onAddRental: { screen = .addRental }
            )

        case .rentals:
            RentalsView(
                onRental: openRental,
                onAddRental: { screen = .addRental }
            )

        case .rentalDetail:
            if let rental = selectedRentalId.flatMap({ data.rental(id: $0) }) {
                RentalDetailView(rental: rental, onBack: { screen = rentalReturnScreen })
                    .id(rental.id)
            }

        case .inventory:
            InventoryView(
                onProduct: openProduct,
                onAddProduct: { screen = .addProduct }
            )

        case .addProduct:
            ProductFormView(
                mode: .add,
                onSave: { product in
                    data.addProduct(product)
                    screen = .inventory
                },
                onCancel: { screen = .inventory }
            )

        case .productDetail:
            if let product = selectedProductId.flatMap({ data.product(id: $0) }) {
                ProductDetailView(
                    product: product,
                    onBack: { screen = .inventory },
                    onRental: { id in
                        rentalReturnScreen = .productDetail
                        selectedRentalId = id
                        screen = .rentalDetail
                    },
                    onEdit: { screen = .editProduct }
                )
            }

        case .editProduct:
            if let product = selectedProductId.flatMap({ data.product(id: $0) }) {
                ProductFormView(
                    mode: .edit(product),
                    onSave: { updated in
                        data.updateProduct(updated)
                        screen = .productDetail
                    },
                    onCancel: { screen = .productDetail }
                )
                .id(product.id)
            }

        case .addRental:
            AddRentalView(
                onSave: { rental in
                    data.addRental(rental)
                    screen = screenFor(activeTab)
                },
                onCancel: { screen = screenFor(activeTab) }
            )

        case .settings:
            SettingsView(onEditProfile: { screen = .profile })

        case .profile:
            ProfileView(profile: data.profile, onBack: { screen = .settings })
        }
    }

    // MARK: Navigation

    private func handleNav(_ tab: AppTab) {
        activeTab = tab
        screen = screenFor(tab)
        selectedRentalId = nil
        selectedProductId = nil
    }

    private func openRental(_ id: String) {
        // Back returns to wherever the rental was opened from.
        rentalReturnScreen = (activeTab == .rentals) ? .rentals : .dashboard
        selectedRentalId = id
        screen = .rentalDetail
    }

    private func openProduct(_ id: String) {
        selectedProductId = id
        screen = .productDetail
    }
}
