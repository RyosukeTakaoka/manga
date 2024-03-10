//
//  CreateViewController.swift
//  manga2
//
//  Created by Ryosuke Takaoka on 2024/01/28.
//

import UIKit

class CreateViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource   {
    //collectionVIewの宣言
    @IBOutlet var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        collectionView.dataSource = self
        collectionView.delegate = self
        let spacer: CGFloat = 2
        
        // collectionViewの表示設定
        
        let layout = UICollectionViewFlowLayout()
        // 縦スクロールに設定
        
        layout.scrollDirection = .horizontal
        // セルの大きさ設定
        
        layout.itemSize = CGSize(width: view.frame.width - spacer * 2, height:
                                    view.frame.height - spacer * 2)
        // 余白の設定
        
        layout.sectionInset = UIEdgeInsets(top: spacer, left: spacer, bottom: spacer, right: spacer)
        // レイアウトをcollectionViewに適応させる
        
        collectionView.collectionViewLayout = layout
    }
    
    //cellを表示する数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        4
    }
    //cellを表示する内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //storyboard上のセルを生成　storyboardのIdentifierで付けたものをここで設定する
        let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
       
        //セル上のTag(2)と付けたUIImageViewを作成
        let image = cell.contentView.viewWithTag(2) as! UIImageView
       
        return cell
    }
    // CollectionViewのセルをタップした時
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        // Identifierを指定して画面遷移する
        performSegue(withIdentifier: "toSecondVC", sender: nil)
    }
}

