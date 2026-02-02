import SwiftUI

struct TransactionFormView: View {
    @Binding var isPresented: Bool
    let existing: Transaction?
    let onSave: (Transaction) -> Void

    @State private var title: String
    @State private var amountText: String
    @State private var date: Date
    @State private var type: TransactionType
    @State private var category: Category
    @State private var note: String
    @State private var isRecurring: Bool
    @State private var validationMessage: String?

    init(isPresented: Binding<Bool>, existing: Transaction? = nil, onSave: @escaping (Transaction) -> Void) {
        _isPresented = isPresented
        self.existing = existing
        self.onSave = onSave
        _title = State(initialValue: existing?.title ?? "")
        _amountText = State(initialValue: existing.map { String(format: "%.2f", $0.amount) } ?? "")
        _date = State(initialValue: existing?.date ?? Date())
        _type = State(initialValue: existing?.type ?? .expense)
        _category = State(initialValue: existing?.category ?? .other)
        _note = State(initialValue: existing?.note ?? "")
        _isRecurring = State(initialValue: existing?.isRecurring ?? false)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Amount", text: $amountText)
                        .keyboardType(.decimalPad)
                    DatePicker("Date", selection: $date, displayedComponents: [.date])

                    Picker("Type", selection: $type) {
                        ForEach(TransactionType.allCases) { item in
                            Text(item.title).tag(item)
                        }
                    }

                    Picker("Category", selection: $category) {
                        ForEach(Category.allCases) { item in
                            Text(item.title).tag(item)
                        }
                    }
                }

                Section("Notes") {
                    TextEditor(text: $note)
                        .frame(minHeight: 120)
                }

                Section {
                    Toggle("Recurring", isOn: $isRecurring)
                }

                if let validationMessage {
                    Section {
                        Text(validationMessage)
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.expense)
                    }
                }

                Section {
                    Button("Save") {
                        save()
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .navigationTitle(existing == nil ? "New Transaction" : "Edit Transaction")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                }
            }
        }
    }

    private func save() {
        let normalizedAmount = Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
        let data = TransactionFormData(title: title, amount: normalizedAmount)

        if let error = data.validate() {
            validationMessage = error
            return
        }

        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let transaction = Transaction(
            id: existing?.id ?? UUID().uuidString,
            title: trimmedTitle,
            amount: normalizedAmount,
            date: date,
            type: type,
            category: category,
            note: note,
            isRecurring: isRecurring,
            createdAt: existing?.createdAt ?? Date()
        )

        onSave(transaction)
        isPresented = false
    }
}

protocol Validatable {
    func validate() -> String?
}

struct TransactionFormData: Validatable {
    let title: String
    let amount: Double

    func validate() -> String? {
        if title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Title is required."
        }
        if amount <= 0 {
            return "Amount must be greater than zero."
        }
        return nil
    }
}

#Preview {
    TransactionFormView(isPresented: .constant(true)) { _ in }
}
