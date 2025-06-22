import Foundation

struct User: Codable, Identifiable {
    var id: String { userId }  // SwiftUIでListなどに使えるようにする

    let userId: String         // Firebaseのuidなど
    let userName: String
    let userIcon: String       // URL文字列として扱う場合が多い
}

