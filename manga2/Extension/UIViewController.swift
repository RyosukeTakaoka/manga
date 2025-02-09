//
//  UIViewController.swift
//  manga2
//
//  Created by Ryosuke Takaoka on 2025/02/09.
//

import Foundation
import UIKit

extension UIViewController {
    func setDismissKeybord() {
        let tapGR: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeybord))
        tapGR.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGR)
    }
    
    @objc func dismissKeybord() {
        self.view.endEditing(true)
    }
}
