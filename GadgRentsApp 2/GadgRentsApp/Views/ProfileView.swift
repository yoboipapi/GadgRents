import SwiftUI

struct ProfileView: View {

    @EnvironmentObject var data: AppData

    let onBack: () -> Void

    @State private var editing = false
    @State private var form: Profile
    @State private var showEmojiPicker = false

    init(profile: Profile, onBack: @escaping () -> Void) {
        self.onBack = onBack
        _form = State(initialValue: profile)
    }

    private struct FieldSpec: Identifiable {
        let keyPath: WritableKeyPath<Profile, String>
        let icon: String
        let label: String
        let placeholder: String
        var keyboard: UIKeyboardType = .default
        var id: String { label }
    }

    private let fields: [FieldSpec] = [
        FieldSpec(keyPath: \.business, icon: "🏪", label: "Business Name", placeholder: "e.g. GadgRents"),
        FieldSpec(keyPath: \.role, icon: "🧑‍💼", label: "Role / Title", placeholder: "e.g. Owner"),
        FieldSpec(keyPath: \.location, icon: "📍", label: "Location", placeholder: "City, Country"),
        FieldSpec(keyPath: \.phone, icon: "📞", label: "Contact Number", placeholder: "+63 9xx xxx xxxx", keyboard: .phonePad),
        FieldSpec(keyPath: \.email, icon: "✉️", label: "Email", placeholder: "admin@example.com", keyboard: .emailAddress),
        FieldSpec(keyPath: \.memberSince, icon: "📅", label: "Member Since", placeholder: "e.g. January 2024")
    ]

    private var profile: Profile { data.profile }

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "My Profile",
                backLabel: editing ? "Cancel" : "Back",
                showChevron: !editing,
                onBack: { editing ? cancel() : onBack() },
                rightLabel: editing ? "Save" : "Edit",
                rightColor: editing ? Theme.green : Theme.blue,
                onRight: { editing ? save() : startEditing() }
            )

            if editing { EditingBanner(text: "Editing profile — tap Save when done") }

            ScrollView {
                VStack(spacing: 0) {
                    avatarSection
                    statsRow
                    infoCard
                    if editing {
                        PrimaryButton(title: "✓ Save Profile", color: Theme.green, action: save)
                            .padding(.bottom, 12)
                    }
                    activeCard
                }
                .padding(.horizontal, 16)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Theme.background.ignoresSafeArea())
    }

    // MARK: Avatar

    private var avatarSection: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .bottomTrailing) {
                ZStack {
                    Circle().fill(Theme.gradient)
                    Text(form.emoji).font(.system(size: 42))
                }
                .frame(width: 88, height: 88)
                .shadow(color: Theme.blue.opacity(0.35), radius: 10, x: 0, y: 6)

                if editing {
                    Button {
                        showEmojiPicker.toggle()
                    } label: {
                        Text("✏️")
                            .font(.system(size: 13))
                            .frame(width: 28, height: 28)
                            .background(Theme.blue)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 2))
                    }
                }
            }
            .padding(.bottom, 12)

            if showEmojiPicker && editing {
                emojiPicker.padding(.bottom, 12)
            }

            if editing {
                TextField("Your name", text: $form.name)
                    .font(.system(size: 22, weight: .black))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.black)
                    .padding(.horizontal, 14).padding(.vertical, 6)
                    .background(Theme.editFill)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Theme.blue.opacity(0.27), lineWidth: 1.5)
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .frame(maxWidth: 300)
                    .padding(.bottom, 4)
            } else {
                Text(profile.name)
                    .font(.system(size: 24, weight: .black))
                    .foregroundColor(.black)
                    .padding(.bottom, 4)
            }

            Text("\(profile.role) · \(profile.business)")
                .font(.system(size: 14))
                .foregroundColor(Theme.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.bottom, 24)
    }

    private var emojiPicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 5), spacing: 8) {
            ForEach(Profile.emojis, id: \.self) { e in
                Button {
                    form.emoji = e
                    showEmojiPicker = false
                } label: {
                    Text(e)
                        .font(.system(size: 24))
                        .frame(width: 44, height: 44)
                        .background(form.emoji == e ? Color(hex: 0xE8F0FF) : Theme.background)
                        .clipShape(Circle())
                        .overlay(
                            Circle().stroke(form.emoji == e ? Theme.blue : Color.clear, lineWidth: 2.5)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: Color.black.opacity(0.12), radius: 8, x: 0, y: 4)
    }

    // MARK: Stats + info

    private var statsRow: some View {
        HStack(spacing: 10) {
            statBox(value: peso(data.totalRevenue), label: "Total Revenue", color: Theme.blue)
            statBox(value: "\(data.rentals.count)", label: "Total Rentals", color: Theme.green)
        }
        .padding(.bottom, 16)
    }

    private func statBox(value: String, label: String, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(size: 17, weight: .black)).foregroundColor(color)
            Text(label).font(.system(size: 11, weight: .semibold)).foregroundColor(Theme.gray)
        }
        .padding(14)
        .frame(maxWidth: .infinity)
        .card(radius: 16)
    }

    private var infoCard: some View {
        VStack(spacing: 0) {
            ForEach(Array(fields.enumerated()), id: \.element.id) { index, f in
                HStack(spacing: 12) {
                    Text(f.icon).font(.system(size: 20)).frame(width: 26)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(f.label)
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(Theme.gray)

                        if editing {
                            TextField(f.placeholder, text: binding(f.keyPath))
                                .font(.system(size: 14))
                                .foregroundColor(.black)
                                .keyboardType(f.keyboard)
                                .textInputAutocapitalization(f.keyboard == .emailAddress ? .never : .sentences)
                                .autocorrectionDisabled(f.keyboard == .emailAddress)
                                .padding(.horizontal, 10).padding(.vertical, 7)
                                .background(Theme.editFill)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                                        .stroke(Theme.blue.opacity(0.27), lineWidth: 1.5)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                        } else {
                            let value = profile[keyPath: f.keyPath]
                            Text(value.isEmpty ? f.placeholder : value)
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(value.isEmpty ? Theme.lightGray : .black)
                                .lineLimit(1)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    if !editing {
                        Text("›").font(.system(size: 16)).foregroundColor(Theme.chevron)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)

                if index < fields.count - 1 {
                    Rectangle().fill(Theme.background).frame(height: 0.5).padding(.horizontal, 16)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .card()
        .padding(.bottom, 16)
    }

    private var activeCard: some View {
        let count = data.activeRentals.count
        return VStack(alignment: .leading, spacing: 0) {
            Text("Currently Active")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white.opacity(0.8))
                .padding(.bottom, 4)
            Text("\(count) rental\(count == 1 ? "" : "s")")
                .font(.system(size: 28, weight: .black))
                .tracking(-0.5)
                .foregroundColor(.white)
                .padding(.bottom, 2)
            Text("in progress right now")
                .font(.system(size: 12))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Theme.gradient)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        .shadow(color: Theme.blue.opacity(0.3), radius: 7, x: 0, y: 4)
    }

    // MARK: Actions

    private func binding(_ keyPath: WritableKeyPath<Profile, String>) -> Binding<String> {
        Binding(
            get: { form[keyPath: keyPath] },
            set: { form[keyPath: keyPath] = $0 }
        )
    }

    private func startEditing() {
        form = data.profile
        editing = true
    }

    private func cancel() {
        form = data.profile
        editing = false
        showEmojiPicker = false
    }

    private func save() {
        var saved = form
        if saved.name.trimmingCharacters(in: .whitespaces).isEmpty {
            saved.name = data.profile.name
        } else {
            saved.name = saved.name.trimmingCharacters(in: .whitespaces)
        }
        data.profile = saved
        form = saved
        editing = false
        showEmojiPicker = false
    }
}
