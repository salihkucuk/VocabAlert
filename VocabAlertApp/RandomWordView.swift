//
//  RandomWordView.swift
//  VocabAlertApp
//
//  Created by MSK on 21.11.2023.
//

import Foundation
import SwiftUI

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
                LinearGradient(gradient: Gradient(colors: [.white, .blue.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    Text(randomWord?.englishWord[0] ?? "")
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
