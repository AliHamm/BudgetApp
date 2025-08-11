import SwiftUI
import BudgetCore

struct ContentView: View {
    @EnvironmentObject var viewModel: BudgetViewModel

    var body: some View {
        TabView {
            AccountsView()
                .tabItem { Label("Accounts", systemImage: "banknote") }
            TransactionsView()
                .tabItem { Label("Transactions", systemImage: "list.bullet") }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") { viewModel.errorMessage = nil }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
}

struct AccountsView: View {
    @EnvironmentObject var viewModel: BudgetViewModel
    @State private var isPresentingAdd = false
    @State private var accountName: String = ""
    @State private var selectedType: AccountType = .checking

    var body: some View {
        NavigationStack {
            List(viewModel.accounts) { account in
                HStack {
                    Text(account.name)
                    Spacer()
                    Text(centsToCurrency(account.balanceCents))
                        .foregroundColor(account.balanceCents >= 0 ? .green : .red)
                }
            }
            .navigationTitle("Accounts")
            .toolbar {
                Button(action: { isPresentingAdd = true }) {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $isPresentingAdd) {
                NavigationStack {
                    Form {
                        TextField("Name", text: $accountName)
                        Picker("Type", selection: $selectedType) {
                            ForEach(AccountType.allCases, id: \.self) { type in
                                Text(type.rawValue.capitalized).tag(type)
                            }
                        }
                    }
                    .navigationTitle("New Account")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Cancel") { isPresentingAdd = false }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Add") {
                                viewModel.addAccount(name: accountName, type: selectedType)
                                accountName = ""
                                isPresentingAdd = false
                            }
                            .disabled(accountName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        }
                    }
                }
            }
        }
    }
}

struct TransactionsView: View {
    @EnvironmentObject var viewModel: BudgetViewModel

    var body: some View {
        NavigationStack {
            List(viewModel.transactions) { tx in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(tx.payee)
                        Spacer()
                        Text(centsToCurrency(tx.amountInCents))
                            .foregroundColor(tx.amountInCents >= 0 ? .green : .red)
                    }
                    Text(tx.date.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Transactions")
            .toolbar {
                Button("Add Sample") { viewModel.addSampleTransaction() }
            }
        }
    }
}

private func centsToCurrency(_ cents: Int) -> String {
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = .current
    let amount = NSDecimalNumber(value: cents).dividing(by: 100)
    return formatter.string(from: amount) ?? "$0.00"
}

#Preview {
    ContentView()
        .environmentObject(BudgetViewModel())
}