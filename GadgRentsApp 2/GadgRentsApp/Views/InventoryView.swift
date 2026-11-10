import SwiftUI

struct InventoryView: View {

    @EnvironmentObject var data: AppData

    let onProduct: (String) -> Void
    let onAddProduct: () -> Void

    @State private var search = ""
    @State private var category = "All"

    private var categories: [String] {
        var seen = Set<String>()
        let ordered = data.products.map { $0.category }.filter { seen.insert($0).inserted }
        return ["All"] + ordered
    }

    private var displayed: [Product] {
        data.products.filter { p in
            let matchesCat = category == "All" || p.category == category
            let matchesSearch = search.isEmpty || p.name.lowercased().contains(search.lowercased())
            return matchesCat && matchesSearch
        }
    }

    private func activeCount(for id: String) -> Int {
        data.rentals.filter { $0.productId == id && ($0.status == .active || $0.status == .upcoming) }.count
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack {
                    Text("Inventory")
                        .font(.system(size: 28, weight: .black))
                        .tracking(-0.5)
                        .foregroundColor(.black)
                    Spacer()
                    Button(action: onAddProduct) {
                        Text("+ Add")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16).padding(.vertical, 8)
                            .background(Theme.blue)
                            .clipShape(Capsule())
                            .shadow(color: Theme.blue.opacity(0.3), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.bottom, 12)

                SearchBar(text: $search, placeholder: "Search inventory...")
                    .padding(.bottom, 10)

                ScrollView(.horizontal) {
                    HStack(spacing: 6) {
                        ForEach(categories, id: \.self) { c in
                            FilterChip(
                                title: c == "All" ? "All" : "\(ProductCategory.icon(c)) \(c)",
                                isSelected: category == c
                            ) { category = c }
                        }
                    }
                    .padding(.bottom, 2)
                }
                .scrollIndicators(.hidden)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 10)

            ScrollView {
                LazyVStack(spacing: 10) {
                    ForEach(displayed) { p in
                        productCard(p)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
        }
        .background(Theme.background.ignoresSafeArea())
    }

    private func productCard(_ p: Product) -> some View {
        let active = activeCount(for: p.id)

        return VStack(spacing: 0) {
            Button {
                onProduct(p.id)
            } label: {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 13, style: .continuous).fill(Theme.softGradient)
                        Text(ProductCategory.icon(p.category)).font(.system(size: 26))
                    }
                    .frame(width: 56, height: 56)

                    VStack(alignment: .leading, spacing: 0) {
                        Text(p.name)
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.black)
                            .lineLimit(1)
                            .padding(.bottom, 2)

                        Text("\(ProductCategory.icon(p.category)) \(p.category) · ★ \(String(format: "%.1f", p.rating)) · \(p.totalRentals) rentals")
                            .font(.system(size: 11))
                            .foregroundColor(Theme.gray)
                            .lineLimit(1)
                            .padding(.bottom, 5)

                        HStack(spacing: 6) {
                            StatusPill(available: p.available)
                            if active > 0 {
                                Text("\(active) active")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(Theme.purple)
                                    .padding(.horizontal, 7).padding(.vertical, 2)
                                    .background(Color(hex: 0xEEEEFF))
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    VStack(alignment: .trailing, spacing: 1) {
                        Text(peso(p.pricePerDay))
                            .font(.system(size: 16, weight: .black))
                            .foregroundColor(Theme.blue)
                        Text("per day")
                            .font(.system(size: 10))
                            .foregroundColor(Theme.gray)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.top, 14)
                .padding(.bottom, 12)
            }
            .buttonStyle(.plain)

            Rectangle().fill(Theme.background).frame(height: 0.5)

            HStack {
                Text(p.available ? "Mark as Rented Out" : "Mark as Available")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(Theme.secondaryLabel)
                Spacer()
                SwitchView(isOn: p.available) { data.toggleAvailability(p.id) }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
        }
        .card(radius: 16)
    }
}
