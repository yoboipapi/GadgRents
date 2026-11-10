import SwiftUI

struct AddRentalView: View {

    @EnvironmentObject var data: AppData

    let onSave: (Rental) -> Void
    let onCancel: () -> Void

    @State private var name = ""
    @State private var phone = ""
    @State private var email = ""
    @State private var address = ""
    @State private var productId = ""
    @State private var startDate = DateUtil.today
    @State private var endDate = DateUtil.addDays(DateUtil.today, 1)
    @State private var note = ""

    @State private var nameError: String?
    @State private var phoneError: String?
    @State private var emailError: String?
    @State private var endError: String?

    private var selected: Product? {
        data.products.first { $0.id == productId } ?? data.products.first
    }

    private var days: Int { DateUtil.daysBetween(startDate, endDate) }
    private var total: Int { (selected?.pricePerDay ?? 0) * days }

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: "Add Customer Rental",
                onBack: onCancel,
                rightLabel: "Save",
                onRight: save
            )

            ScrollView {
                VStack(spacing: 14) {
                    customerCard
                    rentalCard
                    if let sel = selected { costCard(sel) }
                    PrimaryButton(title: "Save Rental", action: save)
                        .padding(.top, 6)
                }
                .padding(.horizontal, 16)
                .padding(.top, 16)
                .padding(.bottom, 40)
            }
            .scrollIndicators(.hidden)
            .scrollDismissesKeyboard(.interactively)
        }
        .background(Theme.background.ignoresSafeArea())
        .onAppear {
            if productId.isEmpty { productId = data.products.first?.id ?? "" }
        }
    }

    // MARK: Cards

    private var customerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(text: "👤 Customer Info").padding(.bottom, 2)

            FormField(label: "Full Name *", text: $name, placeholder: "e.g. Juan dela Cruz", error: nameError)
                .onChange(of: name) { _, _ in nameError = nil }

            FormField(label: "Phone Number *", text: $phone, placeholder: "+63 9xx xxx xxxx", error: phoneError, keyboard: .phonePad)
                .onChange(of: phone) { _, _ in phoneError = nil }

            FormField(label: "Email Address *", text: $email, placeholder: "email@example.com", error: emailError, keyboard: .emailAddress)
                .onChange(of: email) { _, _ in emailError = nil }

            FormField(label: "Address", text: $address, placeholder: "City, Province")
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    private var rentalCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(text: "📦 Rental Details").padding(.bottom, 2)

            OptionMenu(
                label: "Item *",
                options: data.products.map {
                    MenuOption(id: $0.id, title: "\($0.name) — \(peso($0.pricePerDay))/day")
                },
                selection: $productId
            )

            HStack(alignment: .top, spacing: 10) {
                DateField(label: "Start Date *", date: $startDate, range: DateUtil.today...)
                    .onChange(of: startDate) { _, newValue in
                        if newValue >= endDate { endDate = DateUtil.addDays(newValue, 1) }
                    }

                DateField(
                    label: "End Date *", date: $endDate,
                    range: DateUtil.addDays(startDate, 1)...,
                    error: endError
                )
                .onChange(of: endDate) { _, _ in endError = nil }
            }

            FormField(label: "Notes", text: $note, placeholder: "Any special instructions...", multiline: true)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    private func costCard(_ sel: Product) -> some View {
        SummaryCard {
            Text("COST SUMMARY")
                .font(.system(size: 12, weight: .bold))
                .tracking(0.4)
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, 8)

            Text("\(peso(sel.pricePerDay))/day × \(days) day\(days == 1 ? "" : "s")")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.75))
                .padding(.bottom, 8)

            Rectangle().fill(Color.white.opacity(0.2)).frame(height: 0.5).padding(.vertical, 10)

            HStack {
                Text("Total").font(.system(size: 15, weight: .bold)).foregroundColor(.white)
                Spacer()
                Text(peso(total))
                    .font(.system(size: 24, weight: .black))
                    .tracking(-0.5)
                    .foregroundColor(.white)
            }
        }
        .padding(.bottom, 6)
    }

    // MARK: Save

    private func validate() -> Bool {
        var ok = true
        if name.trimmingCharacters(in: .whitespaces).isEmpty { nameError = "Required"; ok = false }
        if phone.trimmingCharacters(in: .whitespaces).isEmpty { phoneError = "Required"; ok = false }
        if email.trimmingCharacters(in: .whitespaces).isEmpty { emailError = "Required"; ok = false }
        if endDate <= startDate { endError = "Must be after start"; ok = false }
        return ok
    }

    private func save() {
        guard validate(), let sel = selected else { return }

        let rental = Rental(
            id: String(Int(Date().timeIntervalSince1970 * 1000)),
            productId: sel.id,
            productName: sel.name,
            category: sel.category,
            customerName: name.trimmingCharacters(in: .whitespaces),
            customerPhone: phone.trimmingCharacters(in: .whitespaces),
            customerEmail: email.trimmingCharacters(in: .whitespaces),
            customerAddress: address.trimmingCharacters(in: .whitespaces),
            pricePerDay: sel.pricePerDay,
            startDate: startDate,
            endDate: endDate,
            quantity: 1,
            totalCost: total,
            status: DateUtil.cal.startOfDay(for: startDate) > DateUtil.today ? .upcoming : .active,
            note: note.trimmingCharacters(in: .whitespaces),
            returned: false
        )
        onSave(rental)
    }
}
