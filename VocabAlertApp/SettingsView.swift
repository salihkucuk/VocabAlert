//
//  SettingsView.swift
//  VocabAlertApp
//
//  Created by MSK on 21.11.2023.
//

import Foundation
import SwiftUI
import FirebaseAuth

struct SettingsView: View {
    @State var isReminderEnabled = false
    @State var selectedInterval = 30
    @State var customTime = ""
    @State var savedTime = ""
    let belirliSureTag = 150
    @State var isNavigationActive = false
    @State var showingLogoutAlert = false
    @State var numberOfNotifications: Int

    var body: some View {
            VStack {
                Spacer()

                VStack(alignment: .center, spacing: 20) {
                    Picker("Hatırlatma Aralığı", selection: $selectedInterval) {
                        Text("30 Dakika").tag(30)
                        Text("1 Saat").tag(60)
                        Text("2 Saat").tag(120)
                        Text("Belirli Bir Süre").tag(belirliSureTag)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .onChange(of: selectedInterval) { newValue in
                        if newValue != belirliSureTag {
                            customTime = ""
                            savedTime = "\(newValue) dakika"
                        }
                    }

                    if selectedInterval == belirliSureTag {
                        TextField("Belirli Bir Süre Girin (dakika cinsinden)", text: $customTime)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                    }

                    Toggle("Hatırlatmaları Etkinleştir", isOn: $isReminderEnabled)
                        .onChange(of: isReminderEnabled) { newValue in
                            saveSettingsToFirestore(isReminderEnabled: newValue, selectedInterval: selectedInterval, customTime: customTime)
                        }
                        .foregroundColor(Color.black)
                        .padding()
                }
                .padding()

                Spacer()
                Button(action: {
                    showingLogoutAlert = true
                }) {
                    Text("Çıkış Yap")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding([.top, .bottom], 20)
                }
                .padding([.leading, .trailing], 20)
                .background(
                              NavigationLink(destination: LoginSignUpView(), isActive: $isNavigationActive) {
                                  EmptyView()
                              }
                                .alert(isPresented: $showingLogoutAlert) {
                                    Alert(
                                        title: Text("Çıkış Yap"),
                                        message: Text("Çıkış yapmak istediğinize emin misiniz?"),
                                        primaryButton: .destructive(Text("Evet")) {
                                            logout()
                                            isNavigationActive = true
                                        },
                                        secondaryButton: .cancel(Text("Hayır"))
                                    )}
            )}
            .onAppear {
                        loadSettingsFromFirestore { isEnabled, interval, time in
                            isReminderEnabled = isEnabled
                            selectedInterval = interval
                            customTime = time
                        }
                    }
        }
                              
        func saveSettingsToFirestore(isReminderEnabled: Bool, selectedInterval: Int, customTime: String) {
            guard let userId = Auth.auth().currentUser?.uid else {
                print("Kullanıcı oturumu açık değil.")
                return
            }

            let settings = [
                "isReminderEnabled": isReminderEnabled,
                "selectedInterval": selectedInterval,
                "customTime": customTime
            ] as [String : Any]

            db.collection("user_settings").document(userId).setData(settings) { error in
                if let error = error {
                    print("Ayarları kaydederken hata: \(error.localizedDescription)")
                } else {
                    print("Ayarlar başarıyla kaydedildi.")
                }
            }
            scheduleNotifications(isReminderEnabled: isReminderEnabled, selectedInterval: selectedInterval, numberOfNotifications: numberOfNotifications)
        }
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Bildirim izinleri kabul edildi.")
            } else if let error = error {
                print("Bildirim izinleri hatası: \(error)")
            }
        }
    }

    func loadSettingsFromFirestore(completion: @escaping (Bool, Int, String) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("Kullanıcı oturumu açık değil.")
            return
        }

        db.collection("user_settings").document(userId).getDocument { document, error in
            if let error = error {
                print("Ayarları yüklerken hata: \(error.localizedDescription)")
                return
            }

            if let document = document, document.exists {
                let data = document.data()
                let isReminderEnabled = data?["isReminderEnabled"] as? Bool ?? false
                let selectedInterval = data?["selectedInterval"] as? Int ?? 30
                let customTime = data?["customTime"] as? String ?? ""
                completion(isReminderEnabled, selectedInterval, customTime)
            } else {
                print("Belge mevcut değil.")
            }
        }
    }
    func scheduleNotifications(isReminderEnabled: Bool, selectedInterval: Int, numberOfNotifications: Int) {
        let center = UNUserNotificationCenter.current()

        // Önceki tüm planlanmış bildirimleri iptal edin
        center.removeAllPendingNotificationRequests()

        guard isReminderEnabled else { return }

        for _ in 1...numberOfNotifications {
            let randomWordA = fetchRandomWord() // Her bildirim için yeni bir kelime alın
            let content = UNMutableNotificationContent()
            content.title = "Kelime Zamanı"
            content.body = "\(randomWordA)"
            content.sound = UNNotificationSound.default

            // Bildirimin ne zaman tetikleneceğini belirleyin
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(selectedInterval * 4), repeats: false)

            // Bildirim isteğini oluşturun
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

            // Bildirimi planlayın
            center.add(request) { error in
                if let error = error {
                    print("Bildirim planlanırken hata: \(error.localizedDescription)")
                }
            }
        }
    }

    func fetchRandomWord() -> (englishWord: String, targetWord: String) {
            let englishWord = randomWord?.englishWord[0] ?? ""
            let targetWord = randomWord?.targetWord ?? ""
            return (englishWord, targetWord)
    }

    func logout() {
        do {
            try Auth.auth().signOut()
            // Oturum kapatma başarılı oldu, ek işlemleri buraya ekleyebilirsiniz
            print("Oturum kapatıldı.")
        } catch let signOutError as NSError {
            // Oturum kapatma hatası, hata işleme mekanizmasını buraya ekleyin
            print("Oturum kapatma hatası: \(signOutError.localizedDescription)")
        }
    }
}
