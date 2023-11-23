import SwiftUI
import FirebaseAuth

@main
struct MyApp: App {
    @StateObject var session = SessionStore()
    
    init() {
        setupAuthentication()
    }
    
    var body: some Scene {
        WindowGroup {
            if session.isLoggedIn {
                ContentView()
            } else {
                LoginSignUpView()
            }
        }
    }
    
    func setupAuthentication() {
        session.listenAuthenticationState()
    }
}

class SessionStore: ObservableObject {
    @Published var isLoggedIn: Bool = false
    
    func listenAuthenticationState() {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // Kullanıcı oturumu açık
                print("Oturum açan kullanıcı: \(user)")
                self.isLoggedIn = true
            } else {
                // Kullanıcı oturumu kapalı veya oturum açılmamış
                self.isLoggedIn = false
            }
        }
    }
}
