import UIKit
import FirebaseAuth
import FirebaseFirestore
import PKHUD

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        errorLabel.text = ""
        setDismissKeybord()
    }
    
    @IBAction func signUpButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text, !name.isEmpty,
              let email = emailTextField.text, !email.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            errorLabel.text = "すべての項目を入力してください。"
            return
        }
        HUD.show(.labeledProgress(title: "", subtitle: "登録中です"))
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let error = error as NSError? {
                self.errorLabel.text = self.errorMessage(forErrorCode: AuthErrorCode.Code(rawValue: error.code))
                self.signUpButton.isEnabled = true
                return
            }
            
            if let user = authResult?.user {
                self.saveUserDataToFirestore(userId: user.uid, name: name, email: email) { success in
                    
                    self.signUpButton.isEnabled = true
                    
                    if success {
                        print("登録成功！")
                        
                        HUD.hide()
                        let alert = UIAlertController(title: "登録完了", message: "アカウントの登録が完了しました。", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            if let homeVC = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as? HomeViewController {
                                homeVC.modalPresentationStyle = .fullScreen
                                self.present(homeVC, animated: true, completion: nil)
                            }
                        })
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        self.errorLabel.text = "ユーザー情報の保存に失敗しました。"
                        // 必要に応じてAuthの登録解除処理を追加
                    }
                }
            }
        }
    }
    
    private func saveUserDataToFirestore(userId: String, name: String, email: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("users").document(userId).setData([
            "userId": userId,
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
    @IBAction func backButton (_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}

