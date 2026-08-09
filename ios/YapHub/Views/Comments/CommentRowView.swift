import SwiftUI

struct CommentRowView: View {
    let comment: Comment
    @Bindable var viewModel: CommentsViewModel
    @Binding var highlightedCommentId: String?
    var isTopLevel: Bool

    @State private var showImageSpot = false

    private var replies: [Comment] {
        viewModel.repliesByCommentId[comment.id] ?? []
    }

    private var isExpanded: Bool {
        viewModel.expandedReplies.contains(comment.id)
    }

    private var isReplying: Bool {
        viewModel.replyingToCommentId == comment.id
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Main comment content
            commentContent

            // Reply inline text field
            if isReplying {
                replyInputField
            }

            // Replies section (top-level comments only)
            if isTopLevel && comment.repliesCount > 0 {
                repliesSection
            }
        }
    }

    // MARK: - Comment Content

    private var commentContent: some View {
        VStack(alignment: .leading, spacing: YHSpacing.xs) {
            // Author + location hint
            HStack(spacing: YHSpacing.xs) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 24))
                    .foregroundStyle(Color.yhSecondary.opacity(0.7))

                Text("User")
                    .font(YHFont.caption())
                    .bold()
                    .foregroundStyle(Color.yhTextPrimary)

                Text(relativeTime(from: comment.createdAt))
                    .font(YHFont.small())
                    .foregroundStyle(Color.yhTextTertiary)

                Spacer()

                // Location pin for top-level comments with coordinates
                if isTopLevel, comment.xCoordinate != nil {
                    Button {
                        showImageSpot = true
                    } label: {
                        Image(systemName: "mappin.circle.fill")
                            .font(.system(size: 18))
                            .foregroundStyle(Color.yhAccent)
                    }
                    .buttonStyle(.borderless)
                    .sheet(isPresented: $showImageSpot) {
                        imageSpotSheet
                    }
                }
            }

            // Comment text
            Text(comment.content)
                .font(YHFont.body(14))
                .foregroundStyle(Color.yhTextPrimary)
                .fixedSize(horizontal: false, vertical: true)

            // Action buttons
            HStack(spacing: YHSpacing.lg) {
                // Like
                Button {
                    Task {
                        await viewModel.toggleCommentLike(commentId: comment.id)
                    }
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "heart")
                            .font(.system(size: 13))
                        Text("\(comment.likesCount)")
                            .font(YHFont.small())
                    }
                    .foregroundStyle(comment.likesCount > 0 ? Color.yhLikeActive : Color.yhTextTertiary)
                }
                .buttonStyle(.borderless)

                // Reply
                Button {
                    if isReplying {
                        viewModel.cancelReply()
                    } else {
                        viewModel.startReply(to: comment.id)
                    }
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "arrowshape.turn.up.left")
                            .font(.system(size: 13))
                        Text("Reply")
                            .font(YHFont.small())
                    }
                    .foregroundStyle(isReplying ? Color.yhPrimary : Color.yhTextTertiary)
                }
                .buttonStyle(.borderless)

                Spacer()
            }
            .padding(.top, YHSpacing.xs)
        }
        .padding(.vertical, YHSpacing.sm)
        .padding(.leading, isTopLevel ? 0 : YHSpacing.lg)
    }

    // MARK: - Reply Input

    private var replyInputField: some View {
        HStack(spacing: YHSpacing.sm) {
            TextField("Write a reply...", text: Bindable(viewModel).replyText, axis: .vertical)
                .font(YHFont.body(14))
                .textFieldStyle(.roundedBorder)
                .lineLimit(1...4)

            Button {
                Task {
                    await viewModel.submitReply()
                }
            } label: {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(
                        viewModel.replyText.isEmpty ? Color.yhTextTertiary : Color.yhPrimary
                    )
            }
            .disabled(viewModel.replyText.isEmpty || viewModel.isSubmittingReply)
        }
        .padding(.leading, isTopLevel ? YHSpacing.xl : YHSpacing.xxl)
        .padding(.trailing, YHSpacing.sm)
        .padding(.bottom, YHSpacing.sm)
        .transition(.move(edge: .top).combined(with: .opacity))
    }

    // MARK: - Replies Section

    private var repliesSection: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Toggle button
            Button {
                Task {
                    await viewModel.toggleReplies(for: comment.id)
                }
            } label: {
                HStack(spacing: YHSpacing.xs) {
                    Rectangle()
                        .fill(Color.yhSecondary.opacity(0.3))
                        .frame(width: 2, height: 16)
                        .clipShape(RoundedRectangle(cornerRadius: 1))

                    Text(isExpanded ? "Hide replies" : "View \(comment.repliesCount) \(comment.repliesCount == 1 ? "reply" : "replies")")
                        .font(YHFont.caption(12))
                        .foregroundStyle(Color.yhSecondary)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(Color.yhSecondary)
                }
            }
            .buttonStyle(.borderless)
            .padding(.leading, YHSpacing.xl)

            // Expanded replies
            if isExpanded {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(replies) { reply in
                        HStack(alignment: .top, spacing: 0) {
                            // Thread line
                            Rectangle()
                                .fill(Color.yhSecondary.opacity(0.15))
                                .frame(width: 2)
                                .padding(.leading, YHSpacing.md)

                            CommentRowView(
                                comment: reply,
                                viewModel: viewModel,
                                highlightedCommentId: $highlightedCommentId,
                                isTopLevel: false
                            )
                        }
                    }
                }
            }
        }
    }

    // MARK: - Image Spot Sheet

    private var imageSpotSheet: some View {
        NavigationStack {
            ZStack {
                AsyncImage(url: URL(string: viewModel.post.image)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .overlay {
                                GeometryReader { imgGeo in
                                    if let x = comment.xCoordinate, let y = comment.yCoordinate {
                                        Circle()
                                            .fill(Color.yhPrimary)
                                            .frame(width: 20, height: 20)
                                            .overlay(
                                                Circle()
                                                    .stroke(.white, lineWidth: 2)
                                            )
                                            .shadow(color: Color.yhPrimary.opacity(0.6), radius: 8)
                                            .position(
                                                x: (x / 100.0) * imgGeo.size.width,
                                                y: (y / 100.0) * imgGeo.size.height
                                            )
                                    }
                                }
                            }
                    default:
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            .background(.black)
            .navigationTitle("Comment Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showImageSpot = false
                    }
                    .foregroundStyle(Color.yhPrimary)
                }
            }
        }
    }

    // MARK: - Helpers

    private func relativeTime(from dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: dateString) else {
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
        if interval < 3600 { return "\(Int(interval / 60))m" }
        if interval < 86400 { return "\(Int(interval / 3600))h" }
        if interval < 604800 { return "\(Int(interval / 86400))d" }
        return "\(Int(interval / 604800))w"
    }
}
