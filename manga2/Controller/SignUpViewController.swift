import UIKit
import FirebaseAuth
import FirebaseFirestore

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text = ""
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            errorLabel.text = "すべての項目を入力してください。"
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error as NSError? {
                self.errorLabel.text =  self.errorMessage(forErrorCode: AuthErrorCode.Code(rawValue: error.code))

                return
            }
            
            // 登録成功時の処理: Firestoreにユーザー情報を保存
            if let user = authResult?.user {
                self.saveUserDataToFirestore(userId: user.uid, name: name, email: email) { success in
                    if success {
                        print("登録成功！")
                        // ログイン後の画面へ遷移するなどの処理
                        // 例: self.navigationController?.popViewController(animated: true)
                    } else {
                        self.errorLabel.text = "ユーザー情報の保存に失敗しました。"
                        // 必要に応じてFirebase Authenticationのユーザーを削除する処理を追加
                    }
                }
            }
        }
    }
    
    private func saveUserDataToFirestore(userId: String, name: String, email: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData([
            "name": name,
            "email": email
        ]) { error in
            if let error = error {
                print("Firestoreへのデータ保存エラー: \(error)")
                completion(false)
            } else {
                print("Firestoreへのユーザーデータ保存成功！")
                completion(true)
            }
        }
    }
    
    private func errorMessage(forErrorCode errorCode: AuthErrorCode.Code?) -> String {
        guard let errorCode = errorCode else {
            return "不明なエラーが発生しました。"
        }
        switch errorCode {
        case .emailAlreadyInUse:
            return "このメールアドレスは既に登録されています。"
        case .invalidEmail:
            return "無効なメールアドレスです。"
        case .weakPassword:
            return "パスワードが脆弱です。6文字以上のパスワードを入力してください。"
        case .userNotFound:
            return "登録されていないメールアドレスです。"
        case .wrongPassword:
            return "パスワードが間違っています。"
        case .networkError:
            return "ネットワークエラーが発生しました。"
        default:
            return "登録に失敗しました。しばらくしてから再度お試しください。"
        }
    }

}

