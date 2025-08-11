# Budget App (SwiftUI + Swift Package)

This workspace contains:

- BudgetCore: A Swift Package with core budgeting models and a JSON-backed `BudgetStore`.
- iOSApp: SwiftUI scaffolding that uses `BudgetCore` with sample screens for Accounts and Transactions.

## Requirements

- Xcode 15 or newer (iOS 16+ target)

## How to run the iOS app

1. Open Xcode and create a new iOS App project named `BudgetApp` (SwiftUI, Swift, iOS 16+).
2. In the project, go to the Package Dependencies tab and add a local package:
   - File > Add Packages... > Add Local... and select the folder at this repo root (which contains `Package.swift`).
   - Choose the `BudgetCore` product.
3. Add the following files from `iOSApp/` into your Xcode app target:
   - `iOSApp/BudgetApp.swift`
   - `iOSApp/ContentView.swift`
   - `iOSApp/ViewModels/BudgetViewModel.swift`
   Ensure these files are part of the app target build settings.
4. Build and run on the simulator. The app will seed sample data on first launch.

## Notes

- Transactions use integer cents to avoid floating-point rounding.
- `BudgetStore` persists to `Documents/BudgetData/budget.json` on iOS.
- Provided unit tests for `BudgetCore` can be run via the package in Xcode.
