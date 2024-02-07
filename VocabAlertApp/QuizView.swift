
//  Created by MSK on 21.11.2023.

import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct QuizView: View {
    @State var randomItem: Item?
    @State private var viewModel = ContentViewModel()
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var isAnswerCorrect = false
    @State private var currentOptions: [String] = []
    @State private var selectedLevel: String = "A1"
    
    // Renk tanımlamaları
    let backgroundColor = Color(red: 0.95, green: 0.95, blue: 0.95) // Açık gri bir arka plan
    let cardBackgroundColor = Color(red: 1.0, green: 0.98, blue: 0.90) // Açık sarı-beyaz arası bir kart rengi
    let correctAnswerButtonColor = Color.green // Doğru cevap için yeşil renk
    let wrongAnswerButtonColor = Color.red // Yanlış cevap için kırmızı renk
    let nextButtonColor = Color.orange //
    
    func getItemWord() {
        if let items = viewModel.loadItemJson(filename: "quiz\(selectedLevel)") {
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
        if let correctAnswer = randomItem?.wordA {
            isAnswerCorrect = userAnswer == correctAnswer
            if isAnswerCorrect {
                // Doğru cevap verildiğinde otomatik olarak yeni bir soru yükle
                getItemWord()
            } else {
                // Yanlış cevap verildiğinde uyarı başlığını ayarla
               // alertTitle = "Yanlış!"
               // showAlert = true
            }
            
            
            // Doğru ya da yanlış cevaba göre puanı kaydet
            saveScoreToFirestore(isCorrectGuess: isAnswerCorrect)
        } else {
            // Eğer randomItem veya wordA boşsa, bir hata mesajı göster
            alertTitle = "Hata!"
            isAnswerCorrect = false
        }
        showAlert = !isAnswerCorrect
    }
    func saveScoreToFirestore(isCorrectGuess: Bool) {
        // Mevcut kullanıcı ID'sini al
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Kullanıcı oturumu açık değil.")
            return
        }
        
        // Puan değişimini hesapla
        let scoreChange = isCorrectGuess ? 1 : -1
        
        // Firestore'daki ilgili dokümanı al
        let userScoresCollection = Firestore.firestore().collection("user_scores")
        let userScoreDocument = userScoresCollection.document(userId)
        
        // Puanı güncelle
        userScoreDocument.setData(["score": FieldValue.increment(Int64(scoreChange))], merge: true) { error in
                        if let error = error {
                            print("Firestore Hata: \(error.localizedDescription)")
                        } else {
                            print("Puan başarıyla kaydedildi!")
                        }
                    }
    }
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white
            VStack() {
                
                // Seviye Seçim Butonları
                HStack {
                    ForEach(["A1", "A2", "B1", "B2"], id: \.self) { level in
                        Button(level) {
                            selectedLevel = level
                            getItemWord()
                        }
                        .buttonStyle(FlashCardButtonStyle(backgroundColor: level == selectedLevel ? Color.orange : Color.green))
                    }
                }
                
                // Soru Metni
                ZStack {
                    // Metnin arka planı
                    Rectangle()
                        .fill(cardBackgroundColor)
                        .frame(width: UIScreen.main.bounds.width * 0.9, height: 250) // Ekran genişliğinin %90'ı kadar genişlik ve 250 yükseklik
                        .cornerRadius(25)
                        .shadow(radius: 5)
                    // Metin
                    if let wordQ = randomItem?.wordQ {
                        Text(wordQ)
                            .font(.largeTitle)
                            .foregroundColor(.black)
                            .padding()
                    }
                }
                .padding(.horizontal)
                
                
                
                // Cevap Seçenekleri
                VStack{
                    ForEach(currentOptions, id: \.self) { option in
                        Button(action: {
                            checkAnswer(option)
                        }) {
                            Text(option)
                                .fontWeight(.bold)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(isAnswerCorrect ? correctAnswerButtonColor : wrongAnswerButtonColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
                Spacer()
                
                // "Sonraki" Butonu
                Button("Sonraki") {
                    getItemWord()
                }
                .font(.system(size: 20))
                
                .buttonStyle(FlashCardButtonStyle(backgroundColor: nextButtonColor))
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
            .padding(.top, 24)
        }
        .onAppear(perform: getItemWord)
       // .alert(isPresented: $showAlert) {
        //    Alert(title: Text(alertTitle), dismissButton: .default(Text("Tamam")) {
        //        if isAnswerCorrect {
                    //getItemWord()
        //        }
         //   })
       // }
    }
}


struct FlashCardButtonStyle: ButtonStyle {
    var backgroundColor: Color = .blue
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding()
            .frame(maxWidth: .infinity)
            .background(configuration.isPressed ? backgroundColor.opacity(0.7) : backgroundColor)
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
