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
        @Binding var randomWord: Word?
        var onCorrectGuess: (Bool) -> Void
        @State private var userGuess = ""
        @State private var isTextFieldFocused = false
        @Binding private var wrongGuesses: [WrongGuess]
    
    func getRandomWord() {
        if let words = viewModel.loadWordJson(filename: "tr") {
            randomWord = words.randomElement()
        }
    }
    
    init(randomWord: Binding<Word?>, wrongGuesses: Binding<[WrongGuess]>, onCorrectGuess: @escaping (Bool) -> Void) {
            self._randomWord = randomWord
            self._wrongGuesses = wrongGuesses
            self.onCorrectGuess = onCorrectGuess
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
        }
    
    func checkGuess() {
        guard !userGuess.isEmpty, let englishWord = randomWord?.englishWord.first, let targetWord = randomWord?.targetWord else { return }
                let lowercasedGuess = userGuess.lowercased().convertTurkishCharacters()
                let targetWordConverted = targetWord.lowercased().convertTurkishCharacters()
            
            if let targetWord = randomWord?.targetWord.lowercased().convertTurkishCharacters() {
                let distance = lowercasedGuess.levenshteinDistance(to: targetWord)
                let similarity = Double(targetWord.count - distance) / Double(targetWord.count)

                if similarity >= 0.74 {
                    onCorrectGuess(true)
                    getRandomWord()
                    userGuess = ""
                } else {
                    let wrongGuess = WrongGuess(englishWord: englishWord, correctTurkishWord: targetWord)
                        wrongGuesses.append(wrongGuess) // İngilizce ve Türkçe kelimeyi ekle
                        saveWrongGuessToFirebase(guess: wrongGuess) // Firebase'e kaydet
                        onCorrectGuess(false)
                        userGuess = ""
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

        db.collection("users").document(userId).collection("wrongGuesses").document(documentId).setData(data) { error in
            if let error = error {
                print("Wrong guess kaydedilirken hata: \(error.localizedDescription)")
            } else {
                print("Wrong guess başarıyla kaydedildi.")
            }
        }
    }
}
extension String {
    func levenshteinDistance(to target: String) -> Int {
        if self.isEmpty || target.isEmpty {
                return max(self.count, target.count)
            }
        
        let s = Array(self)
        let t = Array(target)
        let m = s.count
        let n = t.count
        var distanceMatrix = [[Int]](repeating: [Int](repeating: 0, count: n + 1), count: m + 1)

        for i in 0...m {
            distanceMatrix[i][0] = i
        }

        for j in 0...n {
            distanceMatrix[0][j] = j
        }

        for i in 1...m {
            for j in 1...n {
                let cost = s[i - 1] == t[j - 1] ? 0 : 1
                distanceMatrix[i][j] = Swift.min(
                    distanceMatrix[i - 1][j] + 1,
                    distanceMatrix[i][j - 1] + 1,
                    distanceMatrix[i - 1][j - 1] + cost
                )
            }
        }

        return distanceMatrix[m][n]
    }
}

struct CustomTextField: View {
    let placeholder: Text
    @Binding var text: String
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            TextField("", text: $text)
        }
    }
}

struct CustomButton: View {
    let text: String
    let action: () -> Void
    let color: Color
    var body: some View {
        Button(action: action) {
            Text(text)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding()
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
