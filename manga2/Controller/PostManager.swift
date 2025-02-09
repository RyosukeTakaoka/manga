//
//  PostManager.swift
//  manga2
//
//  Created by Ryosuke Takaoka on 2025/02/09.
//

import Foundation

final public class PostManager {
    var isPosted: Bool = false
    
    static let shared: PostManager = {
        let instance = PostManager()
                
        return instance
    }()
}
