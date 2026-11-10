import SwiftUI

// MARK: - Card style (white, radius, soft shadow)

extension View {
    func card(radius: CGFloat = 18) -> some View {
        self
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .shadow(color: Color.black.opacity(0.07), radius: 4, x: 0, y: 1)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    var scale: CGFloat = 0.96
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? scale : 1)
            .animation(.easeOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Avatar

struct AvatarEmoji: View {
    let name: String
    var size: CGFloat = 40

    private static let colors: [UInt32] = [
        0x007AFF, 0x5856D6, 0x34C759, 0xFF9500,
        0xFF3B30, 0xAF52DE, 0xFF2D55, 0x00C7BE
    ]

    private var color: Color {
        let units = Array(name.utf16)
        let first = Int(units.first ?? 0)
        let last = Int(units.last ?? 0)
        return Color(hex: Self.colors[(first + last) % Self.colors.count])
    }

    var body: some View {
        ZStack {
            Circle().fill(color.opacity(0.13))
            Circle().stroke(color.opacity(0.27), lineWidth: 2)
            Text("👤").font(.system(size: size * 0.48))
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Status pill

struct StatusPill: View {
    let label: String
    let bg: Color
    let text: Color
    let dot: Color

    init(status: RentalStatus) {
        label = status.rawValue
        switch status {
        case .active:
            bg = Color(hex: 0xE8F5E9); text = Color(hex: 0x1B5E20); dot = Theme.green
        case .upcoming:
            bg = Color(hex: 0xE8F0FF); text = Color(hex: 0x1A237E); dot = Theme.purple
        case .overdue:
            bg = Color(hex: 0xFFEBEE); text = Color(hex: 0xB71C1C); dot = Theme.red
        case .completed:
            bg = Color(hex: 0xF2F2F7); text = Theme.gray; dot = Theme.lightGray
        }
    }

    init(available: Bool) {
        if available {
            label = "Available"
            bg = Color(hex: 0xE8F5E9); text = Color(hex: 0x1B5E20); dot = Theme.green
        } else {
            label = "Rented Out"
            bg = Color(hex: 0xFFF3E0); text = Color(hex: 0xE65100); dot = Theme.orange
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Circle().fill(dot).frame(width: 5, height: 5)
            Text(label).font(.system(size: 11, weight: .bold))
        }
        .foregroundColor(text)
        .padding(.horizontal, 9)
        .padding(.vertical, 3)
        .background(bg)
        .clipShape(Capsule())
    }
}

// MARK: - Stat card

struct StatCard: View {
    let label: String
    let value: String
    let sub: String
    let color: Color
    let icon: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 0) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(color.opacity(0.125))
                    Text(icon).font(.system(size: 18))
                }
                .frame(width: 36, height: 36)
                .padding(.bottom, 8)

                Text(value)
                    .font(.system(size: 22, weight: .black))
                    .tracking(-0.5)
                    .foregroundColor(.black)
                    .padding(.bottom, 2)

                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Theme.gray)

                Text(sub)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(color)
                    .padding(.top, 3)
            }
            .padding(.horizontal, 14)
            .padding(.top, 14)
            .padding(.bottom, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .card(radius: 16)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

// MARK: - Switch (50×28 like the prototype)

struct SwitchView: View {
    let isOn: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule().fill(isOn ? Theme.green : Theme.fieldBorder)
                Circle()
                    .fill(Color.white)
                    .frame(width: 22, height: 22)
                    .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                    .padding(3)
            }
            .frame(width: 50, height: 28)
            .animation(.easeInOut(duration: 0.2), value: isOn)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tabs + glass bottom bar

enum AppTab: String, CaseIterable, Identifiable {
    case dashboard = "Dashboard"
    case rentals = "Rentals"
    case inventory = "Inventory"
    case settings = "Settings"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .dashboard: return "📊"
        case .rentals: return "🗂"
        case .inventory: return "📦"
        case .settings: return "⚙️"
        }
    }
}

struct GlassTabBar: View {
    let active: AppTab
    let onNav: (AppTab) -> Void

    var body: some View {
        HStack(spacing: 0) {
            ForEach(AppTab.allCases) { tab in
                let isActive = tab == active
                Button {
                    onNav(tab)
                } label: {
                    VStack(spacing: 3) {
                        Text(tab.icon)
                            .font(.system(size: 22))
                            .shadow(color: isActive ? Theme.blue.opacity(0.25) : .clear, radius: 3, x: 0, y: 1)
                        Text(tab.rawValue)
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(isActive ? Theme.blue : Color(hex: 0x3C3C43, opacity: 0.55))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 10)
                    .padding(.bottom, 8)
                    .background(
                        Group {
                            if isActive {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.white.opacity(0.55), Color.white.opacity(0.2)],
                                            startPoint: .top, endPoint: .bottom
                                        )
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                                            .stroke(Color.white.opacity(0.6), lineWidth: 1)
                                    )
                                    .shadow(color: Theme.blue.opacity(0.15), radius: 4, x: 0, y: 2)
                                    .padding(.vertical, 5)
                                    .padding(.horizontal, 10)
                            }
                        }
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous).fill(.ultraThinMaterial)
                RoundedRectangle(cornerRadius: 28, style: .continuous).fill(Color.white.opacity(0.18))
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.45), Color.white.opacity(0.05)],
                            startPoint: .top, endPoint: .center
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .stroke(Color.white.opacity(0.55), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
        .padding(.horizontal, 16)
        .padding(.top, 6)
        .padding(.bottom, 4)
    }
}

// MARK: - Nav bar (Back · Title · Action)

struct NavBar: View {
    let title: String
    var backLabel: String = "Back"
    var showChevron: Bool = true
    let onBack: () -> Void
    var rightLabel: String = ""
    var rightColor: Color = Theme.blue
    var onRight: (() -> Void)? = nil

    var body: some View {
        HStack(alignment: .bottom) {
            Button(action: onBack) {
                HStack(spacing: 4) {
                    if showChevron {
                        Text("‹").font(.system(size: 22))
                    }
                    Text(backLabel).font(.system(size: 16, weight: .medium))
                }
                .foregroundColor(Theme.blue)
            }
            .frame(minWidth: 60, alignment: .leading)

            Text(title)
                .font(.system(size: 17, weight: .bold))
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)

            Group {
                if let onRight = onRight {
                    Button(action: onRight) {
                        Text(rightLabel)
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(rightColor)
                    }
                } else {
                    Color.clear
                }
            }
            .frame(minWidth: 60, alignment: .trailing)
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .background(Color.white.opacity(0.94).ignoresSafeArea(edges: .top))
        .overlay(alignment: .bottom) {
            Rectangle().fill(Color(hex: 0xC7C7CC)).frame(height: 0.5)
        }
    }
}

struct EditingBanner: View {
    let text: String
    var body: some View {
        HStack(spacing: 8) {
            Text("✏️").font(.system(size: 14))
            Text(text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity)
        .background(Theme.blue)
    }
}

// MARK: - Form pieces

enum FieldStyle {
    case form      // white field, grey border (Add screens)
    case inline    // light-blue field (edit mode on detail screens)
}

struct FieldLabel: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 11, weight: .bold))
            .tracking(0.4)
            .foregroundColor(Theme.gray)
    }
}

private struct FieldChrome: ViewModifier {
    let style: FieldStyle
    let hasError: Bool

    func body(content: Content) -> some View {
        switch style {
        case .form:
            content
                .padding(.horizontal, 14).padding(.vertical, 11)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .stroke(hasError ? Theme.red : Theme.fieldBorder, lineWidth: 1.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        case .inline:
            content
                .padding(.horizontal, 12).padding(.vertical, 8)
                .background(Theme.editFill)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .stroke(Theme.blue.opacity(0.2), lineWidth: 1.5)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        }
    }
}

extension View {
    fileprivate func fieldChrome(_ style: FieldStyle, error: Bool = false) -> some View {
        modifier(FieldChrome(style: style, hasError: error))
    }
}

struct FormField: View {
    let label: String
    @Binding var text: String
    var placeholder: String = ""
    var error: String? = nil
    var keyboard: UIKeyboardType = .default
    var multiline: Bool = false
    var style: FieldStyle = .form

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if !label.isEmpty { FieldLabel(text: label) }

            Group {
                if multiline {
                    TextField(placeholder, text: $text, axis: .vertical)
                        .lineLimit(2...4)
                } else {
                    TextField(placeholder, text: $text)
                }
            }
            .font(.system(size: 14))
            .foregroundColor(.black)
            .keyboardType(keyboard)
            .textInputAutocapitalization(keyboard == .emailAddress ? .never : .sentences)
            .autocorrectionDisabled(keyboard == .emailAddress)
            .fieldChrome(style, error: error != nil)

            if let error = error {
                Text(error)
                    .font(.system(size: 11))
                    .foregroundColor(Theme.red)
            }
        }
    }
}

struct MenuOption: Identifiable, Hashable {
    let id: String
    let title: String
}

struct OptionMenu: View {
    let label: String
    let options: [MenuOption]
    @Binding var selection: String
    var style: FieldStyle = .form

    private var currentTitle: String {
        options.first { $0.id == selection }?.title ?? ""
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            if !label.isEmpty { FieldLabel(text: label) }

            Menu {
                ForEach(options) { option in
                    Button(option.title) { selection = option.id }
                }
            } label: {
                HStack {
                    Text(currentTitle)
                        .font(.system(size: 14))
                        .foregroundColor(.black)
                        .lineLimit(1)
                    Spacer(minLength: 8)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Theme.gray)
                }
                .fieldChrome(style)
            }
        }
    }
}

struct DateField: View {
    let label: String
    @Binding var date: Date
    var range: PartialRangeFrom<Date>
    var style: FieldStyle = .form
    var error: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            FieldLabel(text: label)

            HStack {
                DatePicker("", selection: $date, in: range, displayedComponents: .date)
                    .labelsHidden()
                    .datePickerStyle(.compact)
                Spacer(minLength: 0)
            }
            .padding(.vertical, -4)
            .fieldChrome(style, error: error != nil)

            if let error = error {
                Text(error)
                    .font(.system(size: 11))
                    .foregroundColor(Theme.red)
            }
        }
    }
}

struct PrimaryButton: View {
    let title: String
    var color: Color = Theme.blue
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 16, weight: .heavy))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(color)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: color.opacity(0.3), radius: 6, x: 0, y: 4)
        }
        .buttonStyle(ScaleButtonStyle(scale: 0.98))
    }
}

struct SectionTitle: View {
    let text: String
    var body: some View {
        Text(text.uppercased())
            .font(.system(size: 12, weight: .heavy))
            .tracking(0.5)
            .foregroundColor(Theme.gray)
    }
}

/// Blue gradient summary card used on the Add/Edit forms.
struct SummaryCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) { content }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            .shadow(color: Theme.blue.opacity(0.3), radius: 7, x: 0, y: 4)
    }
}

// MARK: - Bottom sheet dialog (Confirm Return / Log Out / Delete)

struct BottomSheetDialog<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) { self.content = content() }

    var body: some View {
        ZStack(alignment: .bottom) {
            Color.black.opacity(0.45).ignoresSafeArea()

            VStack(spacing: 0) {
                Capsule()
                    .fill(Color(hex: 0xD1D1D6))
                    .frame(width: 40, height: 4)
                    .padding(.bottom, 20)
                content
            }
            .padding(.top, 24)
            .padding(.horizontal, 20)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity)
            .background(
                UnevenRoundedRectangle(topLeadingRadius: 24, topTrailingRadius: 24)
                    .fill(Color.white)
                    .ignoresSafeArea(edges: .bottom)
            )
        }
        .transition(.opacity)
    }
}

struct SheetButtons: View {
    let cancelTitle: String
    let confirmTitle: String
    let confirmColor: Color
    let onCancel: () -> Void
    let onConfirm: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Button(action: onCancel) {
                Text(cancelTitle)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundColor(Theme.secondaryLabel)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Theme.background)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .layoutPriority(1)

            Button(action: onConfirm) {
                Text(confirmTitle)
                    .font(.system(size: 15, weight: .heavy))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(confirmColor)
                    .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .layoutPriority(1.5)
        }
    }
}

struct EmptyState: View {
    let icon: String
    let title: String
    var subtitle: String? = nil
    var iconSize: CGFloat = 48
    var topPadding: CGFloat = 60

    var body: some View {
        VStack(spacing: 4) {
            Text(icon).font(.system(size: iconSize)).padding(.bottom, 8)
            Text(title)
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Theme.secondaryLabel)
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundColor(Theme.gray)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, topPadding)
    }
}

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        HStack(spacing: 8) {
            Text("🔍").font(.system(size: 14))
            TextField(placeholder, text: $text)
                .font(.system(size: 14))
                .foregroundColor(.black)
            if !text.isEmpty {
                Button { text = "" } label: {
                    Text("✕").font(.system(size: 15)).foregroundColor(Theme.gray)
                }
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 9)
        .background(Theme.fieldBorder)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var selectedColor: Color = Theme.blue
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(isSelected ? .white : Theme.secondaryLabel)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? selectedColor : Theme.fieldBorder)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}
