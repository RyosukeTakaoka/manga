//
//  CreateViewController.swift
//  manga2
//
//  Created by Ryosuke Takaoka on 2024/01/28.
//

import UIKit
import PencilKit
import Firebase


//キャンバスをフリップすることができるかどうか
class CreateViewController: UIViewController {
    
    //壁画ビューを表示するためのコンテナ（表示するためのView）
    @IBOutlet var pencilKitContainerView: UIView!
    @IBOutlet var editNavigationButtonItem: UIBarButtonItem!
   
    //現在表示されている漫画のコマのインデックス
    var currentComicIndex = 0
    //4つの画面のビューの設定
    let comicViews = [PKCanvasView(), PKCanvasView(), PKCanvasView(), PKCanvasView()]
    //現在表示されいているページの番号
    var pageIndex: Int = 0
    //ペンや消しゴムを選ぶツール
    let pkToolPicker = PKToolPicker()
    //ビューが編集中かどうか
    var isEditingMode = false
    
    //画面の最初の処理
    override func viewDidLoad() {
        super.viewDidLoad()
        //壁画ビューの設定
        setupCanvasView()
        //ナビゲーションバーの設定
        setupNavigationBar()
        //指定されたページの壁画ビューを表示する関数
        disPlayCanvasView(at: pageIndex)
    }
    //描画ビューを設定する関数
    func setupCanvasView() {
        // 各コマのCanvasViewの設定
        for canvasView in comicViews {
            //ペンツールの設定
            canvasView.tool = PKInkingTool(.pen, color: .black, width: 30)
            if #available(iOS 14.0, *){
                //指でも描けるようにする
                canvasView.drawingPolicy = .anyInput
            }
            //背景を白にする
            canvasView.backgroundColor = .white
            //最初は描けないようにする
            canvasView.isUserInteractionEnabled = false
        }
        
    }
    //指定されたページの描画ビューを表示する関数
    func disPlayCanvasView(at index: Int){
        //既存のビューを消去
        pencilKitContainerView.subviews.forEach { $0.removeFromSuperview() }
        
        //指定された絵画ビューを追加
        let canvasView = comicViews[index]
        canvasView.frame = pencilKitContainerView.bounds
        pencilKitContainerView.addSubview(canvasView)
        
        if isEditingMode {
            //編集モードならツールピッカーを表示して描けるようにする
            pkToolPicker.setVisible(true, forFirstResponder: canvasView)
            pkToolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
            canvasView.isUserInteractionEnabled = true
        } else {
            //その逆
            pkToolPicker.setVisible(false, forFirstResponder: canvasView)
            pkToolPicker.addObserver(canvasView)
            canvasView.becomeFirstResponder()
            canvasView.isUserInteractionEnabled = false
        }
    }
    
    //前のページに移動するボタん
    @IBAction func beforePage() {
        //最初のページなら最後のページに移動
        if pageIndex == 0 {
            pageIndex = comicViews.count - 1
        } else {
            //それ以外なら前に移動
            pageIndex -= 1
        }
        disPlayCanvasView(at: pageIndex)
        setupNavigationBar()
    }
    //次のページにするボタン
    @IBAction func afterPage() {
        //最後のページなら最初のページに移動
        if pageIndex == comicViews.count - 1 {
            pageIndex = 0
        } else {
            //それ以外なら前に移動
            pageIndex += 1
        }
        disPlayCanvasView(at: pageIndex)
        setupNavigationBar()
    }
    
    
    //ナビゲーションバー
    func setupNavigationBar() {
        //タイトルの名前をDrawing + １に設定する
        title = "Drawing\(pageIndex + 1)/4"
        
    }
   
    @IBAction func toggleEditing() {
        isEditingMode.toggle()
        //編集モードに応じてボタンのタイトルを変更
        editNavigationButtonItem.title = isEditingMode ? "完了" : "編集"
        //編集モードの変更に応じてビューを再開
        disPlayCanvasView(at: pageIndex)
    }
    // segueが動作することをViewControllerに通知するメソッド
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

            // segueのIDを確認して特定のsegueのときのみ動作させる
            if segue.identifier == "toSecondVC" {
                // 2. 遷移先のViewControllerを取得
                let next = segue.destination as? PostViewController
            }
        }
    @IBAction func tapAction(_ sender: Any) {
        for canvasView in comicViews {
            canvasView.GetImage()
        }
       
        // 4. 画面遷移実行
        performSegue(withIdentifier: "toSecondVC", sender: nil)
    }
    
}
//PKCanvasViewから画像の関数を取得
extension PKCanvasView {
    func getImage() -> UIImage? {
        let bounds = self.bounds
        //画像のコンテキストを作成
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        
        self.drawHierarchy(in: bounds, afterScreenUpdates: true)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
    
}

