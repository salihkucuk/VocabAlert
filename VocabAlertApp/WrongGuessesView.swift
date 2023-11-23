import SwiftUI

struct WrongGuessesView: View {
    @Binding var wrongGuesses: [WrongGuess]

    var body: some View {
        Group {
            if wrongGuesses.isEmpty {
                Text("Henüz yanlış tahmin yapılmadı")
                    .font(.title)
                    .foregroundColor(.gray)
            } else {
                List(wrongGuesses, id: \.englishWord) { guess in
                    VStack(alignment: .leading) {
                        Text("\(guess.englishWord) = \(guess.correctTurkishWord)")
                    }
                }
            }
        }
    }
}
