//
//  CardBack.swift
//  VocabAlertApp
//
//  Created by MSK on 4.12.2023.
//

import SwiftUI

struct CardBack : View {
    let width : CGFloat
    let height : CGFloat
    @Binding var degree : Double
    @Binding var randomWord : Word

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.yellow)
                .frame(width: width, height: height)
                .shadow(color: .gray, radius: 2, x: 0, y: 0)
            Text(randomWord.targetWord)
                .font(.system(size: 60))
                .foregroundColor(Color.black)
                .frame(width: 300, height: 400)
                .padding()
        }.rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
    func fontSize(for word: String) -> CGFloat {
        let maxLength: CGFloat = 12 // Kelimenin maksimum karakter sayısı
        let baseFontSize: CGFloat = 60 // Temel font boyutu

        let length = CGFloat(word.count)
        return min(baseFontSize, (baseFontSize * maxLength) / length)
    }
}

/*struct EsatPrevieww: PreviewProvider {
    @State static var c: Double = 200.0
    static var previews: some View {
        CardBack(width: 500, height: 500, degree: $c)
    }
}*/
