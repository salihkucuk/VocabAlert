import SwiftUI
import UserNotifications
import Firebase
import FirebaseAuth
import FirebaseFirestore

let db = Firestore.firestore()
private var viewModel = ContentViewModel()
var randomWord: Word?
var randomItem: Item?
func getRandomWord() {
    if let words = viewModel.loadWordJson(filename: "tr") {
        randomWord = words.randomElement()
    }
}
func getItemWord() {
    if let items = viewModel.loadItemJson(filename: "quiz") {
        randomItem = items.randomElement()
    }
}

struct ContentView: View {
    @State private var randomWord: Word?
    @State var isReminderEnabled: Bool = false
    @State var selectedInterval = 30
    @State var showingReminderSettings = false
    @State private var isFlipped = false
    @State private var successAlert = false // Başarı pop-up'ı için
    @State private var falseAlert = false // Başarı pop-up'ı için
    @State private var correctGuess = false
    @State private var userGuess = ""
    @State private var score = 0
    @State var numberOfNotifications = 1
    @State private var wrongGuesses = [WrongGuess]()
    
    var body: some View {
        TabView {
            VStack {
                Image("pexels-lisa-fotios-2129906")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .padding()
            }
            .tabItem {
                Label("Ana Ekran", systemImage: "house")
            }
            RandomWordView(randomWord: $randomWord, wrongGuesses: $wrongGuesses, onCorrectGuess: { isCorrect in
                if isCorrect {
                    successAlert = true
                    saveScoreToFirestore(isCorrectGuess: true)
                } else {
                    falseAlert = true
                    saveScoreToFirestore(isCorrectGuess: false)
                }
            })
            .tabItem {
                Label("Kelime", systemImage: "textformat")
            }
            QuizView()
                .tabItem {
                    Label("Quiz", systemImage: "questionmark.circle")
                }
            CardView() // RandomWordView, her sekmeyi temsil eder
                .tabItem {
                    Label("Kelime Karti", systemImage: "book.pages")
                }
            ScoreView()
                .tabItem {
                    Label("Skor", systemImage: "star")
                }
            WrongGuessesView(wrongGuesses: $wrongGuesses) // Yanlış tahminlerin gösterileceği sekme
                            .tabItem {
                                Label("Yanlış tahminler", systemImage: "xmark.circle")
                            }
           
            TranslateView() // RandomWordView, her sekmeyi temsil eder
                .tabItem {
                    Label("Çeviri", systemImage: "keyboard")
                }
            
            SettingsView(isReminderEnabled: isReminderEnabled, selectedInterval: selectedInterval, numberOfNotifications: numberOfNotifications) // ReminderSettingsView, her sekmeyi temsil eder
                .tabItem {
                    Label("Ayarlar", systemImage: "gear")
                }
        }
        .navigationBarHidden(true)
        .onAppear(perform: {
            getRandomWord()
        })
        .alert(isPresented: Binding<Bool>(
            get: { successAlert || falseAlert },
            set: { _ in
                successAlert = false
                falseAlert = false
            }
        )) {
            Alert(
                title: Text(successAlert ? "Tebrikler!" : "Tekrar Denemelisin"),
                message: Text(successAlert ? "Tahmininiz doğru!" : "Üzgünüm, tahmininiz yanlış."),
                dismissButton: .default(Text("Tamam")) {
                    if successAlert {
                        // Tahmin doğru işlemleri
                    } else {
                        correctGuess = false
                        // Tahmin yanlış işlemleri
                    }
                }
            )
        }
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
