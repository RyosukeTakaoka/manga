//
//  ViewController.swift
//  Message2
//
//  Created by Ryosuke Takaoka on 2024/08/04.
//

import UIKit
import Firebase
import PhotosUI

class PostViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PHPickerViewControllerDelegate {
    //tableViewの関連付け
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    let db = Firestore.firestore()
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //dataSourceをself
        tableView.dataSource = self
        //delegateをself
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        fetchPosts()
    }
    
    @IBAction func postButtonTapped(_ sender: UIButton) {
        // titleが空でないことを確認
        guard let title = titleTextField.text, !title.isEmpty else {
            // テキストが空の場合の処理
            showAlert(message: "タイトルを入力してください。")
            return
        }
        
        // thumbnailが空でないことを確認
        guard let thumbnail = thumbnailImageView.image else {
            // サムネイル画像が空の場合の処理
            showAlert(message: "サムネイル画像を選択してください。")
            return
        }
        
        // 空でない場合、取得したtextとthumbnailを引数として渡して保存処理
        savePostToFirestore(title: title, thumbnail: thumbnail)
    }

    // アラートを表示する関数
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "入力エラー", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }

    // 投稿後に特定のタブ（例えば1番目のタブ）に遷移
    func savePostToFirestore(title: String, thumbnail: UIImage) {
        let uuid = UUID()
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createdAt = formatter.string(from: currentDate)
        
        let post = Post(id: uuid.uuidString, title: title, userId: "exampleUserId", postImages: [], thumbnailPost: "", createdAt: createdAt)
        
        let postData: [String: Any] = [
            "id": post.id,
            "title": post.title,
            "userId": post.userId,
            "postImages": post.postImages,
            "thumbnailPost": post.thumbnailPost,
            "createdAt": createdAt
        ]
        
        // Firestoreにデータを保存
        db.collection("posts").document(uuid.uuidString).setData(postData) { error in
            if let error = error {
                print("Error saving post to Firestore: \(error.localizedDescription)")
                // エラーメッセージをアラートで表示
                DispatchQueue.main.async {
                    self.showAlert(message: "投稿の保存に失敗しました。再試行してください。")
                }
            } else {
                print("Post saved successfully!")
                DispatchQueue.main.async {
                    // Firestore保存成功後に`posts`配列を更新
                    self.posts.append(post)
                    self.tableView.reloadData()
                    
                    // アラートで通知
                    self.completeAlert(message: "投稿できました！")
                }
            }
        }
    }

    // アラートを表示する関数
    func completeAlert(message: String) {
        let alertController = UIAlertController(title: "確認", message: message, preferredStyle: .alert)
        
        // OKボタンが押されたときの処理
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            // OKボタンを押した後にタブを切り替え
            self.switchToTabBar(at: 0)  // 例えば、1番目のタブに遷移
        }))
        
        present(alertController, animated: true, completion: nil)
    }

    // 特定のTabBarで切り替えた画面に遷移
    func switchToTabBar(at index: Int) {
        if let tabBarController = self.tabBarController {
            tabBarController.selectedIndex = index
        }
    }


    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //表示する数をmesseageArrayの個数にする
        return posts.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //名前をCellにする
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        //        //辞書型に無理やり決定
        //        let dictionary = messageArray[indexPath.row] as! [String: AnyObject]
//        content.text = "テスト"
//        cell.textLabel?.text = posts[indexPath.row]
        //cellを返却
        return cell
    }
    
    // Firestoreからデータを取得
    func fetchPosts() {
        db.collection("posts").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }
            
            // 取得したデータを辞書から`Post`型に変換して追加
            self.posts = querySnapshot?.documents.compactMap { document -> Post in
                let data = document.data()
                
                // 必要なフィールドを安全に取り出してPost型を生成
                let id = data["id"] as? String ?? "defaultId"  // デフォルト値を設定
                let title = data["title"] as? String ?? "No Title"  // デフォルト値を設定
                let userId = data["userId"] as? String ?? "defaultUserId"  // デフォルト値を設定
                let postImages = data["postImages"] as? [String] ?? []  // 空の配列を設定
                let thumbnailPost = data["thumbnailPost"] as? String ?? "No Date"  // デフォルト値を設定
                let createdAt = data["createdAt"] as? String ?? "No Date"  // createdAtを追加（デフォルト値）

                // 必要なデータがない場合でもデフォルト値を使ってPost型を生成
                return Post(id: id, title: title, userId: userId, postImages: postImages, thumbnailPost: thumbnailPost, createdAt: createdAt)
            } ?? []  // compactMapがnilを返す場合は空の配列を返す
            
            // UIを更新
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
            
            print("Posts successfully fetched and stored: \(self.posts)")
        }
    }

    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        //選択した画像の情報を取得
        let itemProvider = results.first?.itemProvider
        
        //選択された画像を読み込む
        if let itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                DispatchQueue.main.async {
                    //背景画像にセット
                    self.thumbnailImageView.image = image as? UIImage
                }
            }
            dismiss(animated: true)
        }
    }
    @IBAction func changeBackground() {
        //PHPickerViewControllerを用意
        var configuration = PHPickerConfiguration()
        
        //選択できるアセットタイプを画像に限定
        let filter = PHPickerFilter.images
        configuration.filter = filter
        let picker = PHPickerViewController(configuration: configuration)
        
        //デリケートを設定
        picker.delegate = self
        
        //ピッカーを呼び出す
        present(picker, animated: true)
    }
    
    @IBAction func save() {
        //画面のスクリーンショットを撮影
        UIGraphicsBeginImageContextWithOptions(thumbnailImageView.frame.size, false, 0.0)
        let context = UIGraphicsGetCurrentContext()!
        context.translateBy(x: -thumbnailImageView.frame.origin.x, y: -thumbnailImageView.frame.origin.y)
        view.layer.render(in: context)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //フォトライブラリに保存
        UIImageWriteToSavedPhotosAlbum(screenshot!, nil, nil, nil)
    }
    
    
    
}


