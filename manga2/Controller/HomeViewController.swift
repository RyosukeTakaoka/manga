//
//  HomeViewController.swift
//  manga2
//
//  Created by Ryosuke Takaoka on 2024/01/28.
//

import UIKit
import Firebase

class HomeViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet var homeCollectionView: UICollectionView!
    
    let db = Firestore.firestore()
    var posts: [Post] = []
    private let refreshControl = UIRefreshControl()
    
    let spacer: CGFloat = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        homeCollectionView.dataSource = self
        homeCollectionView.delegate = self
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical // スクロール方向
        layout.minimumLineSpacing = spacer // セル間の縦の間隔
        layout.minimumInteritemSpacing = spacer // セル間の横の間隔
        layout.sectionInset = UIEdgeInsets(top: spacer, left: spacer * 2, bottom: spacer, right: spacer * 2)
        
        // レイアウトをcollectionViewに適応させる
        homeCollectionView.collectionViewLayout = layout
        //FIreBaseからデータを取得
        fetchPosts()
        //上に引っ張って更新するやつ
        homeCollectionView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(refreshPost), for: .valueChanged)
        
        homeCollectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "customCell")
    }
    
    @objc func refreshPost() {
        fetchPosts()
        self.refreshControl.endRefreshing()
    }
    
    //cellを表示する数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
        
    }
    //cellを表示する内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //名前をCellにする
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "customCell", for: indexPath) as! CollectionViewCell
        cell.titleLabel.text = posts[indexPath.row].title
        cell.titleLabel.frame.size = CGSize(width: collectionView.frame.width / 2 - spacer, height: collectionView.frame.width / 4)
        
        cell.thumbnailImageView.image = UIImage(url: posts[indexPath.row].thumbnailPost)
        cell.thumbnailImageView.frame.size = CGSize(width: collectionView.frame.width / 2 - spacer, height: collectionView.frame.width / 2 - spacer)
        cell.thumbnailImageView.contentMode = UIView.ContentMode.scaleAspectFill
        
        //cellを返却
        return cell
    }
    
    // CollectionViewのセルをタップした時
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        
        
        // Identifierを指定して画面遷移する
        performSegue(withIdentifier: "toSecondViewController", sender: nil)
    }
    // Firestoreからデータを取得
    func fetchPosts() {
        db.collection("posts").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                return
            }
            
            // 取得したデータを辞書から`Post`型に変換して追加
            self.posts = querySnapshot?.documents.compactMap { document -> Post? in
                let data = document.data()
                
                // 必要なフィールドを安全に取り出してPost型を生成
                let id = data["id"] as? String ?? "defaultId"  // デフォルト値を設定
                let title = data["title"] as? String ?? "No Title"  // デフォルト値を設定
                let userId = data["userId"] as? String ?? "defaultUserId"  // デフォルト値を設定
                let postImages = data["postImages"] as? [String] ?? []  // 空の配列を設定
                let thumbnailPost = data["thumbnailPost"] as? String ?? "No Thumbnail"  // デフォルト値を設定
                let createdAt = data["createdAt"] as? String ?? "No Date"  // createdAtを追加（デフォルト値）
                
                // 必要なデータがない場合でもデフォルト値を使ってPost型を生成
                return Post(id: id, title: title, userId: userId, postImages: postImages, thumbnailPost: thumbnailPost, createdAt: createdAt)
            } ?? []  // compactMapがnilを返す場合は空の配列を返す
            
            // createdAtをDate型に変換してソート（新しい順）
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"  // createdAtの日付フォーマットを指定
            
            self.posts.sort { post1, post2 in
                guard let date1 = dateFormatter.date(from: post1.createdAt),
                      let date2 = dateFormatter.date(from: post2.createdAt) else {
                    return false  // 日付の解析に失敗した場合は順序を変更しない
                }
                return date1 > date2  // 新しい日付が前に来るように並べ替え
            }
            
            // UIを更新
            DispatchQueue.main.async {
                self.homeCollectionView.reloadData()
            }
            
            print("Posts successfully fetched and stored: \(self.posts)")
        }
    }
    // ④ここでセルのサイズを調節する（インスタっぽく1:1にするならこんな感じ！）
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width / 2 - spacer * 3 // 横幅いっぱいにする
        return CGSize(width: width, height: width * 3) // 高さも横幅と同じで1:1の正方形
    }
}

