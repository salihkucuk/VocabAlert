//
//  Extension.swift
//  VocabAlertApp
//
//  Created by MSK on 4.12.2023.
//

import Foundation

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
