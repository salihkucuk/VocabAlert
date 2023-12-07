//
//  ScoreView.swift
//  VocabAlertApp
//
//  Created by MSK on 21.11.2023.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import SwiftUI

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
