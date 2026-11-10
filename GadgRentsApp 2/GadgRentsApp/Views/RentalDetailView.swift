import SwiftUI

struct RentalDetailView: View {

    @EnvironmentObject var data: AppData

    let rental: Rental
    let onBack: () -> Void

    @State private var editing = false
    @State private var showDialog = false

    @State private var customerName: String
    @State private var customerPhone: String
    @State private var customerEmail: String
    @State private var customerAddress: String
    @State private var productId: String
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var note: String

    init(rental: Rental, onBack: @escaping () -> Void) {
        self.rental = rental
        self.onBack = onBack
        _customerName = State(initialValue: rental.customerName)
        _customerPhone = State(initialValue: rental.customerPhone)
        _customerEmail = State(initialValue: rental.customerEmail)
        _customerAddress = State(initialValue: rental.customerAddress)
        _productId = State(initialValue: rental.productId)
        _startDate = State(initialValue: rental.startDate)
        _endDate = State(initialValue: rental.endDate)
        _note = State(initialValue: rental.note)
    }

    // MARK: Derived

    private var selProduct: Product {
        data.product(id: productId)
            ?? data.product(id: rental.productId)
            ?? Product(
                id: rental.productId, name: rental.productName, category: rental.category,
                pricePerDay: rental.pricePerDay, available: true, totalRentals: 0, rating: 0
            )
    }

    private var days: Int { DateUtil.daysBetween(startDate, endDate) }
    private var computedTotal: Int { selProduct.pricePerDay * days }
    private var overdueDays: Int { abs(DateUtil.daysLeft(rental.endDate)) }

    // MARK: Body

    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                NavBar(
                    title: "Rental Details",
                    backLabel: editing ? "Cancel" : "Back",
                    showChevron: !editing,
                    onBack: { editing ? cancelEditing() : onBack() },
                    rightLabel: editing ? "Save" : "Edit",
                    rightColor: editing ? Theme.green : Theme.blue,
                    onRight: { editing ? save() : startEditing() }
                )

                if editing { EditingBanner(text: "Editing mode — tap Save when done") }

                ScrollView {
                    VStack(spacing: 12) {
                        customerSection
                        itemSection
                        breakdownSection
                        if rental.status == .overdue && !editing { overdueWarning }
                        notesSection
                        if !editing { timelineSection }
                        actions
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 32)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
            .background(Theme.background.ignoresSafeArea())

            if showDialog { confirmReturnDialog }
        }
        .animation(.easeInOut(duration: 0.2), value: showDialog)
    }

    // MARK: Customer

    private var customerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("CUSTOMER")
                .font(.system(size: 11, weight: .bold))
                .tracking(0.5)
                .foregroundColor(Theme.gray)

            HStack(spacing: 14) {
                AvatarEmoji(name: rental.customerName, size: 52)

                VStack(alignment: .leading, spacing: 2) {
                    if editing {
                        FormField(label: "", text: $customerName, placeholder: "Full Name", style: .inline)
                    } else {
                        Text(rental.customerName)
                            .font(.system(size: 18, weight: .heavy))
                            .foregroundColor(.black)
                        Text(rental.customerPhone)
                            .font(.system(size: 12)).foregroundColor(Theme.gray)
                        if !rental.customerEmail.isEmpty {
                            Text(rental.customerEmail)
                                .font(.system(size: 12)).foregroundColor(Theme.gray)
                        }
                        if !rental.customerAddress.isEmpty {
                            Text("📍 \(rental.customerAddress)")
                                .font(.system(size: 12)).foregroundColor(Theme.gray)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if !editing, let url = URL(string: "tel:" + rental.customerPhone.filter { $0.isNumber || $0 == "+" }) {
                    Link(destination: url) {
                        Text("📞")
                            .font(.system(size: 18))
                            .frame(width: 38, height: 38)
                            .background(Color(hex: 0xE8F5E9))
                            .clipShape(Circle())
                    }
                }
            }

            if editing {
                HStack(alignment: .top, spacing: 8) {
                    FormField(label: "Phone", text: $customerPhone, placeholder: "+63 9xx", keyboard: .phonePad, style: .inline)
                    FormField(label: "Email", text: $customerEmail, placeholder: "email@...", keyboard: .emailAddress, style: .inline)
                }
                FormField(label: "Address", text: $customerAddress, placeholder: "City, Province", style: .inline)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    // MARK: Item

    private var itemSection: some View {
        VStack(spacing: 0) {
            ZStack {
                Theme.softGradient
                Text(ProductCategory.icon(selProduct.category)).font(.system(size: 48))
            }
            .frame(height: 90)

            VStack(alignment: .leading, spacing: 0) {
                if editing {
                    OptionMenu(
                        label: "Change Item",
                        options: data.products.map {
                            MenuOption(id: $0.id, title: "\($0.name) — \(peso($0.pricePerDay))/day")
                        },
                        selection: $productId,
                        style: .inline
                    )
                } else {
                    Text("\(ProductCategory.icon(rental.category)) \(rental.category)".uppercased())
                        .font(.system(size: 11, weight: .bold))
                        .tracking(0.4)
                        .foregroundColor(Theme.blue)
                    Text(rental.productName)
                        .font(.system(size: 17, weight: .heavy))
                        .foregroundColor(.black)
                        .padding(.top, 3).padding(.bottom, 6)
                    StatusPill(status: rental.status)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .card()
    }

    // MARK: Breakdown

    private struct BreakdownRow: Identifiable {
        let id: String
        let icon: String
        let value: String
        var bold = false
        var highlight = false
    }

    private var breakdownRows: [BreakdownRow] {
        [
            BreakdownRow(id: "Start Date", icon: "📅", value: DateUtil.fmt(rental.startDate)),
            BreakdownRow(id: "Return Date", icon: "🗓", value: DateUtil.fmt(rental.endDate)),
            BreakdownRow(id: "Duration", icon: "⏱", value: "\(days) day\(days == 1 ? "" : "s")"),
            BreakdownRow(id: "Daily Rate", icon: "💵", value: peso(rental.pricePerDay) + "/day"),
            BreakdownRow(id: "Total Cost", icon: "💰", value: peso(computedTotal), bold: true, highlight: true)
        ]
    }

    private var breakdownSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("RENTAL BREAKDOWN")
                .font(.system(size: 11, weight: .bold))
                .tracking(0.5)
                .foregroundColor(Theme.gray)
                .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 4)

            if editing {
                VStack(spacing: 10) {
                    HStack(alignment: .top, spacing: 10) {
                        DateField(label: "Start Date", date: $startDate, range: Date.distantPast..., style: .inline)
                            .onChange(of: startDate) { _, newValue in
                                if newValue >= endDate { endDate = DateUtil.addDays(newValue, 1) }
                            }
                        DateField(label: "End Date", date: $endDate, range: DateUtil.addDays(startDate, 1)..., style: .inline)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(peso(selProduct.pricePerDay))/day × \(days) day\(days == 1 ? "" : "s")")
                            .font(.system(size: 12)).foregroundColor(Theme.gray)
                        HStack {
                            Text("Updated Total")
                                .font(.system(size: 14, weight: .bold)).foregroundColor(.black)
                            Spacer()
                            Text(peso(computedTotal))
                                .font(.system(size: 20, weight: .black)).foregroundColor(Theme.blue)
                        }
                    }
                    .padding(.horizontal, 14).padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Theme.editFill)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }
                .padding(.horizontal, 16).padding(.top, 12).padding(.bottom, 16)
            } else {
                let rows = breakdownRows
                ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                    HStack(spacing: 10) {
                        Text(row.icon).font(.system(size: 16)).frame(width: 22)
                        Text(row.id).font(.system(size: 14)).foregroundColor(Theme.gray)
                        Spacer()
                        Text(row.value)
                            .font(.system(size: row.highlight ? 16 : 14, weight: row.bold ? .black : .semibold))
                            .foregroundColor(row.highlight ? Theme.blue : .black)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 11)
                    .background(row.highlight ? Theme.editFill : Color.clear)

                    if index < rows.count - 1 {
                        Rectangle().fill(Theme.background).frame(height: 0.5).padding(.horizontal, 16)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    // MARK: Overdue / Notes / Timeline

    private var overdueWarning: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("⚠️ Overdue by \(overdueDays) day\(overdueDays == 1 ? "" : "s")")
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(Color(hex: 0xB71C1C))
            Text("Contact customer to arrange return.")
                .font(.system(size: 12))
                .foregroundColor(Color(hex: 0xC62828))
        }
        .padding(.horizontal, 14).padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: 0xFFF5F5))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(Color(hex: 0xFFCDD2), lineWidth: 1)
        )
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("NOTES")
                .font(.system(size: 11, weight: .bold))
                .tracking(0.5)
                .foregroundColor(Theme.gray)

            if editing {
                FormField(label: "", text: $note, placeholder: "Special instructions...", multiline: true, style: .inline)
            } else {
                Text(note.isEmpty ? "No notes added." : note)
                    .font(.system(size: 14))
                    .foregroundColor(note.isEmpty ? Theme.lightGray : Theme.secondaryLabel)
                    .lineSpacing(3)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
        .padding(.bottom, 4)
    }

    private struct TimelineEvent: Identifiable {
        let id: Int
        let dot: Color
        let label: String
        let date: String
    }

    private var timelineEvents: [TimelineEvent] {
        var events = [
            TimelineEvent(id: 0, dot: Theme.blue, label: "Rented by \(rental.customerName)", date: DateUtil.fmt(rental.startDate)),
            TimelineEvent(id: 1, dot: rental.status == .overdue ? Theme.red : Theme.chevron, label: "Return due", date: DateUtil.fmt(rental.endDate))
        ]
        if rental.returned {
            events.append(TimelineEvent(id: 2, dot: Theme.green, label: "Returned ✓", date: "Completed"))
        }
        return events
    }

    private var timelineSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TIMELINE")
                .font(.system(size: 11, weight: .bold))
                .tracking(0.5)
                .foregroundColor(Theme.gray)

            let events = timelineEvents
            VStack(alignment: .leading, spacing: 0) {
                ForEach(events) { ev in
                    HStack(alignment: .top, spacing: 10) {
                        VStack(spacing: 2) {
                            Circle().fill(ev.dot).frame(width: 10, height: 10).padding(.top, 4)
                            if ev.id < events.count - 1 {
                                Rectangle().fill(Theme.fieldBorder).frame(width: 1.5)
                            }
                        }
                        .frame(width: 14)

                        VStack(alignment: .leading, spacing: 1) {
                            Text(ev.label)
                                .font(.system(size: 13, weight: .semibold)).foregroundColor(.black)
                            Text(ev.date)
                                .font(.system(size: 11)).foregroundColor(Theme.gray)
                        }
                        .padding(.bottom, ev.id < events.count - 1 ? 12 : 0)
                    }
                }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
        .padding(.bottom, 4)
    }

    // MARK: Actions

    @ViewBuilder
    private var actions: some View {
        if editing {
            PrimaryButton(title: "✓ Save Changes", color: Theme.green, action: save)
        } else if rental.returned {
            Text("✓ Item has been returned")
                .font(.system(size: 15, weight: .bold))
                .foregroundColor(Theme.green)
                .frame(maxWidth: .infinity)
                .padding(12)
        } else if rental.status != .upcoming {
            PrimaryButton(title: "✓ Mark as Returned", color: Theme.green) { showDialog = true }
        }
    }

    // MARK: Confirm dialog

    private var confirmReturnDialog: some View {
        BottomSheetDialog {
            Text("Confirm Return")
                .font(.system(size: 19, weight: .heavy))
                .foregroundColor(.black)
                .padding(.bottom, 6)

            (Text("Mark ").foregroundColor(Theme.gray)
             + Text(rental.productName).fontWeight(.semibold).foregroundColor(.black)
             + Text(" as returned from ").foregroundColor(Theme.gray)
             + Text(rental.customerName).fontWeight(.semibold).foregroundColor(.black)
             + Text("?").foregroundColor(Theme.gray))
                .font(.system(size: 14))
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .padding(.bottom, 20)

            SheetButtons(
                cancelTitle: "Cancel", confirmTitle: "Confirm", confirmColor: Theme.green,
                onCancel: { showDialog = false },
                onConfirm: {
                    showDialog = false
                    data.markReturned(rental.id)
                }
            )
        }
    }

    // MARK: Edit actions

    private func startEditing() { editing = true }

    private func resetForm() {
        customerName = rental.customerName
        customerPhone = rental.customerPhone
        customerEmail = rental.customerEmail
        customerAddress = rental.customerAddress
        productId = rental.productId
        startDate = rental.startDate
        endDate = rental.endDate
        note = rental.note
    }

    private func cancelEditing() {
        resetForm()
        editing = false
    }

    private func save() {
        let today = DateUtil.today
        let left = DateUtil.daysLeft(endDate)

        let newStatus: RentalStatus
        if rental.returned {
            newStatus = .completed
        } else if DateUtil.cal.startOfDay(for: startDate) > today {
            newStatus = .upcoming
        } else if left < 0 {
            newStatus = .overdue
        } else {
            newStatus = .active
        }

        var updated = rental
        updated.productId = selProduct.id
        updated.productName = selProduct.name
        updated.category = selProduct.category
        updated.customerName = customerName.trimmingCharacters(in: .whitespaces)
        updated.customerPhone = customerPhone.trimmingCharacters(in: .whitespaces)
        updated.customerEmail = customerEmail.trimmingCharacters(in: .whitespaces)
        updated.customerAddress = customerAddress.trimmingCharacters(in: .whitespaces)
        updated.pricePerDay = selProduct.pricePerDay
        updated.startDate = startDate
        updated.endDate = endDate
        updated.quantity = 1
        updated.totalCost = computedTotal
        updated.status = newStatus
        updated.note = note.trimmingCharacters(in: .whitespaces)

        data.updateRental(updated)
        editing = false
    }
}
