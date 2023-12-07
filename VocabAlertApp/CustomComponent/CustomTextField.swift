//
//  CustomTextField.swift
//  VocabAlertApp
//
//  Created by MSK on 4.12.2023.
//

import SwiftUI

struct CustomTextField: View {
    let placeholder: Text
    @Binding var text: String
    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty { placeholder }
            TextField("", text: $text)
        }
    }
}
