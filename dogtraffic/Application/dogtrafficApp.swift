// dogtrafficApp.swift

import SwiftUI
import FirebaseCore
import FirebaseAuth
import GoogleSignIn

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        print("[AppDelegate] Firebase configured successfully.")
        return true
    }

    func application(_ app: UIApplication,
                   open url: URL,
                   options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if GIDSignIn.sharedInstance.handle(url) {
            print("[AppDelegate] URL handled by Google Sign-In.")
            return true
        }
        if Auth.auth().canHandle(url) {
            print("[AppDelegate] URL can be handled by Firebase Auth (e.g., Phone Auth, Email Link). The auth flow will continue.")
            // Don't return true from here as the specific auth handler should complete the flow.
        }
        return false
    }
}

@main
struct dogtrafficApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        WindowGroup {
            // Use ContentView as the root view which will manage the auth state
            ContentView()
        }
    }
}
