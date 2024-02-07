//
//  CardFront.swift
//  VocabAlertApp
//
//  Created by MSK on 4.12.2023.
//

import SwiftUI

struct CardFront : View {
    let width : CGFloat
    let height : CGFloat
    @Binding var degree : Double
    @Binding var randomWord : Word
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.orange)
                .frame(width: width, height: height)
                .shadow(color: .gray, radius: 2, x: 0, y: 0)
            VStack(alignment: .leading){
                Text(randomWord.englishWord[0])
                    .font(.system(size: 50))
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.center) // Metni ortalamak genellikle daha iyi görünür
                    .lineLimit(1) // Metni tek satırda sınırla
                    .minimumScaleFactor(0.5) // Metni, orijinal boyutunun %50'sine kadar küçültebilir
                    .padding()
                Text(randomWord.englishWord[1])
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding()
                    .multilineTextAlignment(.leading)
                Text(randomWord.englishWord[2])
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding()
                    .multilineTextAlignment(.leading)
                Text(randomWord.englishWord[3])
                    .font(.system(size: 20))
                    .fontWeight(.bold)
                    .foregroundColor(Color.white)
                    .padding()
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(width: width, height: height)
            .padding()
        }
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}

/*struct EsatPreviewww: PreviewProvider {
    @State static var c: Double = 00.0
    static var previews: some View {
        CardFront(width: 200, height: 500, degree: $c)
    }
}*/
