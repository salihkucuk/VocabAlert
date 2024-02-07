import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct WrongGuesss {
    var id: String
    var englishWord: String
    var correctTurkishWord: String
}
struct WrongGuessesView: View {
    @State var wrongGuesses: [WrongGuess] = []

    var body: some View {
        Group {
            if wrongGuesses.isEmpty {
                Text("Henüz yanlış tahmin yapılmadı")
                    .font(.title)
                    .foregroundColor(.gray)
            } else {
                List {
                                    ForEach(wrongGuesses, id: \.id) { guess in
                                        VStack(alignment: .leading) {
                                            Text("\(guess.englishWord) = \(guess.correctTurkishWord)")
                                        }
                                    }
                                    .onDelete(perform: deleteItems)
                                }
            }
        }.onAppear{
            loadWrongGuessesFromFirebase()
        }
    }
    func deleteItems(at offsets: IndexSet) {
            for index in offsets {
                let guessId = wrongGuesses[index].id
                deleteWrongGuessFromFirebase(guessId: guessId)
                wrongGuesses.remove(at: index)
            }
        }
    func loadWrongGuessesFromFirebase() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Kullanıcı oturumu açık değil.")
            return
        }

        db.collection("users").document(userId).collection("wrongGuesses").getDocuments { (snapshot, error) in
            if let error = error {
                print("Wrong guesses yüklenirken hata: \(error.localizedDescription)")
                return
            }

            self.wrongGuesses.removeAll()
            for document in snapshot!.documents {
                let data = document.data()
                if let englishWord = data["englishWord"] as? String, let correctTurkishWord = data["correctTurkishWord"] as? String {
                    // Yeni yanlış tahmini, listede zaten var mı diye kontrol et
                    if !self.wrongGuesses.contains(where: { $0.englishWord == englishWord }) {
                        let guess = WrongGuess(id: document.documentID, englishWord: englishWord, correctTurkishWord: correctTurkishWord)
                        self.wrongGuesses.append(guess)
                    }
                }
            }
        }
    }
    func deleteWrongGuessFromFirebase(guessId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Kullanıcı oturumu açık değil.")
            return
        }

        db.collection("users").document(userId).collection("wrongGuesses").document(guessId).delete() {error in
            if let error = error {
                print("Wrong guess silinirken hata: \(error.localizedDescription)")
            } else {
                print("Wrong guess başarıyla silindi.")
                loadWrongGuessesFromFirebase() // Silme işleminden sonra listeyi yeniden yükle
            }
        }
    }
}
