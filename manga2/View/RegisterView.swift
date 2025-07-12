import SwiftUI

struct RegisterUIView: View {
    var viewController = SignUpViewController()
    
    @State var imputName: String = ""
    @State var inputEmail: String = ""
    @State var inputPassword: String = ""
    @State private var isPresented: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    // 画面遷移用のEnvironment変数
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 40) {
                Spacer()
                
                // タイトル
                Text("SwiftUI App")
                    .font(.system(size: 40, weight: .heavy))
                    .foregroundColor(.black)
                
                Spacer()
                
                // 入力フィールド
                VStack(spacing: 16) {
                    TextField("name", text: $imputName)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .frame(maxWidth: 280)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    TextField("email", text: $inputEmail)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .frame(maxWidth: 280)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    SecureField("password", text: $inputPassword)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(8)
                        .frame(maxWidth: 280)
                }
                
                Spacer()
                
                // ボタン
                VStack(spacing: 16) {
                    // 新規登録ボタン
                    Button(action: {
                        if imputName.isEmpty || inputEmail.isEmpty || inputPassword.isEmpty {
                            alertMessage = "すべての項目を入力してください。"
                            showAlert = true
                            return
                        }
                        
                        if !isValidEmail(inputEmail) {
                            alertMessage = "メールアドレスの形式が正しくありません"
                            showAlert = true
                            return
                        }
                        
                        viewController.Register(name: imputName, email: inputEmail, password: inputPassword) { success in
                            if success {
                                print("登録成功")
                                viewController.move1()
                            } else {
                                print("登録失敗")
                                alertMessage = "登録に失敗しました"
                                showAlert = true
                            }
                        }
                    }) {
                        Text("新規登録")
                            .fontWeight(.medium)
                            .frame(maxWidth: 280)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.blue)
                            .cornerRadius(8)
                    }
                    
                    // 戻るボタン
                    Button(action: {
                        // 前の画面に戻る処理
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text("戻る")
                            .fontWeight(.medium)
                            .frame(maxWidth: 280)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(Color.gray)
                            .cornerRadius(8)
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("エラー"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
            }
            .padding(.horizontal, 40)
            .background(Color.white)
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

struct LoginViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(identifier: "LoginViewController")
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
