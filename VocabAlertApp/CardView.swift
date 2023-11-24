//
//  CardView.swift
//  VocabAlertApp
//
//  Created by MSK on 21.11.2023.
//

import Foundation
import SwiftUI

struct CardFront : View {
    let width : CGFloat
    let height : CGFloat
    @Binding var degree : Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.yellow)
                .frame(width: width, height: height)
                .shadow(color: .gray, radius: 2, x: 0, y: 0)
            VStack(alignment: .leading){
                Text(randomWord?.englishWord[0] ?? "")
                    .font(.system(size: 50))
                    .foregroundColor(Color.black)
                    .multilineTextAlignment(.leading)
                    .padding()
                    .onAppear(perform: {
                        getRandomWord()
                    })
                Text(randomWord?.englishWord[1] ?? "")
                    .font(.system(size: 20))
                    .foregroundColor(Color.white)
                    .padding()
                    .multilineTextAlignment(.leading)
                Text(randomWord?.englishWord[2] ?? "")
                    .font(.system(size: 20))
                    .foregroundColor(Color.white)
                    .padding()
                    .multilineTextAlignment(.leading)
                Text(randomWord?.englishWord[3] ?? "")
                    .font(.system(size: 20))
                    .foregroundColor(Color.white)
                    .padding()
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
        }
        .rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
}

struct CardBack : View {
    let width : CGFloat
    let height : CGFloat
    @Binding var degree : Double
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(.yellow)
                .frame(width: width, height: height)
                .shadow(color: .gray, radius: 2, x: 0, y: 0)
            Text(randomWord?.targetWord ?? "")
                .font(.system(size: 60))
                .foregroundColor(Color.black)
                .frame(width: 300, height: 400)
                .padding()
                .onAppear(perform: {
                    getRandomWord()
                })
        }.rotation3DEffect(Angle(degrees: degree), axis: (x: 0, y: 1, z: 0))
    }
    func fontSize(for word: String) -> CGFloat {
        let maxLength: CGFloat = 12 // Kelimenin maksimum karakter sayısı
        let baseFontSize: CGFloat = 60 // Temel font boyutu

        let length = CGFloat(word.count)
        return min(baseFontSize, (baseFontSize * maxLength) / length)
    }
}

struct CardView: View {
    //MARK: Variables
    @State var backDegree = 0.0
    @State var frontDegree = -90.0
    @State var isFlipped = true
    
    let width : CGFloat = 350
    let height : CGFloat = 540
    let durationAndDelay : CGFloat = 0.3
    
    //MARK: Flip Card Function
    func flipCard () {
        isFlipped = !isFlipped
        if isFlipped {
            withAnimation(.linear(duration: durationAndDelay)) {
                backDegree = 90
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)){
                frontDegree = 0
            }
        } else {
            withAnimation(.linear(duration: durationAndDelay)) {
                frontDegree = -90
            }
            withAnimation(.linear(duration: durationAndDelay).delay(durationAndDelay)){
                backDegree = 0
            }
        }
    }
    //MARK: View Body
    var body: some View {
        ZStack {
            Color.green
            CardFront(width: width, height: height, degree: $frontDegree)
            CardBack(width: width, height: height, degree: $backDegree)
            VStack {
                Spacer()
                Button(action: {
                    // getRandomWord() fonksiyonunu çağırarak rastgele kelimeyi getir
                    getRandomWord()
                }) {
                    Text("Kelime Getir")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding([.top, .bottom], 20)
                }
                .padding([.leading, .trailing], 20)
            }
        }.onTapGesture {
            flipCard ()
        }
    }
}
