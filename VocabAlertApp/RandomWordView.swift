//
//  RandomWordView.swift
//  VocabAlertApp
//
//  Created by MSK on 21.11.2023.
//

import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct WrongGuess {
    var englishWord: String
    var correctTurkishWord: String
}

struct RandomWordView: View {
    @State private var viewModel = ContentViewModel()
    @State var randomWord: Word?
    @State private var userGuess = ""
    @State private var isTextFieldFocused = false
    @State private var wrongGuesses = [WrongGuess]()
    @State private var successAlert = false // Başarı pop-up'ı için
    @State private var falseAlert = false // Başarı pop-up'ı için
    
    func getRandomWord() {
        if let words = viewModel.loadWordJson(filename: "tr") {
            randomWord = words.randomElement()
        }
    }
    var body: some View {
        ZStack {
            LinearGradient(gradient: Gradient(colors: [.white, .blue.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                Text(randomWord?.englishWord.first ?? "")
                    .font(.system(size: 50))
                    .fontWeight(.heavy)
                    .foregroundColor(Color.blue)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .transition(.slide)
                    .animation(.easeInOut(duration: 1.0), value: randomWord?.englishWord[0])
                
                CustomTextField(placeholder: Text("Tahmininizi Girin").foregroundColor(.gray), text: $userGuess)
                    .padding()
                    .frame(height: 55)
                    .background(Color.white)
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding()
                
                HStack {
                    CustomButton(text: "Tahmin Et", action: {
                        checkGuess()
                        isTextFieldFocused = false
                    }, color: .blue)
                    
                    CustomButton(text: "Kelime Getir", action: {
                        getRandomWord()
                        isTextFieldFocused = false
                    }, color: .green)
                }
                Spacer()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isTextFieldFocused)
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
                        //correctGuess = false
                        // Tahmin yanlış işlemleri
                    }
                }
            )
        }
    }
    
    func checkGuess() {
        guard !userGuess.isEmpty, let englishWord = randomWord?.englishWord.first, let targetWord = randomWord?.targetWord else { return }
        let lowercasedGuess = userGuess.lowercased().convertTurkishCharacters()
        let targetWordConverted = targetWord.lowercased().convertTurkishCharacters()
        
        if let targetWord = randomWord?.targetWord.lowercased().convertTurkishCharacters() {
            let distance = lowercasedGuess.levenshteinDistance(to: targetWord)
            let similarity = Double(targetWord.count - distance) / Double(targetWord.count)
            
            if similarity >= 0.74 {
                getRandomWord()
                userGuess = ""
                successAlert = true
                saveScoreToFirestore(isCorrectGuess: true)
            } else {
                let wrongGuess = WrongGuess(englishWord: englishWord, correctTurkishWord: targetWord)
                wrongGuesses.append(wrongGuess) // İngilizce ve Türkçe kelimeyi ekle
                saveWrongGuessToFirebase(guess: wrongGuess) // Firebase'e kaydet
                userGuess = ""
                falseAlert = true
                saveScoreToFirestore(isCorrectGuess: false)
            }
        }
    }
    func saveWrongGuessToFirebase(guess: WrongGuess) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Kullanıcı oturumu açık değil.")
            return
        }
        
        let documentId = UUID().uuidString // Her tahmin için benzersiz bir ID
        let data = [
            "englishWord": guess.englishWord,
            "correctTurkishWord": guess.correctTurkishWord
        ]
        checkWordAndAdd(word: guess.englishWord) { result in
            if result{
                db.collection("users").document(userId).collection("wrongGuesses").document(documentId).setData(data) { error in
                    if let error = error {
                        print("Wrong guess kaydedilirken hata: \(error.localizedDescription)")
                    } else {
                        print("Wrong guess başarıyla kaydedildi.")
                    }
                }
            }
        }
    }
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
    func checkWordAndAdd(word: String, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Kullanıcı oturumu açık değil.")
            return
        }
        let query = db.collection("users").document(userId).collection("wrongGuesses").whereField("englishWord", isEqualTo: word)
        query.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
                completion(false)
            } else if snapshot!.documents.isEmpty {
                // Word not found, add it
                completion(true)
            } else {
                // Word already exists
                completion(false)
            }
        }
    }
}
