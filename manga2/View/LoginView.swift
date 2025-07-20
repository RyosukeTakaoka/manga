import SwiftUI

struct LoginView: View {
    var viewController = LoginViewController()
    
    @State var inputEmail: String = ""
    @State var inputPassword: String = ""
    @State private var isPresented: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Text("SwiftUI App")
                    .font(.system(size: 48, weight: .heavy))
                
                VStack(spacing: 24) {
                    // ここにcontentTypeを追加
                    TextField("Mail address", text: $inputEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 280)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)  // ★ここを追加
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("Password", text: $inputPassword)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(maxWidth: 280)
                }
                .frame(height: 200)
                
                Button(action: {
                    if !isValidEmail(inputEmail) {
                        alertMessage = "メールアドレスの形式が正しくありません"
                        showAlert = true
                        return
                    }
                    viewController.Login(email: inputEmail, password: inputPassword) { success in
                        if success {
                            print("ログイン成功")
                            viewController.move1()
                        } else {
                            print("ログイン失敗")
                            alertMessage = "ログインに失敗しました"
                            showAlert = true
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
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("エラー"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
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
        .contentShape(Rectangle()) // タップ可能な領域を拡張
        .onTapGesture {
            // キーボードを閉じる
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    // メールアドレスバリデーション関数
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}

struct SignUpViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(identifier: "SignUpViewController")
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
