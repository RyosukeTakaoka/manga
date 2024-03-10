//
//  HomeViewController.swift
//  manga2
//
//  Created by Ryosuke Takaoka on 2024/01/28.
//

import UIKit

class HomeViewController: UIViewController,UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet var homeCollectionView: UICollectionView!
    
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
    }
    
    //cellを表示する数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        16
    }
    //cellを表示する内容
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //storyboard上のセルを生成　storyboardのIdentifierで付けたものをここで設定する
        let cell:UICollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        
        //セル上のTag(1)とつけたUILabelを生成
        let label = cell.contentView.viewWithTag(3) as! UILabel
        //セル上のTag(2)と付けたUIImageViewを作成
        let image = cell.contentView.viewWithTag(4) as! UIImageView
        
        //今回は簡易的にセルの番号をラベルのテキストに反映させる
        label.text = String(indexPath.row + 1)
        
        return cell
    }
   
    // CollectionViewのセルをタップした時
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        // Identifierを指定して画面遷移する
        performSegue(withIdentifier: "toSecondViewController", sender: nil)
    }
   
}

