
import SwiftUI
import Firebase
import FirebaseFunctions


struct FeedbackView: View {
    @State private var feedback: String = ""
    @State private var isSending: Bool = false
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""

    var body: some View {
        VStack {
            Text("Geri Bildiriminizi Yazın")
                .font(.title)

            TextEditor(text: $feedback)
                .border(Color.gray, width: 1)
                .padding()

            Button(action: {
                sendFeedback()
            }) {
                Text("Geri Bildirim Gönder")
            }
            .disabled(feedback.isEmpty)
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Bildirim"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
            }
        }
        .padding()
    }

    func sendFeedback() {
        guard !feedback.isEmpty else { return }
        isSending = true

        let functions = Functions.functions()
        functions.httpsCallable("sendFeedback").call(["feedback": feedback]) { result, error in
            isSending = false

            if let error = error as NSError? {
                if error.domain == FunctionsErrorDomain {
                    alertMessage = "Geri bildirim gönderilirken hata oluştu: \(error.localizedDescription)"
                }
                showAlert = true
                return
            }

            if let resultData = result?.data as? [String: Any],
               let message = resultData["message"] as? String {
                alertMessage = message
                showAlert = true
            }

            feedback = "" // Geri bildirim başarıyla gönderildikten sonra metin alanını sıfırla
        }
    }
}

