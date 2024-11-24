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
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
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
    
    //ボタンがタップされた時
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        //titleが空でないことを確認　からならelseを実行
        guard let title = titleTextField.text, !title.isEmpty else {
            // テキストが空の場合の処理
            print("TextView is empty")
            return
        }
        
        //空でない場合取得したtextを引数として渡します
        savePostToFirestore(title: title)
    }
    
    // FirestoreにPostを保存する関数
    func savePostToFirestore(title: String) {
        let uuid = UUID()
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createdAt = formatter.string(from: currentDate)
        
        let post = Post(id: uuid.uuidString, title: title, userId: "exampleUserId", postImages: [], thumbnailPost: createdAt)
        
        let postData: [String: Any] = [
            "id": post.id,
            "title": post.title,
            "userId": post.userId,
            "postImages": post.postImages,
            "thumbnailPost": post.thumbnailPost
        ]
        
        db.collection("posts").document(uuid.uuidString).setData(postData) { error in
            if let error = error {
                print("Error saving post to Firestore: \(error.localizedDescription)")
            } else {
                print("Post saved successfully!")
                DispatchQueue.main.async {
                    // Firestore保存成功後に`posts`配列を更新
                    self.posts.append(post)
                    self.tableView.reloadData()
                }
            }
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
            self.posts = querySnapshot?.documents.compactMap { document in
                let data = document.data()
                
                // 必要なフィールドを安全に取り出してPost型を生成
                guard let id = data["id"] as? String,
                      let title = data["title"] as? String,
                      let userId = data["userId"] as? String,
                      let postImages = data["postImages"] as? [String],
                      let thumbnailPost = data["thumbnailPost"] as? String else {
                    print("Invalid data format: \(data)")
                    return nil
                }
                
                return Post(id: id, title: title, userId: userId, postImages: postImages, thumbnailPost: thumbnailPost)
            } ?? []
            
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


