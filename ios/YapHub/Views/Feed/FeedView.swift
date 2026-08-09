import SwiftUI

struct FeedView: View {
    @Environment(AuthViewModel.self) private var authVM
    var feedVM: FeedViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                if feedVM.isLoading && !feedVM.hasLoaded {
                    loadingView
                } else if let error = feedVM.errorMessage, feedVM.posts.isEmpty {
                    errorView(error)
                } else if feedVM.posts.isEmpty && feedVM.hasLoaded {
                    emptyView
                } else {
                    LazyVStack(spacing: YHSpacing.lg) {
                        ForEach(feedVM.posts) { post in
                            PostCardView(post: post, feedVM: feedVM)
                        }
                    }
                    .padding(.vertical, YHSpacing.sm)
                }
            }
            .background(Color.yhBackground)
            .navigationTitle("YapHub")
            .refreshable {
                await feedVM.loadPosts()
            }
        }
        .task {
            if !feedVM.hasLoaded {
                await feedVM.loadPosts()
            }
        }
    }

    // MARK: - Loading

    private var loadingView: some View {
        VStack(spacing: YHSpacing.lg) {
            Spacer()
                .frame(height: 100)
            ProgressView()
                .controlSize(.large)
                .tint(Color.yhPrimary)
            Text("Loading posts...")
                .font(YHFont.body())
                .foregroundStyle(Color.yhTextSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Error

    private func errorView(_ message: String) -> some View {
        VStack(spacing: YHSpacing.lg) {
            Spacer()
                .frame(height: 80)
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 48))
                .foregroundStyle(Color.yhTextTertiary)
            Text(message)
                .font(YHFont.body())
                .foregroundStyle(Color.yhTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, YHSpacing.xl)
            Button("Try Again") {
                Task {
                    await feedVM.loadPosts()
                }
            }
            .font(YHFont.headline(15))
            .foregroundStyle(Color.yhPrimary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Empty

    private var emptyView: some View {
        VStack(spacing: YHSpacing.lg) {
            Spacer()
                .frame(height: 80)
            Image(systemName: "bubble.left.and.text.bubble.right")
                .font(.system(size: 48))
                .foregroundStyle(Color.yhTextTertiary)
            Text("No posts yet")
                .font(YHFont.headline())
                .foregroundStyle(Color.yhTextPrimary)
            Text("Be the first to share something!")
                .font(YHFont.body())
                .foregroundStyle(Color.yhTextSecondary)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
