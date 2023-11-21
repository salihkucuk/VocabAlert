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
            RandomWordView(randomWord: randomWord, onCorrectGuess: { isCorrect in
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
            CardView() // RandomWordView, her sekmeyi temsil eder
                .tabItem {
                    Label("Kelime Karti", systemImage: "book.pages")
                }
            ScoreView()
                .tabItem {
                    Label("Skor", systemImage: "star")
                }
            QuizView()
                .tabItem {
                    Label("Quiz", systemImage: "star")
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
// Kullanıcının puanını Firestore'a kaydeden fonksiyon
func saveScoreToFirestore(isCorrectGuess: Bool) {
    if let userId = Auth.auth().currentUser?.uid {
        let scoreChange = isCorrectGuess ? 1 : -1 // Doğru tahmin için +1, yanlış tahmin için -1

        let userScoresCollection = db.collection("user_scores")
        let userScoreDocument = userScoresCollection.document(userId)

        userScoreDocument.setData(["score": FieldValue.increment(Int64(scoreChange))], merge: true) { error in
            if let error = error {
                print("Firestore Hata: \(error.localizedDescription)")
            } else {
                print("Puan başarıyla kaydedildi!")
            }
        }
    } else {
        print("Kullanıcı oturumu açık değil.")
    }
}
struct UserScore {
    var username: String
    var score: Int
}
func fetchAllUserScoresAndUsernames(completion: @escaping ([UserScore]) -> Void) {
    db.collection("user_scores")
      .order(by: "score", descending: true) // Skorları azalan sırada sırala
      .getDocuments { (querySnapshot, err) in
          if let err = err {
              print("Hata: \(err)")
              completion([])
          } else {
              var scores: [UserScore] = []
              for document in querySnapshot!.documents {
                  let score = document.data()["score"] as? Int ?? 0
                  let username = document.data()["username"] as? String ?? "Anonim"
                  scores.append(UserScore(username: username, score: score))
              }
              completion(scores)
          }
      }
}
struct ScoreView: View {
    @State private var userScores = [UserScore]()

    var body: some View {
        VStack {
            Text("Puan Sıralaması")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            List(userScores.indices, id: \.self) { index in
                let userScore = userScores[index]

                HStack {
                    Text(userScore.username)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .truncationMode(.tail)

                    Spacer()

                    Text("\(userScore.score)")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 5)
                .listRowBackground(self.backgroundColor(for: index))
            }
        }
        .onAppear {
            fetchAllUserScoresAndUsernames { scores in
                self.userScores = scores
            }
        }
    }

    private func backgroundColor(for index: Int) -> Color {
        // İndekse bağlı olarak sarıdan kırmızıya renk geçişi
        let progress = Double(index) / Double(userScores.count - 1)
        let redValue = 1.0 // Kırmızı bileşen sabit
        let greenValue = 1.0 - progress // Yeşil bileşen azalıyor
        let blueValue = 0.0 // Mavi bileşen kullanılmıyor

        return Color(red: redValue, green: greenValue, blue: blueValue)
    }
}



struct RandomWordView: View {
    @State var randomWord: Word?
    @State private var viewModel = ContentViewModel()
    var onCorrectGuess: (Bool) -> Void
    @State private var userGuess = ""
    @State private var isTextFieldFocused = false
    func getRandomWord() {
        if let words = viewModel.loadWordJson(filename: "tr") {
            randomWord = words.randomElement()
        }
    } 
    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Text(randomWord?.englishWord[0] ?? "")
                    .font(.system(size: 50))
                    .foregroundColor(Color.blue)
                    .multilineTextAlignment(.leading)
                    .padding()
                
                TextField("Tahmininizi Girin", text: $userGuess, onEditingChanged: { editingChanged in
                    isTextFieldFocused = editingChanged
                })
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                
                HStack {
                    Button(action: {
                        checkGuess()
                        isTextFieldFocused = false // Klavye görünürlüğünü kapat
                    }) {
                        Text("Tahmin Et")
                            .fontWeight(.bold)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                    
                    Button(action: {
                        getRandomWord()
                        isTextFieldFocused = false // Klavye görünürlüğünü kapat
                    }) {
                        Text("Kelime Getir")
                            .fontWeight(.bold)
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                
                Spacer()
            }
            
        }
        
    }
    
    func checkGuess() {
        let lowercasedGuess = userGuess.lowercased().convertTurkishCharacters()
        
        if let targetWord = randomWord?.targetWord.lowercased().convertTurkishCharacters(), lowercasedGuess == targetWord {
            onCorrectGuess(true)
            getRandomWord()
            userGuess = ""
        } else {
            onCorrectGuess(false)
            userGuess = ""
            
        }
    }
    
}
extension String {
    func convertTurkishCharacters() -> String {
        var convertedString = self
        let characterMap: [Character: Character] = [
            "ğ": "g",
            "ü": "u",
            "ş": "s",
            "ı": "i",
            "ö": "o",
            "ç": "c",
            "Ğ": "G",
            "Ü": "U",
            "Ş": "S",
            "İ": "I",
            "Ö": "O",
            "Ç": "C"
        ]
        
        for (from, to) in characterMap {
            convertedString = convertedString.replacingOccurrences(of: String(from), with: String(to))
        }
        
        return convertedString
    }
}

struct CardFront : View {
    let width : CGFloat
    let height : CGFloat
    @Binding var degree : Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.yellow)
                .frame(width: width, height: height)
                .shadow(color: .gray, radius: 2, x: 0, y: 0)
            VStack(alignment: .leading){
                Text(randomWord?.englishWord[0] ?? "")
                    .font(.system(size: 50))
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .onAppear(perform: {
                        getRandomWord()
                    })
                Text(randomWord?.englishWord[1] ?? "")
                    .font(.system(size: 20))
                    .foregroundColor(Color.white)
                    .padding()
                    .multilineTextAlignment(.leading)
                Text(randomWord?.englishWord[2] ?? "")
                    .font(.system(size: 20))
                    .foregroundColor(Color.white)
                    .padding()
                    .multilineTextAlignment(.leading)
                Text(randomWord?.englishWord[3] ?? "")
                    .font(.system(size: 20))
                    .foregroundColor(Color.white)
                    .padding()
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}

struct CardBack : View {
    let width : CGFloat
    let height : CGFloat
    @Binding var degree : Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.yellow)
                .frame(width: width, height: height)
                .shadow(color: .gray, radius: 2, x: 0, y: 0)
            Text(randomWord?.targetWord ?? "")
                .font(.system(size: 60))
                .foregroundColor(Color.black)
                .frame(width: 300, height: 400)
                .padding()
                .onAppear(perform: {
                    getRandomWord()
                })
        }.rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}

struct CardView: View {
    //MARK: Variables
    @State var backDegree = 0.0
    @State var frontDegree = -90.0
    @State var isFlipped = true
    
    let width : CGFloat = 350
    let height : CGFloat = 540
    let durationAndDelay : CGFloat = 0.3
    
    //MARK: Flip Card Function
    func flipCard () {
        isFlipped = !isFlipped
        if isFlipped {
            withAnimation(.linear(duration: durationAndDelay)) {
                backDegree = 90
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)){
                frontDegree = 0
            }
        } else {
            withAnimation(.linear(duration: durationAndDelay)) {
                frontDegree = -90
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)){
                backDegree = 0
            }
        }
    }
    //MARK: View Body
    var body: some View {
        ZStack {
            Color.green
            CardFront(width: width, height: height, degree: $frontDegree)
            CardBack(width: width, height: height, degree: $backDegree)
            VStack {
                Spacer()
                Button(action: {
                    // getRandomWord() fonksiyonunu çağırarak rastgele kelimeyi getir
                    getRandomWord()
                }) {
                    Text("Kelime Getir")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding([.top, .bottom], 20)
                }
                .padding([.leading, .trailing], 20)
            }
        }.onTapGesture {
            flipCard ()
        }
    }
}

struct QuizView: View {
    @State var randomItem: Item?
    @State private var viewModel = ContentViewModel()
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var isAnswerCorrect = false
    @State private var currentOptions: [String] = []

    func getItemWord() {
        if let items = viewModel.loadItemJson(filename: "quiz") {
            randomItem = items.randomElement()
            setupOptions()
        }
    }

    func setupOptions() {
        if let item = randomItem {
            var options = item.options
            options.append(item.wordA)
            options.shuffle()  // Karıştır
            currentOptions = options
        }
    }

    func checkAnswer(_ userAnswer: String) {
        if userAnswer == randomItem?.wordA {
            // Doğru cevap verildi
            alertTitle = "Doğru!"
            isAnswerCorrect = true
        } else {
            // Yanlış cevap verildi
            alertTitle = "Yanlış!"
            isAnswerCorrect = false
        }
        showAlert = true
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white)
                        .shadow(radius: 5)
                    Text(randomItem?.wordQ ?? "...")
                        .font(.largeTitle)
                        .foregroundColor(.black)
                }
                .frame(height: 250)
                .padding(.horizontal)
                .padding(.top, 24)

                VStack {
                    ForEach(currentOptions, id: \.self) { option in
                        Button(action: {
                            checkAnswer(option)
                        }) {
                            Text(option)
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.orange)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    Button("Sonraki") {
                        getItemWord()
                    }
                    .buttonStyle(FlashCardButtonStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }
            }
        }
        .onAppear(perform: getItemWord)
        .alert(isPresented: $showAlert) {
            Alert(title: Text(alertTitle), dismissButton: .default(Text("Tamam")) {
                if isAnswerCorrect {
                    getItemWord()
                }
            })
        }
    }
}
struct SimpleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .background(configuration.isPressed ? Color.orange.opacity(0.7) : Color.orange)  // Basılı durumda opaklık ekleyin
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
struct FlashCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)  // Buton genişliğini maksimuma çıkar
            .background(configuration.isPressed ? Color.blue.opacity(0.7) : Color.blue)  // Basılı durumda opaklık ekleyin
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
struct FlashCardButtonStyleA: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .font(.system(size: 18))
    }
}
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
