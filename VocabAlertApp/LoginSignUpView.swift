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
    
    var body: some View {
        VStack {
            Image(systemName: "person.circle")
                .font(.system(size: 100))
                .padding()
                .foregroundColor(.blue)
            
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
    func signUpUser() {
        isEmailTaken(email: self.email) { isEmailTaken in
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


