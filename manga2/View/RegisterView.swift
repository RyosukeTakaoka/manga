import SwiftUI
import UIKit

struct RegisterUIView: View {
    var viewController = SignUpViewController()
    
    @State var imputName: String = ""
    @State var inputEmail: String = ""
    @State var inputPassword: String = ""
    @State private var selectedImage: UIImage? = nil
    @State private var showImagePicker: Bool = false
    @State private var isPresented: Bool = false
    
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isLoading: Bool = false
    
    // 画面遷移用のEnvironment変数
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    Spacer(minLength: 20)
                    
                    // タイトル
                    Text("SwiftUI App")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.black)
                    
                    // プロフィール画像選択部分
                    VStack(spacing: 12) {
                        Button(action: {
                            showImagePicker = true
                        }) {
                            ZStack {
                                if let selectedImage = selectedImage {
                                    Image(uiImage: selectedImage)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                        .overlay(Circle().stroke(Color.blue, lineWidth: 3))
                                } else {
                                    Circle()
                                        .fill(Color.gray.opacity(0.3))
                                        .frame(width: 120, height: 120)
                                        .overlay(
                                            VStack {
                                                Image(systemName: "person.fill.badge.plus")
                                                    .font(.system(size: 30))
                                                    .foregroundColor(.gray)
                                                Text("画像を選択")
                                                    .font(.caption)
                                                    .foregroundColor(.gray)
                                            }
                                        )
                                }
                            }
                        }
                        
                        Text("プロフィール画像")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    
                    // 入力フィールド
                    VStack(spacing: 16) {
                        CustomTextField(placeholder: "名前", text: $imputName)
                        CustomTextField(placeholder: "メールアドレス", text: $inputEmail)
                            .keyboardType(.emailAddress)
                            .textContentType(.emailAddress)
                            .autocapitalization(.none)
                        
                        SecureField("パスワード", text: $inputPassword)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                            .frame(maxWidth: 320)
                    }
                    
                    Spacer(minLength: 20)
                    
                    // ボタン
                    VStack(spacing: 16) {
                        // 新規登録ボタン
                        Button(action: {
                            registerUser()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.8)
                                    Text("登録中...")
                                } else {
                                    Text("新規登録")
                                }
                            }
                            .fontWeight(.medium)
                            .frame(maxWidth: 320)
                            .foregroundColor(.white)
                            .padding(16)
                            .background(isLoading ? Color.gray : Color.blue)
                            .cornerRadius(8)
                        }
                        .disabled(isLoading)
                        
                        // 戻るボタン
                        Button(action: {
                            presentationMode.wrappedValue.dismiss()
                        }) {
                            Text("戻る")
                                .fontWeight(.medium)
                                .frame(maxWidth: 320)
                                .foregroundColor(.white)
                                .padding(16)
                                .background(Color.gray)
                                .cornerRadius(8)
                        }
                        .disabled(isLoading)
                    }
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("エラー"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                    }
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal, 40)
            }
            .background(Color.white)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(selectedImage: $selectedImage)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
    
    // 登録処理
    private func registerUser() {
        // バリデーション
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
        
        if inputPassword.count < 6 {
            alertMessage = "パスワードは6文字以上で入力してください"
            showAlert = true
            return
        }
        
        isLoading = true
        
        // ViewControllerのselectedImageを更新
        viewController.selectedImage = selectedImage
        
        viewController.Register(name: imputName, email: inputEmail, password: inputPassword, image: selectedImage) { success in
            DispatchQueue.main.async {
                self.isLoading = false
                
                if success {
                    print("登録成功")
                    // 成功時のアラートを表示
                    let alert = UIAlertController(title: "登録完了", message: "アカウントの登録が完了しました。", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                        self.viewController.move1()
                    })
                    self.viewController.present(alert, animated: true)
                } else {
                    print("登録失敗")
                    self.alertMessage = "登録に失敗しました。もう一度お試しください。"
                    self.showAlert = true
                }
            }
        }
    }
    
    // メールアドレスバリデーション関数
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: email)
    }
}

// カスタムテキストフィールド
struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        TextField(placeholder, text: $text)
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(8)
            .frame(maxWidth: 320)
            .disableAutocorrection(true)
    }
}

// 画像ピッカー
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Environment(\.presentationMode) private var presentationMode
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let editedImage = info[.editedImage] as? UIImage {
                parent.selectedImage = editedImage
            } else if let originalImage = info[.originalImage] as? UIImage {
                parent.selectedImage = originalImage
            }
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}

struct LoginViewControllerWrapper: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateViewController(identifier: "LoginViewController")
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {}
}
