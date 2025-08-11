import SwiftUI
import BudgetCore

@main
struct BudgetApp: App {
    @StateObject private var viewModel = BudgetViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(viewModel)
        }
    }
}