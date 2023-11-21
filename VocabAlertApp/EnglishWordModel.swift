//
//  EnglishWordModel.swift
//  FirstSwiftUIApp
//
//  Created by MSK on 28.10.2023.
//

import Foundation

// MARK: - Word
struct LocalJsonData: Decodable {
    let words: [Word]
}
struct Word: Decodable {
    let targetWord: String
    let englishWord: [String]
}
struct ItemsContainer: Decodable {
    let items: [Item]
}
struct Item: Decodable {
    var id: Int
    var wordQ: String
    var wordA: String
    var options: [String]
}
