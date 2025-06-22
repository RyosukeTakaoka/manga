//
//  LoginViewController.swift
//  manga2
//
//  Created by Ryosuke Takaoka on 2025/05/11.
//

import UIKit
import SwiftUI
import FirebaseAuth

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // SwiftUIのHomeViewをホスティング
        let loginView =  LoginUIView(viewController: self)
        let hostingController = UIHostingController(rootView: loginView)
        
        // HostingControllerのビューを子ビューとして追加
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }

    //画面遷移
    func move1() {
        self.performSegue(withIdentifier: "toBarController", sender: nil)
    }
    
    func Login(email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            if let _ = authResult?.user {
                completion(true)  // 成功時
            } else {
                completion(false) // 失敗時
            }
        }
    }
}
