//
//  ContentViewModel.swift
//  FirstSwiftUIApp
//
//  Created by MSK on 28.10.2023.
//

import SwiftUI

class ContentViewModel {
    func loadWordJson(filename: String) -> [Word]? {
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
    func loadItemJson(filename: String) -> [Item]? {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Couldn't find \(filename) in main bundle.")
            return nil
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let jsonData = try decoder.decode(ItemsContainer.self, from: data)
            return jsonData.items
        } catch {
            print("Error decoding JSON from \(filename): \(error)")
            return nil
        }
    }

}



