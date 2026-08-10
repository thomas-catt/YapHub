import SwiftUI

struct CommentsView: View {
    @Bindable var viewModel: CommentsViewModel
    @Environment(AuthViewModel.self) private var authVM

    @State private var showAddComment = false
    @State private var showLoginPrompt = false

    var body: some View {
        ScrollViewReader { proxy in
            List {
                // Add Comment button
                Section {
                    Button {
                        if authVM.isLoggedIn {
                            showAddComment = true
                        } else {
                            showLoginPrompt = true
                        }
                    } label: {
                        HStack(spacing: YHSpacing.sm) {
                            Image(systemName: "plus.bubble")
                                .font(.system(size: 20))
                                .foregroundStyle(Color.yhPrimary)
                            Text("Add Comment")
                                .font(YHFont.headline(15))
                                .foregroundStyle(Color.yhPrimary)
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(Color.yhTextTertiary)
                        }
                        .padding(.vertical, YHSpacing.xs)
                    }
                }

                // Comments list
                if viewModel.isLoading {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                                .tint(Color.yhPrimary)
                            Spacer()
                        }
                        .padding(.vertical, YHSpacing.xl)
                    }
                } else if viewModel.comments.isEmpty {
                    Section {
                        VStack(spacing: YHSpacing.md) {
                            Image(systemName: "text.bubble")
                                .font(.system(size: 36))
                                .foregroundStyle(Color.yhTextTertiary)
                            Text("No comments yet")
                                .font(YHFont.headline(15))
                                .foregroundStyle(Color.yhTextSecondary)
                            Text("Be the first to share your thoughts!")
                                .font(YHFont.body(14))
                                .foregroundStyle(Color.yhTextTertiary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, YHSpacing.xxl)
                    }
                } else {
                    if viewModel.filterToCommentId != nil {
                        Section {
                            Button {
                                withAnimation {
                                    viewModel.filterToCommentId = nil
                                }
                            } label: {
                                HStack {
                                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                    Text("Viewing one comment. See all comments...")
                                        .font(YHFont.caption())
                                }
                                .foregroundStyle(Color.yhPrimary)
                                .frame(maxWidth: .infinity, alignment: .center)
                                .padding(.vertical, YHSpacing.xs)
                            }
                        }
                    }

                    Section {
                        ForEach(viewModel.displayComments) { comment in
                            CommentRowView(
                                comment: comment,
                                viewModel: viewModel,
                                highlightedCommentId: $viewModel.highlightedCommentId,
                                isTopLevel: true
                            )
                            .id(comment.id)
                        }
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showAddComment) {
                AddCommentSheet(viewModel: viewModel)
            }
            .alert("Login Required", isPresented: $showLoginPrompt) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Please log in from the Account tab to add a comment.")
            }
            .onChange(of: viewModel.highlightedCommentId) { _, newValue in
                if let id = newValue {
                    withAnimation {
                        proxy.scrollTo(id, anchor: .center)
                    }
                }
            }
        }
        .task {
            await viewModel.loadComments()
        }
    }
}
