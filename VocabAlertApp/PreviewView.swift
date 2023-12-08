import SwiftUI

struct PreviewView: View {
    let images = ["image1", "image2", "image3"]
    @State private var currentIndex = 0

    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                Text("Hoş Geldiniz!")
                    .font(.largeTitle)
                    .foregroundColor(.blue)
                    .fontWeight(.bold)
                    .padding()

                HStack {
                    Button(action: {
                        currentIndex = (currentIndex - 1 + images.count) % images.count
                    }) {
                        Image(systemName: "arrow.left.circle")
                            .foregroundColor(.gray)
                            .padding()
                    }

                    Spacer()

                    Button(action: {
                        currentIndex = (currentIndex + 1) % images.count
                    }) {
                        Image(systemName: "arrow.right.circle")
                            .foregroundColor(.gray)
                            .padding()
                    }
                }

                NavigationLink(destination: destinationView(for: currentIndex)) {
                    Image(images[currentIndex])
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .cornerRadius(10)
                        .frame(width: 500, height: 500)
                        .padding()
                }

                Spacer()

                NavigationLink(destination: LoginSignUpView()) {
                    Text("Giriş Yap veya Kayıt Ol")
                        .foregroundColor(.white)
                        .frame(width: 280, height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
    }

    @ViewBuilder
    private func destinationView(for index: Int) -> some View {
        switch index {
        case 0:
            QuizView() // image1 için QuizView
        case 1:
            RandomWordView()
        case 2:
            CardView() // image2 için CardView
        // Burada diğer durumlar için ek view'lar ekleyebilirsiniz
        default:
            Text("Default View")
        }
    }
}

struct PreviewView_Previews: PreviewProvider {
    static var previews: some View {
        PreviewView()
    }
}
