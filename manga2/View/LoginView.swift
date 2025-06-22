import SwiftUI

struct LoginUIView: View {
    var viewController = LoginViewController()
    
    @State var inputEmail: String = ""
    @State var inputPassword: String = ""
    @State private var isPresented: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text("SwiftUI App")
                    .font(.system(size: 48, weight: .heavy))
                
                VStack(spacing: 24) {
                    TextField("Mail address", text: $inputEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 280)
                    
                    SecureField("Password", text: $inputPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 280)
                }
                .frame(height: 200)
                
                Button(action: {
                    viewController.Login(email: inputEmail, password: inputPassword) { success in
                        if success {
                            print("ログイン成功")
                            viewController.move1()
                        } else {
                            print("ログイン失敗")
                        }
                    }
                }) {
                    Text("Login")
                        .fontWeight(.medium)
                        .frame(minWidth: 160)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                }



                
                Button(action: {
                    isPresented = true
                }) {
                    Text("新規登録")
                        .fontWeight(.medium)
                        .frame(minWidth: 160)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color.accentColor)
                        .cornerRadius(8)
                }
                .fullScreenCover(isPresented: $isPresented) {
                    SignUpViewControllerWrapper()
                }
            }
        }
    }
}
struct SignUpViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(identifier: "SignUpViewController")
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
