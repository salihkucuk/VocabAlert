//
//  CustomButton.swift
//  VocabAlertApp
//
//  Created by MSK on 4.12.2023.
//

import SwiftUI

struct CustomButton: View {
    let text: String
    let action: () -> Void
    let color: Color
    var body: some View {
        Button(action: action) {
            Text(text)
                .fontWeight(.bold)
                .padding()
                .frame(maxWidth: .infinity)
                .background(color)
                .foregroundColor(.white)
                .cornerRadius(10)
                .shadow(radius: 5)
        }
        .padding()
    }
}
