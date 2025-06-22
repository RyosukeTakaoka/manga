import SwiftUI
import Firebase

struct HomeView: View {
    @State private var posts: [Post] = []
    @State private var isLoading: Bool = false
    let db = Firestore.firestore()
    let spacer: CGFloat = 8

    var onPostSelected: ((Post) -> Void)?

    var body: some View {
        ScrollView {
            if isLoading {
                ProgressView("Loading...")
                    .padding()
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: spacer) {
                ForEach(posts) { post in
                    VStack {
                        ZStack(alignment: .bottomTrailing) {
                            let imageSize = UIScreen.main.bounds.width / 2 - spacer * 3

                            // メイン画像
                            AsyncImage(url: URL(string: post.thumbnailPost)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: imageSize, height: imageSize)
                                    .clipped()
                            } placeholder: {
                                Color.gray
                                    .frame(width: imageSize, height: imageSize)
                            }

                            // 右下の小さな円形画像
                            AsyncImage(url: URL(string: post.thumbnailPost)) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: imageSize * 0.2, height: imageSize * 0.2)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
                                    .shadow(radius: 2)
                            } placeholder: {
                                Circle()
                                    .fill(Color.white)
                                    .frame(width: imageSize * 0.3, height: imageSize * 0.3)
                                    .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            }
                            .offset(x: -spacer, y: -spacer)
                        }

                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(post.title)
                                    .font(.headline)
                                    .foregroundColor(.black)
                                    .lineLimit(1)
                                    .truncationMode(.tail)

                                Text(post.createdAt.timeAgo())
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            Spacer()

                            // ✅ Buttonに変更して競合回避
                            Button(action: {
                                if let index = posts.firstIndex(where: { $0.id == post.id }) {
                                    withAnimation(.spring()) {
                                        posts[index].isLiked.toggle()
                                    }
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                }
                            }) {
                                Image(systemName: post.isLiked ? "heart.fill" : "heart")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(post.isLiked ? .red : .gray)
                                    .padding(12)
                                    .background(Color.white.opacity(0.001))
                                    .clipShape(Circle())
                                    .contentShape(Circle())
                            }
                            .buttonStyle(PlainButtonStyle()) // ✅ 不要なアニメーション回避
                        }
                        .padding(.horizontal, 4)
                    }
                    .padding(.bottom, 4)
                    .background(Color.white)
                    .cornerRadius(8)
                    .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)

                    // ✅ 投稿全体のタップ設定（誤タップ防止）
                    .contentShape(Rectangle())
                    .onTapGesture {
                        onPostSelected?(post)
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

                return Post(id: id, title: title, userId: userId, postImages: postImages, thumbnailPost: thumbnailPost, createdAt: createdAt, isLiked: false)
            } ?? []

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
