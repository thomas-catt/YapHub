import SwiftUI

struct PostCardView: View {
    let post: Post
    var feedVM: FeedViewModel

    @State private var showComments = false
    @State private var commentsVM: CommentsViewModel?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Author header
            authorHeader

            // Image with comment dots
            imageSection

            // Action bar
            actionBar

            // Caption
            captionSection
        }
        .background(Color.yhCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: YHRadius.md))
        .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
        .padding(.horizontal, YHSpacing.lg)
        .navigationDestination(isPresented: $showComments) {
            if let vm = commentsVM {
                CommentsView(viewModel: vm)
            }
        }
    }

    // MARK: - Author Header

    private var authorHeader: some View {
        HStack(spacing: YHSpacing.sm) {
            Image(systemName: "person.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.yhPrimary, Color.yhAccent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(alignment: .leading, spacing: 2) {
                Text(post.author.displayName)
                    .font(YHFont.headline(15))
                    .foregroundStyle(Color.yhTextPrimary)
                Text("@\(post.author.username)")
                    .font(YHFont.caption(12))
                    .foregroundStyle(Color.yhTextTertiary)
            }

            Spacer()

            Text(relativeTime(from: post.createdAt))
                .font(YHFont.small())
                .foregroundStyle(Color.yhTextTertiary)
        }
        .padding(.horizontal, YHSpacing.md)
        .padding(.vertical, YHSpacing.sm)
    }

    // MARK: - Image Section

    private var imageSection: some View {
        AsyncImage(url: URL(string: post.image)) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
            case .failure:
                imageErrorPlaceholder
            case .empty:
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .aspectRatio(1, contentMode: .fit)
                    .background(Color.yhSurface)
            @unknown default:
                imageErrorPlaceholder
            }
        }
        .overlay {
            GeometryReader { geometry in
                // Comment dot overlays (loaded asynchronously)
                CommentDotsOverlay(postId: post.id, size: geometry.size) { commentId in
                    let vm = CommentsViewModel(post: post)
                    vm.highlightedCommentId = commentId
                    commentsVM = vm
                    showComments = true
                }
            }
        }
    }

    // MARK: - Action Bar

    private var actionBar: some View {
        HStack(spacing: YHSpacing.xl) {
            // Like button
            Button {
                Task {
                    await feedVM.toggleLike(for: post.id)
                }
            } label: {
                HStack(spacing: YHSpacing.xs) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(post.likesCount > 0 ? Color.yhLikeActive : Color.yhTextTertiary)
                    Text("\(post.likesCount)")
                        .font(YHFont.caption())
                        .foregroundStyle(Color.yhTextSecondary)
                }
            }
            .sensoryFeedback(.impact(flexibility: .soft), trigger: post.likesCount)

            // Comments button
            Button {
                let vm = CommentsViewModel(post: post)
                commentsVM = vm
                showComments = true
            } label: {
                HStack(spacing: YHSpacing.xs) {
                    Image(systemName: "bubble.left")
                        .font(.system(size: 19))
                        .foregroundStyle(Color.yhSecondary)
                    Text("\(post.commentsCount)")
                        .font(YHFont.caption())
                        .foregroundStyle(Color.yhTextSecondary)
                }
            }

            Spacer()
        }
        .padding(.horizontal, YHSpacing.md)
        .padding(.vertical, YHSpacing.sm)
    }

    // MARK: - Caption

    private var captionSection: some View {
        HStack(spacing: YHSpacing.xs) {
            Text(post.caption)
                .font(YHFont.body(14))
                .foregroundStyle(Color.yhTextPrimary)
                .lineLimit(3)
        }
        .padding(.horizontal, YHSpacing.md)
        .padding(.bottom, YHSpacing.md)
    }

    // MARK: - Helpers

    private var imageErrorPlaceholder: some View {
        ZStack {
            Rectangle()
                .fill(Color.yhSurface)
                .aspectRatio(1, contentMode: .fit)
            Image(systemName: "photo")
                .font(.system(size: 40))
                .foregroundStyle(Color.yhTextTertiary)
        }
    }

    private func relativeTime(from dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: dateString) else {
            // Try without fractional seconds
            let basic = ISO8601DateFormatter()
            basic.formatOptions = [.withInternetDateTime]
            guard let d = basic.date(from: dateString) else { return "" }
            return relativeString(from: d)
        }
        return relativeString(from: date)
    }

    private func relativeString(from date: Date) -> String {
        let now = Date()
        let interval = now.timeIntervalSince(date)

        if interval < 60 { return "just now" }
        if interval < 3600 { return "\(Int(interval / 60))m ago" }
        if interval < 86400 { return "\(Int(interval / 3600))h ago" }
        if interval < 604800 { return "\(Int(interval / 86400))d ago" }
        return "\(Int(interval / 604800))w ago"
    }
}

// MARK: - Comment Dots Overlay

struct CommentDotsOverlay: View {
    let postId: String
    let size: CGSize
    var onDotTapped: ((String) -> Void)?

    @State private var comments: [Comment] = []
    @State private var isPulsing = false

    var body: some View {
        ZStack {
            ForEach(Array(comments.enumerated()), id: \.element.id) { index, comment in
                if let x = comment.xCoordinate, let y = comment.yCoordinate {
                    Button {
                        onDotTapped?(comment.id)
                    } label: {
                        Circle()
                            .fill(dotColor(for: index))
                            .frame(width: 14, height: 14)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: 1.5)
                            )
                            .shadow(color: dotColor(for: index).opacity(0.5), radius: 4)
                            .scaleEffect(isPulsing ? 1.1 : 0.9)
                    }
                    .buttonStyle(.plain)
                    .position(
                        x: (x / 100.0) * size.width,
                        y: (y / 100.0) * size.height
                    )
                }
            }
        }
        .task {
            do {
                comments = try await CommentService().fetchComments(postId: postId)
                withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
                    isPulsing = true
                }
            } catch {
                // Dots are decorative, no error handling needed
            }
        }
    }

    private func dotColor(for index: Int) -> Color {
        Color.commentDotColors[index % Color.commentDotColors.count]
    }
}
