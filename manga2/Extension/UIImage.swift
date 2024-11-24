//
//  UIImage.swift
//  manga2
//
//  Created by Ryosuke Takaoka on 2024/11/24.
//

import UIKit

extension UIImage {
    public convenience init(url: String) {
        // URLが正しいか確認
        if let validURL = URL(string: url) {
            do {
                // URLから画像データを取得
                let data = try Data(contentsOf: validURL)
                self.init(data: data)!
                return
            } catch let err {
                // エラーが発生した場合の処理
                print("Error : \(err.localizedDescription)")
            }
        }
        
        // URLが無効またはエラーの場合、ダミー画像（SF Symbolsのstar）を使用
        if let symbolImage = UIImage(systemName: "scribble.variable") {
            self.init(cgImage: symbolImage.cgImage!) // SF Symbolsの画像を使用
        } else {
            // 万が一SF Symbolsが読み込めない場合の予備処理
            self.init()
        }
    }
}

