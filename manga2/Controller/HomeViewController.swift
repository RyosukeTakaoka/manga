//
//  HomeViewController.swift
//  manga2
//
//  Created by Ryosuke Takaoka on 2024/01/28.
//

import UIKit
import SwiftUI

class HomeViewController: UIViewController {
    
    var selectedPost: Post!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // SwiftUIのHomeViewをホスティング
        let homeView = HomeView { selectedPost in
            self.selectedPost = selectedPost
            self.nabigateToDetailView()
        }
        let hostingController = UIHostingController(rootView: homeView)
        
        // HostingControllerのビューを子ビューとして追加
        addChild(hostingController)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
    }
    
    private func nabigateToDetailView() {
        performSegue(withIdentifier: "toDetailsViewController", sender: self)
        print("画面遷移完了")
    }
    //セグエ実行前の処理
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //セグエの識別子確認
        if segue.identifier == "toDetailsViewController" {
            //セグエ先のViewControllerの取得
            let destinationVC = segue.destination as! DetailsViewController
            destinationVC.post = selectedPost
        }
    }
    
    
}

