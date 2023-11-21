//
//  TranslateView.swift
//  VocabAlertApp
//
//  Created by MSK on 21.11.2023.
//

import Foundation
import SwiftUI

struct TranslateView: View {
    @State private var userInput = ""
    @State private var translatedText = ""
    
    var body: some View {
        VStack {
            VStack {
                TextField("Metni Girin", text: $userInput)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(width: 300, height: 200)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .border(Color.black, width: 1) // Kenarlık ekleniyor
                    )
                    .foregroundColor(.blue) // Yazı rengi
                    .onTapGesture {
                        // TextField'a tıklandığında yapılacak işlemler
                        // Örneğin, klavyeyi göstermek için UIApplication.shared.sendAction kullanabilirsiniz:
                        UIApplication.shared.sendAction(#selector(UIResponder.becomeFirstResponder), to: nil, from: nil, for: nil)
                    }
                Spacer()
            }
            .padding()
            
            Button("Çevir") {
                translateText()
            }
            .padding(.bottom, 20)
            
            VStack {
                Text(translatedText)
                    .frame(width: 300, height: 200)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white)
                            .border(Color.black, width: 1) // Kenarlık ekleniyor
                    )
                    .foregroundColor(.blue) // Yazı rengi
                Spacer() // Çevrilen metin alt satırdan başlasın diye Spacer ekleniyor
            }
            .padding()
            
            Spacer()
        }
        .padding()
        
    }
    
    func translateText() {
        // Google Translate API çağrısı
        translateText(userInput: userInput, targetLanguage: "tr") { result in
            switch result {
            case .success(let translation):
                translatedText = translation
            case .failure(let error):
                print("Çeviri Hatası: \(error.localizedDescription)")
            }
        }
    }
    
    func translateText(userInput: String, targetLanguage: String, completion: @escaping (Result<String, Error>) -> Void) {
        let apiKey = "AIzaSyA9ey3XuH0rwFFLNHkzDY9HnD0GooHX1FE"
        let baseURL = "https://translation.googleapis.com/language/translate/v2"
        let sourceLanguage = "en" // İngilizce örnek olarak
        
        guard var urlComponents = URLComponents(string: baseURL) else { return }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: userInput), // Değişiklik yapıldı
            URLQueryItem(name: "source", value: sourceLanguage),
            URLQueryItem(name: "target", value: targetLanguage),
            URLQueryItem(name: "key", value: apiKey)
        ]
        
        guard let url = urlComponents.url else { return }
        
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            if let data = data {
                do {
                    let result = try JSONDecoder().decode(TranslationResponse.self, from: data)
                    let translatedText = result.data.translations.first?.translatedText ?? "Çeviri bulunamadı."
                    completion(.success(translatedText))
                } catch {
                    completion(.failure(error))
                }
            }
        }.resume()
    }
}

struct TranslationResponse: Codable {
    let data: TranslationData
}

struct TranslationData: Codable {
    let translations: [Translation]
}

struct Translation: Codable {
    let translatedText: String
}
