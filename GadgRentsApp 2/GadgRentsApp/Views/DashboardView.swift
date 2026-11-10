import SwiftUI

private struct DashboardAlert: Identifiable {
    let rental: Rental
    let isOverdue: Bool
    var id: String { rental.id }
}

struct DashboardView: View {

    @EnvironmentObject var data: AppData

    let onNav: (AppTab) -> Void
    let onRental: (String) -> Void
    let onAddRental: () -> Void

    private var alerts: [DashboardAlert] {
        let overdue = data.overdueRentals.map { DashboardAlert(rental: $0, isOverdue: true) }
        let upcoming = data.upcomingRentals.prefix(2).map { DashboardAlert(rental: $0, isOverdue: false) }
        return overdue + upcoming
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                header
                revenueCard
                statsGrid
                if !alerts.isEmpty { alertsSection }
                activitySection
            }
            .padding(.bottom, 100)
        }
        .scrollIndicators(.hidden)
        .background(Theme.background.ignoresSafeArea())
    }

    // MARK: Header

    private var header: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(data.profile.business.isEmpty ? "GadgRents" : data.profile.business)
                .font(.system(size: 34, weight: .black))
                .tracking(-1)
                .foregroundColor(.black)
                .padding(.bottom, 1)

            Text("Welcome back, \(data.profile.name) \(data.profile.emoji)")
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(Theme.gray)

            Text(DateUtil.headerDate())
                .font(.system(size: 11))
                .foregroundColor(Theme.lightGray)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .padding(.bottom, 16)
    }

    // MARK: Revenue

    private var revenueCard: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("TOTAL REVENUE")
                .font(.system(size: 12, weight: .bold))
                .tracking(0.5)
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 4)

            Text(peso(data.totalRevenue))
                .font(.system(size: 32, weight: .black))
                .tracking(-1)
                .foregroundColor(.white)
                .padding(.bottom, 2)

            Text("All time · \(data.processedRentals.count) rentals processed")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
                .padding(.bottom, 16)

            HStack(alignment: .top, spacing: 20) {
                miniStat(value: data.activeRentals.count, label: "Active Now")
                Rectangle().fill(Color.white.opacity(0.2)).frame(width: 1)
                miniStat(value: data.overdueRentals.count, label: "Overdue")
                Rectangle().fill(Color.white.opacity(0.2)).frame(width: 1)
                miniStat(value: data.availableCount, label: "Available")
                Spacer(minLength: 0)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [Theme.blue, Theme.purple], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: Theme.blue.opacity(0.35), radius: 10, x: 0, y: 6)
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
    }

    private func miniStat(value: Int, label: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("\(value)")
                .font(.system(size: 18, weight: .heavy))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 11))
                .foregroundColor(.white.opacity(0.65))
        }
    }

    // MARK: Stats

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)], spacing: 10) {
            StatCard(
                label: "Active Rentals",
                value: "\(data.activeRentals.count)",
                sub: "+\(data.upcomingRentals.count) upcoming",
                color: Theme.green, icon: "✅"
            ) { onNav(.rentals) }

            StatCard(
                label: "Overdue Items",
                value: "\(data.overdueRentals.count)",
                sub: data.overdueRentals.isEmpty ? "All clear" : "Needs attention",
                color: Theme.red, icon: "⚠️"
            ) { onNav(.rentals) }

            StatCard(
                label: "Total Inventory",
                value: "\(data.products.count)",
                sub: "\(data.availableCount) available",
                color: Theme.blue, icon: "📦"
            ) { onNav(.inventory) }

            StatCard(
                label: "Total Customers",
                value: "\(data.uniqueCustomers)",
                sub: "this period",
                color: Theme.purple, icon: "👥"
            ) { onNav(.rentals) }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
    }

    // MARK: Alerts

    private var alertsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("🔔 Alerts")
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(.black)

            VStack(spacing: 8) {
                ForEach(alerts) { alert in
                    alertRow(alert)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
    }

    private func alertRow(_ alert: DashboardAlert) -> some View {
        let r = alert.rental
        let title = alert.isOverdue ? "Overdue: \(r.productName)" : "Due Soon: \(r.productName)"
        let subtitle = alert.isOverdue
            ? "\(r.customerName) · \(abs(DateUtil.daysLeft(r.endDate)))d overdue"
            : "\(r.customerName) · starts \(DateUtil.fmt(r.startDate))"

        return Button {
            onRental(r.id)
        } label: {
            HStack(spacing: 10) {
                Text(alert.isOverdue ? "🚨" : "🕐").font(.system(size: 22))

                VStack(alignment: .leading, spacing: 1) {
                    Text(title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    Text(subtitle)
                        .font(.system(size: 11))
                        .foregroundColor(Theme.gray)
                }
                Spacer(minLength: 0)

                Text("›").font(.system(size: 18)).foregroundColor(Theme.chevron)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(alert.isOverdue ? Color(hex: 0xFFF5F5) : Color(hex: 0xF0F5FF))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(alert.isOverdue ? Color(hex: 0xFFCDD2) : Color(hex: 0xC5CAE9), lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
        .buttonStyle(.plain)
    }

    // MARK: Recent activity

    private var activitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Recent Activity")
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundColor(.black)
                Spacer()

                HStack(spacing: 6) {
                    if !data.activityRentals.isEmpty {
                        Button {
                            withAnimation { data.clearActivity() }
                        } label: {
                            Text("Clear All")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(Theme.red)
                                .padding(.horizontal, 12).padding(.vertical, 6)
                                .background(Theme.red.opacity(0.125))
                                .clipShape(Capsule())
                        }
                    }

                    Button(action: onAddRental) {
                        Text("+ Add")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 14).padding(.vertical, 6)
                            .background(Theme.blue)
                            .clipShape(Capsule())
                    }
                }
            }

            if data.activityRentals.isEmpty {
                EmptyState(
                    icon: "📋", title: "No activity yet",
                    subtitle: "Changes and new rentals will appear here",
                    iconSize: 36, topPadding: 32
                )
            } else {
                VStack(spacing: 8) {
                    ForEach(data.activityRentals) { r in
                        activityCard(r)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 18)
    }

    private func activityCard(_ r: Rental) -> some View {
        VStack(spacing: 0) {
            Button {
                onRental(r.id)
            } label: {
                HStack(spacing: 10) {
                    AvatarEmoji(name: r.customerName, size: 40)

                    VStack(alignment: .leading, spacing: 1) {
                        Text(r.customerName)
                            .font(.system(size: 13, weight: .heavy))
                            .foregroundColor(.black)
                        Text(r.productName)
                            .font(.system(size: 11))
                            .foregroundColor(Theme.gray)
                            .lineLimit(1)
                            .padding(.bottom, 3)
                        Text("\(DateUtil.fmt(r.startDate)) → \(DateUtil.fmt(r.endDate)) · \(DateUtil.daysBetween(r.startDate, r.endDate))d")
                            .font(.system(size: 10))
                            .foregroundColor(Theme.lightGray)
                    }
                    Spacer(minLength: 4)

                    VStack(alignment: .trailing, spacing: 4) {
                        StatusPill(status: r.status)
                        Text(peso(r.totalCost))
                            .font(.system(size: 12, weight: .heavy))
                            .foregroundColor(Theme.blue)
                    }
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain)

            Rectangle().fill(Theme.background).frame(height: 0.5)

            Button {
                withAnimation { data.removeActivity(r.id) }
            } label: {
                Text("Remove from activity")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(Theme.red)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
        }
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .shadow(color: Color.black.opacity(0.06), radius: 3, x: 0, y: 1)
    }
}
