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
            aaview().tabItem {
                Label("Ayarlar", systemImage: "gear")
            }
            SettingsView().tabItem {
                Label("Ayarlar", systemImage: "gear")
            }
           
        }
        .navigationBarHidden(true)
    }
}
struct WordPair: Decodable, Identifiable {
    let id: Int
    let english: String
    let turkish: String
}

struct aaview: View {
    @State private var wordPairs: [WordPair] = []
    @State private var selectedEnglishWord: String?
    @State private var selectedTurkishWord: String?

    var body: some View {
        VStack {
            Text("Kelime Eşleştirme Oyunu")
                .font(.largeTitle)

            HStack {
                VStack {
                    ForEach(wordPairs) { pair in
                        Button(action: {
                            self.selectedEnglishWord = pair.english
                            checkMatch()
                        }) {
                            Text(pair.english)
                        }
                    }
                }

                VStack {
                    ForEach(wordPairs) { pair in
                        Button(action: {
                            self.selectedTurkishWord = pair.turkish
                            checkMatch()
                        }) {
                            Text(pair.turkish)
                        }
                    }
                }
            }
        }
        .onAppear(perform: loadWordPairs)
    }
    
    func loadWordPairs() {
        // JSON dosyanızı yükleyin ve parse edin.
        // Sonucu 'wordPairs' dizisine atayın.
    }
    
    func checkMatch() {
        if let english = selectedEnglishWord, let turkish = selectedTurkishWord {
            // Burada eşleştirme kontrolü yapın.
            // Eğer kelimeler eşleşiyorsa, kullanıcıya bildirim verin veya puan ekleyin.
            // Ardından seçimleri sıfırlayın.
            selectedEnglishWord = nil
            selectedTurkishWord = nil
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
