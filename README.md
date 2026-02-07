# SpendWise

Personal Finance and Budget Tracker built with SwiftUI + MVVM. The app supports full CRUD for transactions, real-time sync with Firebase Realtime Database, and live exchange rates via a REST API.

## Features

- Transactions CRUD (create, edit, delete) with real-time updates
- Firebase Realtime Database sync
- Exchange rates card (REST API via Alamofire + async/await)
- Analytics tab (summary, category breakdown, recent activity)
- Category budgets (per-category limits stored in UserDefaults)
- Settings with currency selection and monthly start day
- Modern SwiftUI UI with Light/Dark Mode support

## Tech Stack

- SwiftUI
- MVVM
- Firebase Realtime Database
- Alamofire (async/await)
- UserDefaults

## Requirements Coverage (high-level)

- Form inputs: TextField, TextEditor, DatePicker, Picker, Toggle, Button
- List and Sections for data display
- NavigationStack + NavigationLink
- TabView with 3 tabs (Home, Transactions, Analytics, Settings)
- State management: @State, @Binding, @StateObject, @ObservedObject
- Animations on list updates and budget progress
- Firebase CRUD + real-time listener
- REST API loading/success/error states

## Setup

### 1) Firebase

1. Add Firebase packages via Swift Package Manager:
   - FirebaseCore
   - FirebaseDatabase
2. Add `GoogleService-Info.plist` to the Xcode target.
3. Ensure Firebase is configured on app launch (already set in `SpendWiseApp.swift`).

### 2) Build

Open `SpendWise/SpendWise.xcodeproj` and run the app on a simulator or device.

## Project Structure

```
SpendWise/
  SpendWise/
    Models/
    Services/
    ViewModels/
    Views/
    Resources/
```

## Notes

- Currency is stored by code (default: KZT). You can change it in Settings.
- Category budgets are stored locally in UserDefaults.
- Exchange rates are fetched from `https://open.er-api.com/v6/latest/USD`.
