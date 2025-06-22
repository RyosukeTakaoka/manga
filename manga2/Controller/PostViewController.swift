//
//  ViewController.swift
//  Message2
//
//  Created by Ryosuke Takaoka on 2024/08/04.
//

import UIKit
import Firebase
import PhotosUI
import Cloudinary
import PKHUD

class PostViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, PHPickerViewControllerDelegate {
    
    //tableViewの関連付け
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    
    let config = CLDConfiguration(cloudName: "dw71feikq", secure: true)
    var cloudinary: CLDCloudinary?
    
    let db = Firestore.firestore()
    let postManager = PostManager.shared
    var posts: [Post] = []
    
    var canvasImages: [UIImage] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setDismissKeybord()
        
        cloudinary = CLDCloudinary(configuration: config)
        
        //dataSourceをself
        collectionView.dataSource = self
        //delegateをself
        collectionView.delegate = self
        
        // ③レイアウト設定をする（縦方向にスクロールするように設定&セルの間の距離を設定）
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical // スクロール方向
        layout.minimumLineSpacing = 8 // セル間の縦の間隔
        layout.minimumInteritemSpacing = 0 // セル間の横の間隔
        collectionView.collectionViewLayout = layout
        
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "customCell")
        fetchPosts()
        
        print(canvasImages)
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
        
        Task {
            HUD.show(.labeledProgress(title: "", subtitle: "アップロード中です"))

            let thumbnailURL = await uploadThumbnailImage(image: thumbnail)
            
            // canvasImages内のすべての画像URLをアップロード
            var canvasImageURLs: [String] = []
            for image in canvasImages {
                let imageURL = await uploadThumbnailImage(image: image)  // ここで画像をアップロード
                if !imageURL.isEmpty {
                    canvasImageURLs.append(imageURL)  // 成功したURLを追加
                    print("成功したタタタアップロードが成功しました")
                }
            }
            
            // 空でない場合、取得したtextとthumbnailを引数として渡して保存処理
            savePostToFirestore(title: title, thumbnailURL: thumbnailURL, postImages: canvasImageURLs)
            HUD.hide()
            postManager.isPosted = true
        }
    }
    
    // アラートを表示する関数
    func showAlert(message: String) {
        let alertController = UIAlertController(title: "入力エラー", message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        present(alertController, animated: true, completion: nil)
    }
    
    //サムネイルを保存する関数
    func uploadThumbnailImage(image: UIImage) async -> String {
        guard let imageData = image.jpegData(compressionQuality: 0.8), let cloudinary = cloudinary else {
            print("画像データの準備に失敗しました")
            return ""
        }
        
        let uploader = cloudinary.createUploader()
        
        return await withCheckedContinuation { continuation in
            var isResumed = false
            let uniquePublicId = "thumbnail_\(UUID().uuidString)"
            let params = CLDUploadRequestParams().setPublicId(uniquePublicId)
            
            uploader.upload(data: imageData, uploadPreset: "manga_thumbnail", params: params, progress: { progress in
                print("アップロード進行中: \(progress.fractionCompleted * 100)%")
            }) { result, error in
                guard !isResumed else { return }
                
                if let error = error {
                    print("アップロード失敗: \(error.localizedDescription)")
                    isResumed = true
                    continuation.resume(returning: "")
                    return
                }
                
                if let result = result, let secureUrl = result.secureUrl {
                    print("アップロード成功: \(secureUrl)")
                    isResumed = true
                    continuation.resume(returning: secureUrl)
                } else {
                    print("アップロード結果が不明です")
                    isResumed = true
                    continuation.resume(returning: "")
                }
            }
        }
    }
    
    func savePostToFirestore(title: String, thumbnailURL: String, postImages: [String]) {
        let uuid = UUID()
        let currentDate = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let createdAt = formatter.string(from: currentDate)
        
        print(thumbnailURL)
        
        let post = Post(id: uuid.uuidString, title: title, userId: "exampleUserId", postImages: postImages, thumbnailPost: thumbnailURL, createdAt: createdAt, isLiked: false)
        
        let postData: [String: Any] = [
            "id": post.id,
            "title": post.title,
            "userId": post.userId,
            "postImages": post.postImages,
            "thumbnailPost": post.thumbnailPost,
            "createdAt": createdAt
        ]
        
        db.collection("posts").document(uuid.uuidString).setData(postData) { error in
            if let error = error {
                print("Error saving post to Firestore: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.showAlert(message: "投稿の保存に失敗しました。再試行してください。")
                }
            } else {
                print("Post saved successfully!")
                DispatchQueue.main.async {
                    self.posts.append(post)
                    self.collectionView.reloadData()
                    
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
            self.titleTextField.text = ""
            self.thumbnailImageView.image = nil
            
            self.navigationController?.popViewController(animated: true)
            
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //表示する数をmesseageArrayの個数にする
        return canvasImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //名前をCellにする
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! CollectionViewCell
        cell.thumbnailImageView.image = canvasImages[indexPath.row]
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
                return Post(id: id, title: title, userId: userId, postImages: postImages, thumbnailPost: thumbnailPost, createdAt: createdAt, isLiked: false)
            } ?? []  // compactMapがnilを返す場合は空の配列を返す
            
            // UIを更新
            DispatchQueue.main.async {
                self.collectionView.reloadData()
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
    
    // ④ここでセルのサイズを調節する（インスタっぽく1:1にするならこんな感じ！）
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width // 横幅いっぱいにする
        return CGSize(width: width, height: width) // 高さも横幅と同じで1:1の正方形
    }
    
    
}


