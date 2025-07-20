import UIKit
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PKHUD
import SwiftUI

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var selectedImage: UIImage?
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var backButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // SwiftUIのHomeViewをホスティング
        let registerView = RegisterUIView(viewController: self)
        let hostingController = UIHostingController(rootView: registerView)
        
        // HostingControllerのビューを子ビューとして追加
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
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
                HUD.hide()
                return
            }
            
            if let user = authResult?.user {
                // 画像がある場合は画像をアップロードしてからユーザー情報を保存
                if let image = self.selectedImage {
                    self.uploadImageToFirebase(image: image, userId: user.uid) { imageUrl in
                        self.saveUserDataToFirestore(userId: user.uid, name: name, email: email, imageUrl: imageUrl) { success in
                            self.handleRegistrationResult(success: success)
                        }
                    }
                } else {
                    // 画像がない場合はそのままユーザー情報を保存
                    self.saveUserDataToFirestore(userId: user.uid, name: name, email: email, imageUrl: nil) { success in
                        self.handleRegistrationResult(success: success)
                    }
                }
            }
        }
    }
    
    private func uploadImageToFirebase(image: UIImage, userId: String, completion: @escaping (String?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let imageRef = storageRef.child("profile_images/\(userId).jpg")
        
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            if let error = error {
                print("画像アップロードエラー: \(error)")
                completion(nil)
                return
            }
            
            imageRef.downloadURL { url, error in
                if let error = error {
                    print("画像URL取得エラー: \(error)")
                    completion(nil)
                } else {
                    completion(url?.absoluteString)
                }
            }
        }
    }
    
    private func saveUserDataToFirestore(userId: String, name: String, email: String, imageUrl: String?, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        var userData: [String: Any] = [
            "userId": userId,
            "name": name,
            "email": email,
            "createdAt": Timestamp(date: Date())
        ]
        
        if let imageUrl = imageUrl {
            userData["profileImageUrl"] = imageUrl
        }
        
        db.collection("users").document(userId).setData(userData) { error in
            if let error = error {
                print("Firestoreへのデータ保存エラー: \(error)")
                completion(false)
            } else {
                print("Firestoreへのユーザーデータ保存成功！")
                completion(true)
            }
        }
    }
    
    private func handleRegistrationResult(success: Bool) {
        self.signUpButton.isEnabled = true
        HUD.hide()
        
        if success {
            print("登録成功！")
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
    
    func Register(name: String, email: String, password: String, image: UIImage?, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] authResult, error in
            guard let self = self else { return }
            
            if let user = authResult?.user {
                // 画像がある場合は画像をアップロードしてからユーザー情報を保存
                if let image = image {
                    self.uploadImageToFirebase(image: image, userId: user.uid) { imageUrl in
                        self.saveUserDataToFirestore(userId: user.uid, name: name, email: email, imageUrl: imageUrl) { success in
                            completion(success)
                        }
                    }
                } else {
                    // 画像がない場合はそのままユーザー情報を保存
                    self.saveUserDataToFirestore(userId: user.uid, name: name, email: email, imageUrl: nil) { success in
                        completion(success)
                    }
                }
            } else {
                completion(false)
            }
        }
    }
    
    //画面遷移
    func move1() {
        self.performSegue(withIdentifier: "toBarController2", sender: nil)
    }
    
    func presentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        self.present(picker, animated: true)
    }
    
    // 選択後の処理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            selectedImage = editedImage
        } else if let originalImage = info[.originalImage] as? UIImage {
            selectedImage = originalImage
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}
