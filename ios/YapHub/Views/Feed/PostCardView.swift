import SwiftUI

struct PostCardView: View {
    let post: Post
    var feedVM: FeedViewModel

    @State private var showComments = false
    @State private var commentsVM: CommentsViewModel?
    @Environment(AuthViewModel.self) private var authVM
    @State private var showLoginPrompt = false

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
        .alert("Login Required", isPresented: $showLoginPrompt) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Please log in from the Account tab to add a comment.")
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
                CommentDotsOverlay(postId: post.id, size: geometry.size) { commentId, nearestIds in
                    let vm = CommentsViewModel(post: post)
                    vm.highlightedCommentId = commentId
                    vm.filterToCommentIds = nearestIds
                    commentsVM = vm
                    showComments = true
                } onEmptyTapped: { location in
                    if authVM.isLoggedIn {
                        let vm = CommentsViewModel(post: post)
                        let xPercent = (location.x / geometry.size.width) * 100.0
                        let yPercent = (location.y / geometry.size.height) * 100.0
                        let clamped = CGPoint(
                            x: min(max(xPercent, 0), 100),
                            y: min(max(yPercent, 0), 100)
                        )
                        vm.selectedPoint = clamped
                        vm.isAddingComment = true
                        commentsVM = vm
                        showComments = true
                    } else {
                        showLoginPrompt = true
                    }
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
                        .foregroundStyle(post.isLiked == true ? Color.yhLikeActive : Color.yhTextTertiary)
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
    var onDotTapped: ((String, Set<String>) -> Void)?
    var onEmptyTapped: ((CGPoint) -> Void)?

    @State private var comments: [Comment] = []
    @State private var isPulsing = false
    @State private var tappedLocation: CGPoint? = nil

    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture { location in
                    withAnimation(.easeInOut(duration: 0.15)) {
                        tappedLocation = location
                    }
                }

            if let loc = tappedLocation {
                VStack(spacing: 0) {
                    Text("Add comment here")
                        .font(YHFont.caption())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            Capsule().fill(Color(white: 0.15))
                        )
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                        .onTapGesture {
                            onEmptyTapped?(loc)
                            tappedLocation = nil
                        }
                    
                    Path { path in
                        path.move(to: CGPoint(x: 0, y: 0))
                        path.addLine(to: CGPoint(x: 12, y: 0))
                        path.addLine(to: CGPoint(x: 6, y: 6))
                        path.closeSubpath()
                    }
                    .fill(Color(white: 0.15))
                    .frame(width: 12, height: 6)
                }
                .position(x: loc.x, y: loc.y - 25)
                .transition(.opacity)
                .zIndex(100)
            }

            ForEach(Array(comments.enumerated()).reversed(), id: \.element.id) { index, comment in
                if let x = comment.xCoordinate, let y = comment.yCoordinate {
                    Circle()
                        .fill(dotColor(for: index))
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(.white, lineWidth: 1.5)
                        )
                        .shadow(color: dotColor(for: index).opacity(0.5), radius: 4)
                        .scaleEffect(isPulsing ? 1.1 : 0.9)
                        .frame(width: 44, height: 44) // Increase touch target
                        .contentShape(Rectangle())
                        .highPriorityGesture(
                            TapGesture().onEnded {
                                var nearestIds = Set<String>()
                                for other in comments {
                                    if let ox = other.xCoordinate, let oy = other.yCoordinate {
                                        let dx = ox - x
                                        let dy = oy - y
                                        let distance = sqrt(dx*dx + dy*dy)
                                        if distance <= 4.0 {
                                            nearestIds.insert(other.id)
                                        }
                                    }
                                }
                                onDotTapped?(comment.id, nearestIds)
                            }
                        )
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
