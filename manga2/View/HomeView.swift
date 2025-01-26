import SwiftUI
import Firebase

struct HomeView: View {
    @State private var posts: [Post] = []
    @State private var isLoading: Bool = false
    let db = Firestore.firestore()
    let spacer: CGFloat = 8
    
    // UIKitとの連携用クロージャ
    var onPostSelected: ((Post) -> Void)?
    
    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("Loading...") // ローディングインジケーター
                    .padding()
            }
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: spacer) {
                ForEach(posts) { post in
                    VStack {
                        // サムネイル画像
                        AsyncImage(url: URL(string: post.thumbnailPost)) { image in
                            image
                                .resizable()
                                .scaledToFill()
                                .frame(width: UIScreen.main.bounds.width / 2 - spacer * 3,
                                       height: UIScreen.main.bounds.width / 2 - spacer * 3)
                                .clipped()
                        } placeholder: {
                            Color.gray
                                .frame(width: UIScreen.main.bounds.width / 2 - spacer * 3,
                                       height: UIScreen.main.bounds.width / 2 - spacer * 3)
                        }

                        // タイトル
                        Text(post.title)
                            .font(.headline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1) // 1行に制限
                            .truncationMode(.tail) // 末尾に "..." を表示
                            .padding(.top, 4)

                    }
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                    .onTapGesture {
                        onPostSelected?(post) // タップ時のクロージャ
                    }
                }
            }
            .padding(.horizontal, spacer * 2)
        }
        .onAppear {
            fetchPosts()
        }
        .refreshable {
            fetchPosts()
        }
    }

    private func fetchPosts() {
        isLoading = true
        db.collection("posts").getDocuments { (querySnapshot, error) in
            if let error = error {
                print("Error getting documents: \(error.localizedDescription)")
                isLoading = false
                return
            }
            
            posts = querySnapshot?.documents.compactMap { document -> Post? in
                let data = document.data()
                let id = data["id"] as? String ?? "defaultId"
                let title = data["title"] as? String ?? "No Title"
                let userId = data["userId"] as? String ?? "defaultUserId"
                let postImages = data["postImages"] as? [String] ?? []
                let thumbnailPost = data["thumbnailPost"] as? String ?? "No Thumbnail"
                let createdAt = data["createdAt"] as? String ?? "No Date"
                
                return Post(id: id, title: title, userId: userId, postImages: postImages, thumbnailPost: thumbnailPost, createdAt: createdAt)
            } ?? []
            
            // 日付でソート
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            posts.sort {
                guard let date1 = dateFormatter.date(from: $0.createdAt),
                      let date2 = dateFormatter.date(from: $1.createdAt) else { return false }
                return date1 > date2
            }
            isLoading = false
        }
    }
}
