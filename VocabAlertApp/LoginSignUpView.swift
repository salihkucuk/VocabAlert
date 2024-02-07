//
//  LoginSignUpView.swift
//  FirstSwiftUIApp
//
//  Created by MSK on 28.10.2023.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginSignUpView: View {
    
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var email: String = ""
    @State private var isLogin: Bool = true
    @State private var isNavigation: Bool = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    @State private var navigateToCardView = false
    
    var body: some View {
        NavigationView{
            VStack {
                /*  Text("Welcome to VocabAlert")
                 .font(.largeTitle) // Büyük ve dikkat çekici bir font
                 .italic()
                 .foregroundColor(.white) // Mavi renk
                 .padding() // Etrafına boşluk ekleme
                 .background(Color.green) // Beyaz arka plan rengi
                 .cornerRadius(10) // Kenarları yuvarlaklaştırma
                 .shadow(radius: 10) // Gölge efekti
                 .padding()
                 
                 */
                
                Image("main")
                    .resizable() // Resmi yeniden boyutlandırılabilir yap
                    .aspectRatio(contentMode: .fill) // İçeriği dolduracak şekilde boyutlandır
                    .frame(height: 200) // Resmin yüksekliğini belirle
                    .clipped() // Çerçeve dışına taşan kısımları kırp
                    .cornerRadius(10) // Kenarları yuvarlaklaştır
                    .padding() // Etrafına boşluk ekle
                
                
                if !isLogin {
                    TextField("Kullanıcı adı", text: $username)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                        .padding([.leading, .trailing, .bottom], 20)
                }
                TextField("E-posta", text: $email)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                    .padding([.leading, .trailing, .bottom], 20)
                
                SecureField("Şifre", text: $password)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 10).stroke(Color.blue, lineWidth: 2))
                    .padding([.leading, .trailing, .bottom], 20)
                Button(action: {
                    if isLogin {
                        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                            if let error = error {
                                print("Giriş başarısız. Hata: \(error.localizedDescription)")
                                self.alertMessage = "E-posta veya Şifre Yanlış"
                                self.showAlert = true
                                
                            } else {
                                print("Giriş başarılı!")
                                isNavigation = true
                            }
                        }
                    } else {
                        signUpUser()
                    }
                }) {
                    Text(isLogin ? "Giriş Yap" : "Kayıt Ol")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding([.top, .bottom], 20)
                }
                .padding([.leading, .trailing], 20)
                
                Button("Şifremi Unuttum") {
                    resetPassword()
                }
                .padding()
                Button(action: {
                    isLogin.toggle()
                }) {
                    Text(isLogin ? "Hesabınız yok mu? Kayıt olun" : "Zaten hesabınız var mı? Giriş yapın")
                        .foregroundColor(.blue)
                }
                .padding([.top], 20)
                
                NavigationLink(destination: ContentView(), isActive: $isNavigation) {
                    EmptyView()
                }
            }
            .navigationBarHidden(true)
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Uyarı!"), message: Text(alertMessage), dismissButton: .default(Text("Tamam")))
            }
        }
    }
    func resetPassword() {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                // Hata mesajını göster
                self.alertMessage = error.localizedDescription
                self.showAlert = true
            } else {
                // Başarılı mesajını göster
                self.alertMessage = "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi."
                self.showAlert = true
            }
        }
    }
    func loginUser() {
            Auth.auth().signIn(withEmail: email, password: password) { [self] authResult, error in
                if error != nil {
                    // Hata işleme...
                } else {
                    isNavigation = true
                }
            }
        }
    func signUpUser() {
        isEmailTaken(email: self.email) { isEmailTaken in
            if username.isEmpty {
                    self.alertMessage = "Kullanıcı adı boş bırakılamaz."
                    self.showAlert = true
                    return
                }

            if isEmailTaken {
                self.alertMessage = "Bu email zaten kullanılıyor."
                self.showAlert = true
                return
            }
    
        isUsernameTaken(username: username) { isUsernameTaken in
            if isUsernameTaken {
                self.alertMessage = "Bu kullanıcı adı zaten kullanılıyor."
                self.showAlert = true
                return
            }

            // Kullanıcı adı mevcut değilse, e-posta kontrolüne geç
           

                // Kayıt işlemine devam et
                Auth.auth().createUser(withEmail: self.email, password: self.password) { authResult, error in
                    if let error = error {
                        print("Kayıt olma işlemi başarısız. Hata: \(error.localizedDescription)")
                        self.alertMessage = "Bu email zaten kullanılıyor."
                        self.showAlert = true
                    } else {
                        print("Kayıt işlemi başarılı!")
                        self.alertMessage = "Kayıt işlemi başarılı!"
                        self.showAlert = true
                        self.saveUsernameToFirestore(username: self.username)
                        self.isLogin = true // Burada değişiklik yapıldı
                    }
                }
            }
        }
    }

    func isUsernameTaken(username: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        let usersRef = db.collection("user_scores")

        usersRef.whereField("username", isEqualTo: username).getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Kullanıcı adı kontrolünde hata: \(error.localizedDescription)")
                completion(false)
            } else if querySnapshot!.documents.isEmpty {
                completion(false) // Kullanıcı adı mevcut değil
            } else {
                completion(true) // Kullanıcı adı zaten alınmış
            }
        }
    }

    func isEmailTaken(email: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().fetchSignInMethods(forEmail: email) { (signInMethods, error) in
            if let error = error {
                print("E-posta kontrolünde hata: \(error.localizedDescription)")
                completion(false)
            } else if signInMethods == nil {
                completion(false) // E-posta mevcut değil
            } else {
                completion(true) // E-posta zaten alınmış
            }
        }
    }
    func saveUsernameToFirestore(username: String) {
        // Firestore referansını al
        let db = Firestore.firestore()
        
        // Kullanıcının ID'sini al (Bu genellikle kullanıcı kaydı yapıldıktan sonra elde edilir)
        if let userId = Auth.auth().currentUser?.uid {
            // 'user_scores' koleksiyonunda bir doküman oluştur
            let userScoreDocument = db.collection("user_scores").document(userId)
            
            // 'username' alanını ekleyerek dokümanı güncelle
            userScoreDocument.setData(["username": username], merge: true) { error in
                if let error = error {
                    print("Firestore'a veri eklenirken hata oluştu: \(error.localizedDescription)")
                } else {
                    print("Firestore'a veri başarıyla eklendi.")
                }
            }
        } else {
            print("Kullanıcı ID'si bulunamadı.")
        }
    }
    
    
}
struct LoginSignUpView_Previews: PreviewProvider {
    static var previews: some View {
        LoginSignUpView()
    }
}


