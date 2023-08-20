////
////  SignUpViewController.swift
////  manga
////
////  Created by Ryosuke Takaoka on 2023/07/23.
////
////
//
//import UIKit
////import Firebase
//
//class SignUpViewController: UIViewController {
//    
//    var auth: Auth!
//    
//    @IBOutlet private weak var nameTextField: UITextField!
//    @IBOutlet private weak var emailTextField: UITextField!
//    @IBOutlet private weak var passwordTextField: UITextField!
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        auth = Auth.auth()
//        FirebaseApp.configure()
//    }
//    
//    override func viewDidAppear(_ animated: Bool) {
//        super.viewDidAppear(animated)
//        if auth.currentUser != nil {
//            auth.currentUser?.reload(completion: { error in
//                if error == nil {
//                    if self.auth.currentUser?.isEmailVerified == true {
//                        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "toHome") as! UITabBarController
//                        
//                        let nextUser = AppUser(
//                            data: [
//                                "userID": self.auth.currentUser?.uid,
//                                "userName": self.auth.currentUser?.displayName,
//                                "userEmail": self.auth.currentUser?.email
//                            ]
//                        )
//                        
//                        (nextVC.viewControllers![0] as! UserInformationViewController).me = nextUser //値を渡す
//
//                        //遷移先の画面をフルスクリーンで表示
//                        nextVC.modalPresentationStyle = .fullScreen
//                        self.present(nextVC, animated: true, completion: nil) // 画面遷移
//
//
//                    } else if self.auth.currentUser?.isEmailVerified == false {
//                        let alert = UIAlertController(title: "まだメール認証が完了していません。", message: "確認用メールを送信しているので確認をお願いします。", preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
//                    }
//                }
//            })
//        }
//    }
//    
//    @IBAction func reload()  {
//        if auth.currentUser != nil {
//            auth.currentUser?.reload(completion: { error in
//                if error == nil {
//                    if self.auth.currentUser?.isEmailVerified == true {
//                        let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "toHome") as! UITabBarController
//                        
//                        let nextUser = AppUser(
//                            data: [
//                                "userID": self.auth.currentUser?.uid,
//                                "userName": self.auth.currentUser?.displayName,
//                                "userEmail": self.auth.currentUser?.email
//                            ]
//                        )
//                        
//                        (nextVC.viewControllers![0] as! UserInformationViewController).me = nextUser //値を渡す
//
//                        //遷移先の画面をフルスクリーンで表示
//                        nextVC.modalPresentationStyle = .fullScreen
//                        self.present(nextVC, animated: true, completion: nil) // 画面遷移
//
//
//                    } else if self.auth.currentUser?.isEmailVerified == false {
//                        let alert = UIAlertController(title: "まだメール認証が完了していません。", message: "確認用メールを送信しているので確認をお願いします。", preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
//                    }
//                }
//            })
//        }
//    }
//    
//
//    
//    private func showErrorIfNeeded(_ errorOrNil: Error?) {
//        // エラーがなければ何もしません
//        guard let error = errorOrNil else { return }
//        
//        let message = "エラーが起きました"
//        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        present(alert, animated: true, completion: nil)
//    }
//    
//    
//    @IBAction private func didTapSignUpButton() {
//        //もしなければ
//        let email = emailTextField.text ?? ""
//        let password = passwordTextField.text ?? ""
//        let name = nameTextField.text ?? ""
//        
//        auth.createUser(withEmail: email, password: password) { [weak self] result, error in
//            guard let self = self else { return }
//            if let user = result?.user {
//                let req = user.createProfileChangeRequest()
//                req.displayName = name
//                req.commitChanges() { [weak self] error in
//                    guard let self = self else { return }
//                    if error == nil {
//                        user.sendEmailVerification() { [weak self] error in
//                            guard let self = self else { return }
//                            if error == nil {
//                                // 仮登録完了画面へ遷移する処理
//                                if self.auth.currentUser?.isEmailVerified == true {
//                                    let nextVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "toHome") as! UITabBarController
//                                    
//                                    let nextUser = AppUser(
//                                        data: [
//                                            "userID": self.auth.currentUser?.uid,
//                                            "userName": self.auth.currentUser?.displayName,
//                                            "userEmail": self.auth.currentUser?.email
//                                        ]
//                                    )
//                                    
//                                    (nextVC.viewControllers![0] as! UserInformationViewController).me = nextUser //値を渡す
//
//                                    //遷移先の画面をフルスクリーンで表示
//                                    nextVC.modalPresentationStyle = .fullScreen
//                                    self.present(nextVC, animated: true, completion: nil) // 画面遷移
//
//
//                                } else if self.auth.currentUser?.isEmailVerified == false {
//                                    let alert = UIAlertController(title: "まだメール認証が完了していません。", message: "確認用メールを送信しているので確認をお願いします。", preferredStyle: .alert)
//                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                                    self.present(alert, animated: true, completion: nil)
//                                }
//                            }
//                            self.showErrorIfNeeded(error)
//                        }
//                    }
//                    self.showErrorIfNeeded(error)
//                }
//            }
//            self.showErrorIfNeeded(error)
//        }
//    }
//}
//
//
//    /*
//    // MARK: - Navigation
//
//    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        // Get the new view controller using segue.destination.
//        // Pass the selected object to the new view controller.
//    }
//    */
//
//
