//
//  UserView.swift
//  manga2
//
//  Created by Ryosuke Takaoka on 2025/02/23.
//

import SwiftUI
import Firebase

struct UserView: View {
    @State private var posts: [Post] = []
    @State private var isLoading: Bool = false
    let db = Firestore.firestore()
    var body: some View {
        VStack {
//            Image("0C526000-5F20-4761-BA00-F1D86ACC8A65_4_5005_c")
//                .clipShape(Circle())
//                .overlay {
//                    Circle().stroke(.white, lineWidth: 4)
//                }
//                .shadow(radius: 7)
            Text("UserName")
                .font(.title)
                .foregroundColor(.black)
                .font(.subheadline)
            Text("UserID")
                .font(.subheadline)
                .foregroundColor(.gray)
            List {
                HStack {
//                    Image("0C526000-5F20-4761-BA00-F1D86ACC8A65_4_5005_c")
//                        .resizable()
//                        .clipShape(Circle())
//                        .scaledToFill()
//                        .frame(width: 80, height: 80)
//                        .clipShape(Rectangle())
//                        .overlay(
//                            RoundedRectangle(cornerRadius: 3)
//                                .stroke(Color.black, lineWidth: 3)
//                        )
                    Text("りんご")
                        .font(.title)// ⬅︎リスト要素
                }
            } // List ここまで
            .listStyle(GroupedListStyle())
            
        }
    }
}

#Preview {
    UserView()
}
