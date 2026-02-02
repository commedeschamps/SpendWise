import SwiftUI
import FirebaseCore

// Firebase setup notes:
// 1) Add Firebase packages (FirebaseCore + FirebaseDatabase) via Swift Package Manager.
// 2) Add GoogleService-Info.plist to the Xcode project (SpendWise target).
// 3) Ensure FirebaseApp.configure() is called at launch (see AppDelegate below).

final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct SpendWiseApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var delegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
