import SwiftUI
import UserNotifications
import Firebase
import FirebaseAuth
import FirebaseFirestore

let db = Firestore.firestore()

struct ContentView: View {
    var body: some View {
        TabView {
            RandomWordView().tabItem {
                Label("Kelime", systemImage: "textformat")
            }
            QuizView().tabItem {
                Label("Quiz", systemImage: "questionmark.circle")
            }
            CardView().tabItem {
                Label("Kelime Kartı", systemImage: "book.pages")
            }
           ScoreView().tabItem {
                Label("Skor", systemImage: "star")
            }
            WrongGuessesView().tabItem {
                Label("Yanlış Tahminler", systemImage: "xmark.circle")
            }
            /*TranslateView().tabItem {
                Label("Çeviri", systemImage: "keyboard")
            }*/
           SettingsView().tabItem {
                Label("Ayarlar", systemImage: "gear")
            }
           
        }
        .navigationBarHidden(true)
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
