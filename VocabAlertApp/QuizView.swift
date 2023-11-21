//
//  QuizView.swift
//  VocabAlertApp
//
//  Created by MSK on 21.11.2023.
//

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

    // Renk tanımlamaları
    let backgroundColor = Color(red: 0.95, green: 0.95, blue: 0.95) // Açık gri bir arka plan
        let cardBackgroundColor = Color(red: 1.0, green: 0.98, blue: 0.90) // Açık sarı-beyaz arası bir kart rengi
        let correctAnswerButtonColor = Color.green // Doğru cevap için yeşil renk
        let wrongAnswerButtonColor = Color.red // Yanlış cevap için kırmızı renk
        let nextButtonColor = Color.blue // Sonraki butonu için mavi renk
    
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
            if let correctAnswer = randomItem?.wordA {
                isAnswerCorrect = userAnswer == correctAnswer
                alertTitle = isAnswerCorrect ? "Doğru!" : "Yanlış!"
                
                // Doğru ya da yanlış cevaba göre puanı kaydet
                saveScoreToFirestore(isCorrectGuess: isAnswerCorrect)
            } else {
                // Eğer randomItem veya wordA boşsa, bir hata mesajı göster
                alertTitle = "Hata!"
                isAnswerCorrect = false
            }
            showAlert = true
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
            backgroundColor.edgesIgnoringSafeArea(.all)
            
            VStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 25)
                        .fill(cardBackgroundColor)
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
                                .background(isAnswerCorrect ? correctAnswerButtonColor : wrongAnswerButtonColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer()
                    
                    Button("Sonraki") {
                        getItemWord()
                    }
                    .buttonStyle(FlashCardButtonStyle(backgroundColor: nextButtonColor))
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
