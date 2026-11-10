import SwiftUI

struct ProductDetailView: View {

    @EnvironmentObject var data: AppData

    let product: Product
    let onBack: () -> Void
    let onRental: (String) -> Void
    let onEdit: () -> Void

    private var productRentals: [Rental] {
        data.rentals.filter { $0.productId == product.id }
    }

    private var revenue: Int {
        productRentals.filter { $0.status != .upcoming }.reduce(0) { $0 + $1.totalCost }
    }

    private struct Stat: Identifiable {
        let label: String
        let value: String
        let color: Color
        var id: String { label }
    }

    private var stats: [Stat] {
        [
            Stat(label: "Daily Rate", value: peso(product.pricePerDay), color: Theme.blue),
            Stat(label: "Total Rentals", value: "\(product.totalRentals)", color: Theme.purple),
            Stat(label: "Revenue", value: peso(revenue), color: Theme.green)
        ]
    }

    var body: some View {
        VStack(spacing: 0) {
            NavBar(title: "Item Details", onBack: onBack, rightLabel: "Edit", onRight: onEdit)

            ScrollView {
                VStack(spacing: 0) {
                    hero

                    VStack(spacing: 12) {
                        infoCard
                        statsRow
                        availabilityCard

                        Button(action: onEdit) {
                            Text("✏️ Edit Item Details")
                                .font(.system(size: 15, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Theme.blue)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .shadow(color: Theme.blue.opacity(0.3), radius: 5, x: 0, y: 3)
                        }
                        .buttonStyle(ScaleButtonStyle(scale: 0.98))
                        .padding(.bottom, 4)

                        if !productRentals.isEmpty { history }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
                .padding(.bottom, 32)
            }
            .scrollIndicators(.hidden)
        }
        .background(Theme.background.ignoresSafeArea())
    }

    private var hero: some View {
        ZStack(alignment: .topTrailing) {
            ZStack {
                Theme.softGradient
                Text(ProductCategory.icon(product.category)).font(.system(size: 72))
            }
            StatusPill(available: product.available)
                .padding(12)
        }
        .frame(height: 160)
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(ProductCategory.icon(product.category)) \(product.category)".uppercased())
                .font(.system(size: 11, weight: .bold))
                .tracking(0.4)
                .foregroundColor(Theme.blue)

            Text(product.name)
                .font(.system(size: 20, weight: .black))
                .tracking(-0.3)
                .foregroundColor(.black)
                .padding(.top, 4).padding(.bottom, 6)

            if !product.description.isEmpty {
                Text(product.description)
                    .font(.system(size: 13))
                    .foregroundColor(Color(hex: 0x6C6C6C))
                    .lineSpacing(3)
                    .padding(.bottom, 8)
            }

            HStack(spacing: 8) {
                Text("★ \(String(format: "%.1f", product.rating))")
                    .font(.system(size: 11, weight: .semibold))
                Text("·").font(.system(size: 11))
                Text("\(product.totalRentals) rentals")
                    .font(.system(size: 11, weight: .semibold))
            }
            .foregroundColor(Theme.gray)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    private var statsRow: some View {
        HStack(spacing: 8) {
            ForEach(stats) { s in
                VStack(spacing: 2) {
                    Text(s.value)
                        .font(.system(size: 14, weight: .black))
                        .foregroundColor(s.color)
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    Text(s.label)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Theme.gray)
                }
                .padding(.horizontal, 10).padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
            }
        }
    }

    private var availabilityCard: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Availability")
                    .font(.system(size: 14, weight: .bold)).foregroundColor(.black)
                Text(product.available ? "Available for rent" : "Marked as rented out")
                    .font(.system(size: 12)).foregroundColor(Theme.gray)
            }
            Spacer()
            SwitchView(isOn: product.available) { data.toggleAvailability(product.id) }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .card(radius: 16)
    }

    private var history: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Rental History (\(productRentals.count))")
                .font(.system(size: 14, weight: .heavy))
                .foregroundColor(.black)

            ForEach(productRentals) { r in
                Button {
                    onRental(r.id)
                } label: {
                    HStack(spacing: 10) {
                        AvatarEmoji(name: r.customerName, size: 38)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(r.customerName)
                                .font(.system(size: 13, weight: .bold)).foregroundColor(.black)
                            Text("\(DateUtil.fmt(r.startDate)) – \(DateUtil.fmt(r.endDate)) · \(DateUtil.daysBetween(r.startDate, r.endDate))d")
                                .font(.system(size: 11)).foregroundColor(Theme.gray)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        VStack(alignment: .trailing, spacing: 3) {
                            Text(peso(r.totalCost))
                                .font(.system(size: 13, weight: .heavy)).foregroundColor(Theme.blue)
                            StatusPill(status: r.status)
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
                }
                .buttonStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
