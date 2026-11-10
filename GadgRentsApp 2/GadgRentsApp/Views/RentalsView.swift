import SwiftUI

struct RentalsView: View {

    @EnvironmentObject var data: AppData

    let onRental: (String) -> Void
    let onAddRental: () -> Void

    @State private var filter: RentalStatus? = nil
    @State private var search = ""

    private var displayed: [Rental] {
        data.rentals.filter { r in
            let matchesFilter = filter == nil || r.status == filter
            let q = search.lowercased()
            let matchesSearch = q.isEmpty
                || r.customerName.lowercased().contains(q)
                || r.productName.lowercased().contains(q)
            return matchesFilter && matchesSearch
        }
    }

    private func count(_ status: RentalStatus?) -> Int {
        guard let status = status else { return data.rentals.count }
        return data.rentals.filter { $0.status == status }.count
    }

    private func chipColor(_ status: RentalStatus?) -> Color {
        switch status {
        case .overdue: return Theme.red
        case .active: return Theme.green
        default: return Theme.blue
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                HStack {
                    Text("All Rentals")
                        .font(.system(size: 28, weight: .black))
                        .tracking(-0.5)
                        .foregroundColor(.black)
                    Spacer()
                    Button(action: onAddRental) {
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

                SearchBar(text: $search, placeholder: "Search customer or item...")
                    .padding(.bottom, 10)

                ScrollView(.horizontal) {
                    HStack(spacing: 6) {
                        chip("All", nil)
                        chip("Active", .active)
                        chip("Upcoming", .upcoming)
                        chip("Overdue", .overdue)
                        chip("Completed", .completed)
                    }
                    .padding(.bottom, 2)
                }
                .scrollIndicators(.hidden)
            }
            .padding(.horizontal, 16)
            .padding(.top, 4)
            .padding(.bottom, 10)

            ScrollView {
                if displayed.isEmpty {
                    EmptyState(icon: "🗂", title: "No rentals found")
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(displayed) { r in
                            rentalCard(r)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 4)
                    .padding(.bottom, 100)
                }
            }
            .scrollIndicators(.hidden)
        }
        .background(Theme.background.ignoresSafeArea())
    }

    private func chip(_ title: String, _ status: RentalStatus?) -> some View {
        FilterChip(
            title: "\(title) (\(count(status)))",
            isSelected: filter == status,
            selectedColor: chipColor(status)
        ) {
            filter = status
        }
    }

    private func rentalCard(_ r: Rental) -> some View {
        Button {
            onRental(r.id)
        } label: {
            HStack(spacing: 12) {
                AvatarEmoji(name: r.customerName, size: 46)

                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .top) {
                        Text(r.customerName)
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(.black)
                        Spacer(minLength: 6)
                        Text(peso(r.totalCost))
                            .font(.system(size: 14, weight: .heavy))
                            .foregroundColor(Theme.blue)
                    }
                    .padding(.bottom, 2)

                    Text(r.productName)
                        .font(.system(size: 12))
                        .foregroundColor(Theme.gray)
                        .lineLimit(1)
                        .padding(.bottom, 4)

                    HStack(spacing: 6) {
                        StatusPill(status: r.status)
                        Text("\(DateUtil.daysBetween(r.startDate, r.endDate))d · \(DateUtil.fmt(r.startDate))")
                            .font(.system(size: 10))
                            .foregroundColor(Theme.lightGray)
                    }
                }
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .card(radius: 16)
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(r.status == .overdue ? Color(hex: 0xFFCDD2) : Color.clear, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}
