//
//  FirstSwiftUIAppApp.swift
//  FirstSwiftUIApp
//
//  Created by MSK on 26.10.2023.
//

import SwiftUI
import FirebaseCore
import FirebaseAuth
import FirebaseAnalytics
import FirebaseStorage
import FirebaseFirestore
import Firebase
import OneSignalFramework

@main
struct VocabAlertApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
                    MainView()
                }
    }
}
struct MainView: View {
    @StateObject var session = SessionStore()
    
    var body: some View {
        Group {
            if session.isLoggedIn {
                ContentView()
            } else {
                LoginSignUpView()
            }
        }
        .onAppear(perform: session.listenAuthenticationState)
    }
}

class SessionStore: ObservableObject {
    @Published var isLoggedIn: Bool = false
    
    func listenAuthenticationState() {
        Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.isLoggedIn = user != nil
        }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
       // Remove this method to stop OneSignal Debugging
       OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        
       // OneSignal initialization
       OneSignal.initialize("e8b71c46-8a62-4588-be4f-7961e988913e", withLaunchOptions: launchOptions)

       // requestPermission will show the native iOS notification permission prompt.
       // We recommend removing the following code and instead using an In-App Message to prompt for notification permission
       OneSignal.Notifications.requestPermission({ accepted in
         print("User accepted notifications: \(accepted)")
       }, fallbackToSettings: true)

       // Login your customer with externalId
       // OneSignal.login("EXTERNAL_ID")
            
       return true
    }
}
