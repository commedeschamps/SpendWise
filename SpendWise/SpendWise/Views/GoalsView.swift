import SwiftUI

struct GoalsView: View {
    @ObservedObject var viewModel: GoalsViewModel
    @AppStorage("currencyCode") private var currencyCode = "KZT"

    @State private var showingAddForm = false

    var body: some View {
        List {
            Section {
                summaryCard
                    .padding(.top, Theme.compactSpacing)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: Theme.spacing, bottom: 0, trailing: Theme.spacing))
            }

            if viewModel.sortedGoals.isEmpty {
                Section {
                    VStack(spacing: Theme.compactSpacing) {
                        Image(systemName: "target")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(Theme.textSecondary)
                        Text("No goals yet")
                            .font(Theme.subtitleFont)
                            .foregroundStyle(Theme.textPrimary)
                        Text("Add your first target to start tracking progress.")
                            .font(Theme.bodyFont)
                            .foregroundStyle(Theme.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, Theme.spacing)
                    .cardStyle(background: Theme.softCardGradient)
                    .padding(.horizontal, Theme.spacing)
                    .listRowBackground(Color.clear)
                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                }
            } else {
                Section(header: Text("Goals")) {
                    ForEach(viewModel.sortedGoals) { goal in
                        NavigationLink {
                            GoalDetailView(goalId: goal.id, viewModel: viewModel)
                        } label: {
                            GoalRowView(goal: goal, projection: viewModel.projection(for: goal), currencyCode: currencyCode)
                                .padding(.horizontal, 10)
                                .background(Theme.softCardGradient, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                                        .stroke(Theme.separator.opacity(0.2), lineWidth: 1)
                                )
                        }
                        .listRowBackground(Color.clear)
                        .listRowInsets(EdgeInsets(top: 6, leading: Theme.spacing, bottom: 6, trailing: Theme.spacing))
                        .listRowSeparator(.hidden)
                    }
                    .onDelete(perform: deleteGoals)
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(Color.clear)
        .background {
            AppBackgroundView()
        }
        .navigationTitle("Goals")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingAddForm = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 30)
                        .background(Theme.accent, in: Circle())
                        .shadow(color: Theme.accent.opacity(0.35), radius: 6, x: 0, y: 3)
                }
            }
        }
        .sheet(isPresented: $showingAddForm) {
            GoalFormView(isPresented: $showingAddForm) { draft in
                viewModel.addGoal(
                    title: draft.title,
                    targetAmount: draft.targetAmount,
                    savedAmount: draft.savedAmount,
                    deadline: draft.deadline,
                    note: draft.note
                )
            }
        }
    }

    private var summaryCard: some View {
        VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            Text("Savings Goals")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)

            Text(Currency.format(viewModel.totalSavedAmount, code: currencyCode))
                .font(Theme.heroAmountFont)
                .foregroundStyle(Theme.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            Text("of \(Currency.format(viewModel.totalTargetAmount, code: currencyCode)) target")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)

            ProgressBarView(progress: viewModel.overallProgress)
                .frame(height: 10)
        }
        .cardStyle(background: Theme.heroGradient)
    }

    private func deleteGoals(_ offsets: IndexSet) {
        let items = viewModel.sortedGoals
        for index in offsets {
            viewModel.deleteGoal(id: items[index].id)
        }
    }
}

private struct GoalRowView: View {
    let goal: FinancialGoal
    let projection: GoalProjection
    let currencyCode: String

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            HStack(alignment: .firstTextBaseline) {
                Text(goal.title)
                    .font(Theme.subtitleFont)
                    .foregroundStyle(Theme.textPrimary)
                    .lineLimit(1)

                Spacer()

                Text("\(Int(goal.progress * 100))%")
                    .font(Theme.captionFont.weight(.semibold))
                    .foregroundStyle(goal.isCompleted ? Theme.income : Theme.accent)
                    .padding(.vertical, 3)
                    .padding(.horizontal, 7)
                    .background((goal.isCompleted ? Theme.income : Theme.accent).opacity(0.14))
                    .clipShape(Capsule())
            }

            ProgressBarView(progress: goal.progress)
                .frame(height: 8)

            HStack {
                Text("\(Currency.format(goal.savedAmount, code: currencyCode)) / \(Currency.format(goal.targetAmount, code: currencyCode))")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
                Spacer()
                Text(shortDate(goal.deadline))
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
            }

            Text(projection.message)
                .font(Theme.captionFont)
                .foregroundStyle(projection.isAtRisk ? Theme.expense : Theme.income)
        }
        .padding(.vertical, 8)
    }

    private func shortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("d MMM yyyy")
        return formatter.string(from: date)
    }
}

private struct GoalDetailView: View {
    let goalId: String
    @ObservedObject var viewModel: GoalsViewModel
    @AppStorage("currencyCode") private var currencyCode = "KZT"

    @State private var contributionText = ""
    @State private var contributionError: String?
    @State private var showingEditForm = false

    var body: some View {
        Group {
            if let goal = viewModel.goal(withId: goalId) {
                ScrollView {
                    VStack(alignment: .leading, spacing: Theme.spacing) {
                        detailHeader(goal: goal)
                        contributionCard(goal: goal)
                        notesCard(goal: goal)
                    }
                    .padding(Theme.spacing)
                }
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            showingEditForm = true
                        } label: {
                            Label("Edit", systemImage: "square.and.pencil")
                                .font(Theme.captionFont)
                        }
                    }
                }
                .sheet(isPresented: $showingEditForm) {
                    GoalFormView(isPresented: $showingEditForm, existing: goal) { draft in
                        var updated = goal
                        updated.title = draft.title
                        updated.targetAmount = draft.targetAmount
                        updated.savedAmount = draft.savedAmount
                        updated.deadline = draft.deadline
                        updated.note = draft.note
                        viewModel.updateGoal(updated)
                    }
                }
            } else {
                Text("Goal not found.")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .background {
            AppBackgroundView()
        }
        .navigationTitle("Goal Detail")
    }

    private func detailHeader(goal: FinancialGoal) -> some View {
        let projection = viewModel.projection(for: goal)
        return VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            Text(goal.title)
                .font(Theme.titleFont)
                .foregroundStyle(Theme.textPrimary)

            Text("\(Currency.format(goal.savedAmount, code: currencyCode)) / \(Currency.format(goal.targetAmount, code: currencyCode))")
                .font(Theme.subtitleFont)
                .foregroundStyle(Theme.accent)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            ProgressBarView(progress: goal.progress)
                .frame(height: 10)

            HStack {
                Text("Deadline: \(dateText(goal.deadline))")
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.textSecondary)
                Spacer()
                Text("\(Int(goal.progress * 100))%")
                    .font(Theme.captionFont.weight(.semibold))
                    .foregroundStyle(goal.isCompleted ? Theme.income : Theme.accent)
            }

            Text(projection.message)
                .font(Theme.captionFont)
                .foregroundStyle(projection.isAtRisk ? Theme.expense : Theme.income)
        }
        .cardStyle(background: Theme.heroGradient)
    }

    private func contributionCard(goal: FinancialGoal) -> some View {
        VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            Text("Add Contribution")
                .font(Theme.subtitleFont)
                .foregroundStyle(Theme.textPrimary)

            HStack(spacing: Theme.compactSpacing) {
                TextField("Amount", text: $contributionText)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(.roundedBorder)

                Button("Add") {
                    addContribution(to: goal)
                }
                .buttonStyle(.borderedProminent)
                .tint(Theme.accent)
            }

            if let contributionError {
                Text(contributionError)
                    .font(Theme.captionFont)
                    .foregroundStyle(Theme.expense)
            }

            Text("Remaining: \(Currency.format(goal.remainingAmount, code: currencyCode))")
                .font(Theme.captionFont)
                .foregroundStyle(Theme.textSecondary)
        }
        .cardStyle()
    }

    private func notesCard(goal: FinancialGoal) -> some View {
        VStack(alignment: .leading, spacing: Theme.compactSpacing) {
            Text("Notes")
                .font(Theme.subtitleFont)
                .foregroundStyle(Theme.textPrimary)

            if goal.note.isEmpty {
                Text("No notes for this goal.")
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
            } else {
                Text(goal.note)
                    .font(Theme.bodyFont)
                    .foregroundStyle(Theme.textSecondary)
            }
        }
        .cardStyle()
    }

    private func addContribution(to goal: FinancialGoal) {
        let normalized = contributionText.replacingOccurrences(of: ",", with: ".")
        guard let amount = Double(normalized), amount > 0 else {
            contributionError = "Enter a valid positive amount."
            return
        }

        viewModel.contribute(to: goal.id, amount: amount)
        contributionText = ""
        contributionError = nil
    }

    private func dateText(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

private struct GoalDraft {
    let title: String
    let targetAmount: Double
    let savedAmount: Double
    let deadline: Date
    let note: String
}

private struct GoalFormView: View {
    @Binding var isPresented: Bool
    let existing: FinancialGoal?
    let onSave: (GoalDraft) -> Void

    @State private var title: String
    @State private var targetAmountText: String
    @State private var savedAmountText: String
    @State private var deadline: Date
    @State private var note: String
    @State private var validationMessage: String?

    init(
        isPresented: Binding<Bool>,
        existing: FinancialGoal? = nil,
        onSave: @escaping (GoalDraft) -> Void
    ) {
        _isPresented = isPresented
        self.existing = existing
        self.onSave = onSave
        _title = State(initialValue: existing?.title ?? "")
        _targetAmountText = State(initialValue: existing.map { String(format: "%.2f", $0.targetAmount) } ?? "")
        _savedAmountText = State(initialValue: existing.map { String(format: "%.2f", $0.savedAmount) } ?? "0")
        _deadline = State(initialValue: existing?.deadline ?? Date())
        _note = State(initialValue: existing?.note ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text("Goal")) {
                    TextField("Title", text: $title)
                    TextField("Target Amount", text: $targetAmountText)
                        .keyboardType(.decimalPad)
                    TextField("Already Saved", text: $savedAmountText)
                        .keyboardType(.decimalPad)
                    DatePicker("Deadline", selection: $deadline, displayedComponents: [.date])
                }

                Section("Notes") {
                    TextEditor(text: $note)
                        .frame(minHeight: 100)
                }

                if let validationMessage {
                    Section {
                        Text(validationMessage)
                            .font(Theme.captionFont)
                            .foregroundStyle(Theme.expense)
                    }
                }

                Section {
                    Button("Save") {
                        save()
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                }
            }
            .navigationTitle(existing == nil ? "New Goal" : "Edit Goal")
            .scrollContentBackground(.hidden)
            .background {
                AppBackgroundView()
            }
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
        let normalizedTarget = targetAmountText.replacingOccurrences(of: ",", with: ".")
        let normalizedSaved = savedAmountText.replacingOccurrences(of: ",", with: ".")
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let targetAmount = Double(normalizedTarget) ?? 0
        let savedAmount = Double(normalizedSaved) ?? 0

        guard !trimmedTitle.isEmpty else {
            validationMessage = "Title is required."
            return
        }
        guard targetAmount > 0 else {
            validationMessage = "Target amount must be greater than zero."
            return
        }
        guard savedAmount >= 0 else {
            validationMessage = "Saved amount cannot be negative."
            return
        }

        onSave(
            GoalDraft(
                title: trimmedTitle,
                targetAmount: targetAmount,
                savedAmount: savedAmount,
                deadline: deadline,
                note: note.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        )
        isPresented = false
    }
}

#Preview {
    NavigationStack {
        GoalsView(viewModel: GoalsViewModel())
    }
}
