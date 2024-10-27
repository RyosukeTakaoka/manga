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
    @IBOutlet weak var textVIew: UITextView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    
    let db = Firestore.firestore()
    var post: [String] = []
    
    //messageArrayの数
    var messageArray = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //dataSourceをself
        tableView.dataSource = self
        //delegateをself
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        fetchNotes()
        
    }
    //ボタンがタップされた時
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        //textが空でないことを確認　からならelseを実行
        guard let text = textVIew.text, !text.isEmpty else {
            // テキストが空の場合の処理
            print("TextView is empty")
            return
        }
        //空でない場合取得したtextを引数として渡します
        saveTextToFirestore(text: text)
    }
    //textViewをFIrebaseに保存する
    func saveTextToFirestore(text: String) {
        //Messageという名前のコレクション textはtext
        db.collection("post").addDocument(
            data: [
                "title": text,
                //                "createdAt": Timestamp()
            ]
        ) { error in
            //エラーの処理
            if let error = error {
                print("Error adding document: \(error)")
            } else {
                print("Document added successfully")
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //表示する数をmesseageArrayの個数にする
        return messageArray.count
        
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //名前をCellにする
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        //        //辞書型に無理やり決定
        //        let dictionary = messageArray[indexPath.row] as! [String: AnyObject]
        content.text = "テスト"
        cell.textLabel?.text = post[indexPath.row]
        //cellを返却
        return cell
    }
    
    // Firestoreからデータを取得
    func fetchNotes() {
        db.collection("post").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error)")
            } else {
                self.messageArray = querySnapshot?.documents.compactMap { $0.data()["content"] as? String } ?? []
                self.tableView.reloadData()
            }
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
    

