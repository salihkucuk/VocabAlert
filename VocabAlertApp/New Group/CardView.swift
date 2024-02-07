//
//  CardView.swift
//  VocabAlertApp
//
//  Created by MSK on 21.11.2023.
//

import SwiftUI

struct CardView: View {
    //MARK: Variables
    @State var backDegree = -90.0
    @State var frontDegree = 0.0
    @State var isFlipped = true
    @State var randomWord = Word(targetWord: "", englishWord: ["","","",""])
    
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
    func getRandomWord() {
        if let words = Util.loadWordJson(filename: "tr") {
            randomWord = words.randomElement() ?? Word(targetWord: "", englishWord: [])
        }
    }
    //MARK: View Body
    var body: some View {
        ZStack {
            Color.white//(red: 0.7, green: 0, blue: 0)
            CardFront(width: width, height: height, degree: $frontDegree, randomWord: $randomWord)
            CardBack(width: width, height: height, degree: $backDegree, randomWord: $randomWord)
            VStack {
                Spacer()
                Button(action: {
                    getRandomWord()
                }) {
                    Text("Kelime Getir")
                        .font(.system(size: 20))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding([.top, .bottom], 20)
                }
                .padding([.leading, .trailing], 20)
            }
        }.onTapGesture {
            flipCard ()
        }.onAppear{
            getRandomWord()
        }
    }
}

struct EsatPreviewww: PreviewProvider {
    static var previews: some View {
        CardView()
    }
}
