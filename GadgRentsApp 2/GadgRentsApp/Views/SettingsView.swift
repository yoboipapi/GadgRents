import SwiftUI

struct SettingsView: View {

    @EnvironmentObject var data: AppData

    let onEditProfile: () -> Void

    @State private var showLogout = false
    @State private var showDelete = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Settings")
                        .font(.system(size: 28, weight: .black))
                        .tracking(-0.5)
                        .foregroundColor(.black)
                        .padding(.bottom, 20)

                    profileCard

                    section(title: "Business") {
                        row(icon: "🏪", label: "Business Name", value: data.profile.business, onPress: onEditProfile)
                        divider
                        row(icon: "📍", label: "Location", value: orDash(data.profile.location), onPress: onEditProfile)
                        divider
                        row(icon: "📞", label: "Contact Number", value: orDash(data.profile.phone), onPress: onEditProfile)
                        divider
                        row(icon: "✉️", label: "Email", value: orDash(data.profile.email), onPress: onEditProfile)
                    }

                    section(title: "About") {
                        row(icon: "📱", label: "App Name", value: "GadgRents")
                        divider
                        row(icon: "🔖", label: "Version", value: "1.0.0")
                        divider
                        row(icon: "📅", label: "Member Since", value: data.profile.memberSince)
                    }

                    actionButton(
                        icon: "🚪", iconBg: Color(hex: 0xE8F0FF),
                        title: "Log Out", color: Theme.blue
                    ) { showLogout = true }
                    .padding(.bottom, 12)

                    actionButton(
                        icon: "🗑", iconBg: Color(hex: 0xFFF0F0),
                        title: "Delete Account", color: Theme.red
                    ) { showDelete = true }
                    .padding(.bottom, 24)

                    Text("GadgRents v1.0.0 · Made for admins")
                        .font(.system(size: 12))
                        .foregroundColor(Theme.chevron)
                        .frame(maxWidth: .infinity)
                }
                .padding(.horizontal, 16)
                .padding(.top, 4)
                .padding(.bottom, 100)
            }
            .scrollIndicators(.hidden)
            .background(Theme.background.ignoresSafeArea())

            if showLogout { logoutSheet }
            if showDelete { deleteSheet }
        }
        .animation(.easeInOut(duration: 0.2), value: showLogout)
        .animation(.easeInOut(duration: 0.2), value: showDelete)
    }

    private func orDash(_ s: String) -> String { s.isEmpty ? "—" : s }

    // MARK: Profile card

    private var profileCard: some View {
        Button(action: onEditProfile) {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle().fill(Color.white.opacity(0.25))
                        Text(data.profile.emoji).font(.system(size: 28))
                    }
                    .frame(width: 56, height: 56)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(data.profile.name)
                            .font(.system(size: 18, weight: .black))
                            .foregroundColor(.white)
                        Text("\(data.profile.role) · \(data.profile.business)")
                            .font(.system(size: 13))
                            .foregroundColor(.white.opacity(0.75))
                    }
                    Spacer()
                    Text("›").font(.system(size: 18)).foregroundColor(.white.opacity(0.6))
                }

                Rectangle().fill(Color.white.opacity(0.2)).frame(height: 1).padding(.top, 14)

                HStack(spacing: 20) {
                    profileStat("\(data.rentals.count)", "Rentals")
                    profileStat("\(data.products.count)", "Items")
                    profileStat(peso(data.totalRevenue), "Revenue")
                    Spacer(minLength: 0)
                }
                .padding(.top, 14)
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(Theme.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Theme.blue.opacity(0.3), radius: 10, x: 0, y: 6)
        }
        .buttonStyle(.plain)
        .padding(.bottom, 24)
    }

    private func profileStat(_ value: String, _ label: String) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(value).font(.system(size: 15, weight: .heavy)).foregroundColor(.white)
            Text(label).font(.system(size: 11)).foregroundColor(.white.opacity(0.65))
        }
    }

    // MARK: Sections / rows

    private func section<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title.uppercased())
                .font(.system(size: 12, weight: .bold))
                .tracking(0.5)
                .foregroundColor(Theme.gray)
                .padding(.horizontal, 4)

            VStack(spacing: 0) { content() }
                .frame(maxWidth: .infinity)
                .card()
        }
        .padding(.bottom, 24)
    }

    private var divider: some View {
        Rectangle().fill(Theme.background).frame(height: 0.5).padding(.horizontal, 16)
    }

    @ViewBuilder
    private func row(icon: String, label: String, value: String, onPress: (() -> Void)? = nil) -> some View {
        let content = HStack(spacing: 12) {
            Text(icon).font(.system(size: 20)).frame(width: 26)
            Text(label).font(.system(size: 15, weight: .medium)).foregroundColor(.black)
            Spacer(minLength: 8)
            Text(value)
                .font(.system(size: 14))
                .foregroundColor(Theme.gray)
                .lineLimit(1)
                .padding(.trailing, 4)
            if onPress != nil {
                Text("›").font(.system(size: 18)).foregroundColor(Theme.chevron)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 13)
        .contentShape(Rectangle())

        if let onPress = onPress {
            Button(action: onPress) { content }.buttonStyle(.plain)
        } else {
            content
        }
    }

    private func actionButton(icon: String, iconBg: Color, title: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 18))
                    .frame(width: 36, height: 36)
                    .background(iconBg)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(color)
                Spacer()
                Text("›").font(.system(size: 18)).foregroundColor(Theme.chevron)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 15)
            .frame(maxWidth: .infinity)
            .card()
        }
        .buttonStyle(.plain)
    }

    // MARK: Sheets

    private var logoutSheet: some View {
        BottomSheetDialog {
            Text("🚪")
                .font(.system(size: 28))
                .frame(width: 56, height: 56)
                .background(Color(hex: 0xE8F0FF))
                .clipShape(Circle())
                .padding(.bottom, 14)

            Text("Log Out?")
                .font(.system(size: 19, weight: .heavy))
                .foregroundColor(.black)
                .padding(.bottom, 6)

            Text("You will be signed out of your GadgRents admin account.")
                .font(.system(size: 14))
                .foregroundColor(Theme.gray)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.bottom, 24)

            SheetButtons(
                cancelTitle: "Cancel", confirmTitle: "Log Out", confirmColor: Theme.blue,
                onCancel: { showLogout = false },
                onConfirm: { showLogout = false }
            )
        }
    }

    private var deleteSheet: some View {
        BottomSheetDialog {
            Text("⚠️")
                .font(.system(size: 28))
                .frame(width: 56, height: 56)
                .background(Color(hex: 0xFFF0F0))
                .clipShape(Circle())
                .padding(.bottom, 14)

            Text("Delete Account?")
                .font(.system(size: 19, weight: .heavy))
                .foregroundColor(.black)
                .padding(.bottom, 6)

            (Text("This will permanently delete your account and all GadgRents data. This action ")
                .foregroundColor(Theme.gray)
             + Text("cannot be undone").fontWeight(.semibold).foregroundColor(Theme.red)
             + Text(".").foregroundColor(Theme.gray))
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.bottom, 24)

            SheetButtons(
                cancelTitle: "Cancel", confirmTitle: "Delete Account", confirmColor: Theme.red,
                onCancel: { showDelete = false },
                onConfirm: { showDelete = false }
            )
        }
    }
}
