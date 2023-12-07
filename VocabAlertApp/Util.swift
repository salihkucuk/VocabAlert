//
//  Util.swift
//  VocabAlertApp
//
//  Created by MSK on 4.12.2023.
//

import Foundation

class Util {
    static func loadWordJson(filename: String) -> [Word]? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Couldn't find \(filename) in main bundle.")
            return nil
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(LocalJsonData.self, from: data)
            return jsonData.words
        } catch {
            print("Error decoding JSON from \(filename): \(error)")
            return nil
        }
    }
}
