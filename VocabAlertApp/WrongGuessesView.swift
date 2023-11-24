import SwiftUI
import FirebaseAuth
import FirebaseFirestore

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
    func loadWrongGuessesFromFirebase(completion: @escaping ([WrongGuess]) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Kullanıcı oturumu açık değil.")
            return
        }

        db.collection("users").document(userId).collection("wrongGuesses").getDocuments { (snapshot, error) in
            if let error = error {
                print("Wrong guesses yüklenirken hata: \(error.localizedDescription)")
                return
            }

            var guesses: [WrongGuess] = []
            snapshot?.documents.forEach { document in
                let data = document.data()
                if let englishWord = data["englishWord"] as? String, let correctTurkishWord = data["correctTurkishWord"] as? String {
                    guesses.append(WrongGuess(englishWord: englishWord, correctTurkishWord: correctTurkishWord))
                }
            }
            completion(guesses)
        }
    }
    func deleteWrongGuessFromFirebase(guessId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Kullanıcı oturumu açık değil.")
            return
        }

        db.collection("users").document(userId).collection("wrongGuesses").document(guessId).delete() { error in
            if let error = error {
                print("Wrong guess silinirken hata: \(error.localizedDescription)")
            } else {
                print("Wrong guess başarıyla silindi.")
            }
        }
    }


}
