//
//  HomeViewController.swift
//  manga2
//
//  Created by Ryosuke Takaoka on 2024/01/28.
//

import UIKit
import Firebase

class HomeViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var homeCollectionView: UICollectionView!
    
    let db = Firestore.firestore()
    var posts: [Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        homeCollectionView.dataSource = self
        homeCollectionView.delegate = self
        let spacer: CGFloat = 8
        
        // collectionViewの表示設定
        let layout = UICollectionViewFlowLayout()
        // 縦スクロールに設定
        layout.scrollDirection = .vertical
        // セルの大きさ設定
        layout.itemSize = CGSize(width: view.frame.width / 2 - spacer * 2, height:
                                    view.frame.width / 2 - spacer * 2)
        // 余白の設定
        layout.sectionInset = UIEdgeInsets(top: spacer, left: spacer, bottom: spacer, right: spacer)
        // レイアウトをcollectionViewに適応させる
        homeCollectionView.collectionViewLayout = layout
        //FIreBaseからデータを取得
        fetchPosts()
    }
    
    //cellを表示する数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
        
    }
    //cellを表示する内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //storyboard上のセルを生成　storyboardのIdentifierで付けたものをここで設定する
        let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        //セル上のTag(1)とつけたUILabelを生成
        let title = cell.contentView.viewWithTag(3) as! UILabel
        //セル上のTag(2)と付けたUIImageViewを作成
        let thumbnail = cell.contentView.viewWithTag(4) as! UIImageView
        
        //今回は簡易的にセルの番号をラベルのテキストに反映させる
        title.text = posts[indexPath.row].title
        thumbnail.image =  UIImage(url: posts[indexPath.row].thumbnailPost)
        
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
            self.posts = querySnapshot?.documents.compactMap { document -> Post in
                let data = document.data()
                // 必要なフィールドを安全に取り出してPost型を生成
                let id = data["id"] as? String ?? "defaultId"  // デフォルト値を設定
                let title = data["title"] as? String ?? "No Title"  // デフォルト値を設定
                let userId = data["userId"] as? String ?? "defaultUserId"  // デフォルト値を設定
                let postImages = data["postImages"] as? [String] ?? []  // 空の配列を設定
                let thumbnailPost = data["thumbnailPost"] as? String ?? "No Thumbnai"  // デフォルト値を設定
                let createdAt = data["createdAt"] as? String ?? "No Date"  // createdAtを追加（デフォルト値）

                // 必要なデータがない場合でもデフォルト値を使ってPost型を生成
                return Post(id: id, title: title, userId: userId, postImages: postImages, thumbnailPost: thumbnailPost, createdAt: createdAt)
            } ?? []  // compactMapがnilを返す場合は空の配列を返す
            
            // UIを更新
            DispatchQueue.main.async {
                self.homeCollectionView.reloadData()
            }
            
            print("Posts successfully fetched and stored: \(self.posts)")
        }
    }
}

