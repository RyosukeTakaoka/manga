//
//  SubViewController.swift
//  manga
//
//  Created by Ryosuke Takaoka on 2023/07/08.
//

import Foundation

import UIKit
 
class SubViewController: UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    //プロトコルのメソッドで、コレクションビューのセルを作成およびカスタマイズするために使用
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        let testCell:UICollectionViewCell =
        collectionView.dequeueReusableCell(withReuseIdentifier: "CellId",
                                           for: indexPath)
        return testCell
    }
    //プロトコルのメソッドで、コレクションビューのアイテムが選択された際の処理
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
    }
    //メソッド: UIStoryboardSegueが発生する前に実行される処理を実装するためのメソッド
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if (segue.identifier == "toSubViewController") {
            let subVC: SubViewController = (segue.destination as? SubViewController)!
        }
    }
    //プロトコルのメソッドで、セクションの数を返すために使用
    func numberOfSections(in collectionView: UICollectionView) -> Int {
           return 1
       }
    
   
}
