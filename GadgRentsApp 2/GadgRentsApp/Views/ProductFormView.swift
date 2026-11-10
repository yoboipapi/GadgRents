import SwiftUI

/// Shared screen for "Add Item" and "Edit Item" (identical layout in the prototype).
struct ProductFormView: View {

    enum Mode {
        case add
        case edit(Product)
    }

    let mode: Mode
    let onSave: (Product) -> Void
    let onCancel: () -> Void

    @State private var name: String
    @State private var category: String
    @State private var price: String
    @State private var rating: String
    @State private var descriptionText: String

    @State private var nameError: String?
    @State private var priceError: String?
    @State private var ratingError: String?

    init(mode: Mode, onSave: @escaping (Product) -> Void, onCancel: @escaping () -> Void) {
        self.mode = mode
        self.onSave = onSave
        self.onCancel = onCancel

        switch mode {
        case .add:
            _name = State(initialValue: "")
            _category = State(initialValue: ProductCategory.all[0])
            _price = State(initialValue: "")
            _rating = State(initialValue: "4.5")
            _descriptionText = State(initialValue: "")
        case .edit(let p):
            _name = State(initialValue: p.name)
            _category = State(initialValue: p.category)
            _price = State(initialValue: String(p.pricePerDay))
            _rating = State(initialValue: String(p.rating))
            _descriptionText = State(initialValue: p.description)
        }
    }

    private var isEdit: Bool {
        if case .edit = mode { return true }
        return false
    }

    private var priceValue: Int? {
        guard let v = Double(price), v > 0 else { return nil }
        return Int(v.rounded())
    }

    // MARK: Body

    var body: some View {
        VStack(spacing: 0) {
            NavBar(
                title: isEdit ? "Edit Item" : "Add Item",
                onBack: onCancel,
                rightLabel: "Save",
                rightColor: Theme.green,
                onRight: save
            )

            ScrollView {
                VStack(spacing: 14) {
                    iconPreview
                    infoCard
                    if isEdit {
                        summaryCard(title: "SUMMARY", showPrice: true)
                    } else if !name.isEmpty && !price.isEmpty {
                        summaryCard(title: "PREVIEW", showPrice: true)
                    }
                    PrimaryButton(title: isEdit ? "Save Item Details" : "Add to Inventory", action: save)
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
    }

    // MARK: Pieces

    private var iconPreview: some View {
        ZStack {
            Theme.softGradient
            Text(ProductCategory.icon(category)).font(.system(size: 52))
        }
        .frame(height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
    }

    private var infoCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionTitle(text: "📦 Item Info").padding(.bottom, 2)

            FormField(
                label: "Item Name *", text: $name,
                placeholder: isEdit ? "e.g. iPhone 16 Pro Max" : "e.g. Sony A7 IV",
                error: nameError
            )
            .onChange(of: name) { _, _ in nameError = nil }

            OptionMenu(
                label: "Category",
                options: ProductCategory.all.map {
                    MenuOption(id: $0, title: "\(ProductCategory.icon($0)) \($0)")
                },
                selection: $category
            )

            FormField(label: "Description", text: $descriptionText, placeholder: "Short description of the item...", multiline: true)

            HStack(alignment: .top, spacing: 10) {
                FormField(
                    label: "Price / Day (₱) *", text: $price, placeholder: "1500",
                    error: priceError, keyboard: .numberPad
                )
                .onChange(of: price) { _, _ in priceError = nil }

                FormField(
                    label: "Rating (0–5)", text: $rating, placeholder: isEdit ? "4.8" : "4.5",
                    error: ratingError, keyboard: .decimalPad
                )
                .onChange(of: rating) { _, _ in ratingError = nil }
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }

    private func summaryCard(title: String, showPrice: Bool) -> some View {
        SummaryCard {
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .tracking(0.4)
                .foregroundColor(.white.opacity(0.7))
                .padding(.bottom, isEdit ? 8 : 6)

            Text(name.isEmpty ? "—" : name)
                .font(.system(size: 18, weight: .black))
                .tracking(-0.3)
                .foregroundColor(.white)
                .padding(.bottom, 2)

            Text("\(ProductCategory.icon(category)) \(category) · ★ \(rating)")
                .font(.system(size: 13))
                .foregroundColor(.white.opacity(0.75))
                .padding(.bottom, 10)

            Rectangle().fill(Color.white.opacity(0.2)).frame(height: 0.5).padding(.vertical, 10)

            HStack {
                Text("Rental price")
                    .font(.system(size: 14))
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                HStack(alignment: .lastTextBaseline, spacing: 0) {
                    Text(Double(price).map { peso(Int($0.rounded())) } ?? "₱—")
                        .font(.system(size: 22, weight: .black))
                        .tracking(-0.5)
                    Text("/day")
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(.white)
            }
        }
        .padding(.bottom, 6)
    }

    // MARK: Save

    private func validate() -> Bool {
        var ok = true

        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = "Required"; ok = false
        }
        if priceValue == nil {
            priceError = "Enter a valid price"; ok = false
        }
        if let r = Double(rating), r >= 0, r <= 5 {
            // valid
        } else {
            ratingError = isEdit ? "Rating must be 0–5" : "Must be 0–5"; ok = false
        }
        return ok
    }

    private func save() {
        guard validate(), let priceInt = priceValue, let ratingValue = Double(rating) else { return }

        let roundedRating = (ratingValue * 10).rounded() / 10
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedDescription = descriptionText.trimmingCharacters(in: .whitespaces)

        switch mode {
        case .add:
            onSave(
                Product(
                    id: String(Int(Date().timeIntervalSince1970 * 1000)),
                    name: trimmedName,
                    category: category,
                    pricePerDay: priceInt,
                    available: true,
                    totalRentals: 0,
                    rating: roundedRating,
                    description: trimmedDescription
                )
            )
        case .edit(let original):
            var updated = original
            updated.name = trimmedName
            updated.category = category
            updated.pricePerDay = priceInt
            updated.rating = roundedRating
            updated.description = trimmedDescription
            onSave(updated)
        }
    }
}
