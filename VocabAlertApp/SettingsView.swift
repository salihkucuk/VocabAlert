
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseFunctions

struct SettingsView: View {
    @State var showingLogoutAlert = false
    @State var showingDeleteAccountAlert = false
    @State var showingFeedbackView = false // Geri Bildirim View'ını göstermek için yeni bir state
    let db = Firestore.firestore()
    
    var body: some View {
        VStack {
            Button(action: {
                showingFeedbackView = true // Geri Bildirim View'ını aç
            }) {
                Text("Geri Bildirim Gönder")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.top, 20)
            }
            .padding([.leading, .trailing], 20)
            // Geri Bildirim View'ına geçiş
            NavigationLink(destination: FeedbackView(), isActive: $showingFeedbackView) {
                EmptyView()
            }
            Button(action: {
                showingLogoutAlert = true
            }) {
                Text("Çıkış Yap")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.orange)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding([.top, .bottom], 20)
            }
            .padding([.leading, .trailing], 20)
            .alert(isPresented: $showingLogoutAlert) {
                Alert(
                    title: Text("Çıkış Yap"),
                    message: Text("Çıkış yapmak istediğinize emin misiniz?"),
                    primaryButton: .destructive(Text("Evet")) {
                        logout()
                    },
                    secondaryButton: .cancel(Text("Hayır"))
                )
            }
            Spacer()
            Button(action: {
                showingDeleteAccountAlert = true
            })
            {  Text("Hesabı Sil")
                    .fontWeight(.bold)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.top, 20)
            }
            .padding([.leading, .trailing], 20)
            .alert(isPresented: $showingDeleteAccountAlert) {
                Alert(
                    title: Text("Hesabı Sil"),
                    message: Text("Hesabınızı silmek istediğinize emin misiniz? Bu işlem geri alınamaz."),
                    primaryButton: .destructive(Text("Sil")) {
                        deleteAccount()
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }
    func logout() {
        do {
            try Auth.auth().signOut()
            print("Oturum kapatıldı.")
        } catch let signOutError as NSError {
            print("Oturum kapatma hatası: \(signOutError.localizedDescription)")
        }
    }
    
    func deleteAccount() {
        guard let user = Auth.auth().currentUser else { return }
        
        // Firestore ve Firebase Auth hesabını silmek için ilgili işlemler
        // Örnek Firebase Firestore veri silme işlemi
        
        db.collection("user_scores").document(user.uid).delete { error in
            if let error = error {
                print("Firestore'dan veri silinirken hata: \(error.localizedDescription)")
                return
            } else{
                print("Kullanıcı verileri başarıyla silindi")
            }
            
            
            // Firebase Auth hesabını silmek için işlem
            user.delete { error in
                if let error = error {
                    print("Kullanıcı hesabı silinirken hata: \(error.localizedDescription)")
                } else {
                    print("Kullanıcı hesabı başarıyla silindi")
                    // Burada kullanıcıyı logout yaparak ana ekrana yönlendirebilirsiniz
                }
            }
        }
        
    }
    
}
