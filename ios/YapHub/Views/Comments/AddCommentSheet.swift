import SwiftUI

struct AddCommentSheet: View {
    @Bindable var viewModel: CommentsViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var tappedPoint: CGPoint?
    @State private var imageSize: CGSize = .zero
    @FocusState private var isTextFieldFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Image with tap target
                Spacer() // Push image to middle

                AsyncImage(url: URL(string: viewModel.post.image)) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .overlay {
                                GeometryReader { imgGeo in
                                    Color.clear
                                        .contentShape(Rectangle())
                                        .onTapGesture { location in
                                            let xPercent = (location.x / imgGeo.size.width) * 100.0
                                            let yPercent = (location.y / imgGeo.size.height) * 100.0
                                            let clamped = CGPoint(
                                                x: min(max(xPercent, 0), 100),
                                                y: min(max(yPercent, 0), 100)
                                            )
                                            tappedPoint = clamped
                                            viewModel.selectedPoint = clamped
                                            isTextFieldFocused = true
                                        }
                                    
                                    // Show placed pin
                                    if let point = tappedPoint {
                                        Circle()
                                            .fill(Color.yhPrimary)
                                            .frame(width: 22, height: 22)
                                            .overlay(
                                                Circle()
                                                    .stroke(.white, lineWidth: 2.5)
                                            )
                                            .shadow(color: Color.yhPrimary.opacity(0.6), radius: 8)
                                            .position(
                                                x: (point.x / 100.0) * imgGeo.size.width,
                                                y: (point.y / 100.0) * imgGeo.size.height
                                            )
                                            .transition(.scale.combined(with: .opacity))
                                            .animation(.spring(response: 0.35), value: tappedPoint)
                                    }
                                }
                            }
                    case .failure:
                        ZStack {
                            Color.yhSurface
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.yhTextTertiary)
                        }
                        .aspectRatio(1, contentMode: .fit)
                    case .empty:
                        ProgressView()
                            .aspectRatio(1, contentMode: .fit)
                    @unknown default:
                        Color.yhSurface
                            .aspectRatio(1, contentMode: .fit)
                    }
                }
                
                Spacer() // Push image to middle

                // Instruction overlay (always takes up some space or floats)
                if tappedPoint == nil {
                    HStack(spacing: YHSpacing.sm) {
                        Image(systemName: "hand.tap")
                            .font(.system(size: 18))
                        Text("Tap a spot on the image to comment")
                            .font(YHFont.caption())
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, YHSpacing.lg)
                    .padding(.vertical, YHSpacing.sm)
                    .background(
                        Capsule().fill(.black.opacity(0.6))
                    )
                    .padding(.bottom, YHSpacing.lg)
                }

                // Comment input (always in hierarchy, hidden when not active to prevent shift)
                VStack(spacing: YHSpacing.md) {
                    Divider()

                    HStack(spacing: YHSpacing.sm) {
                        TextField("Write your comment...", text: Bindable(viewModel).newCommentText, axis: .vertical)
                            .font(YHFont.body(14))
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(1...5)
                            .focused($isTextFieldFocused)

                        Button {
                            Task {
                                await viewModel.submitComment()
                                if !viewModel.isAddingComment {
                                    dismiss()
                                }
                            }
                        } label: {
                            Text("Submit")
                                .font(YHFont.headline(14))
                                .foregroundStyle(.white)
                                .padding(.horizontal, YHSpacing.lg)
                                .padding(.vertical, YHSpacing.sm)
                                .background(
                                    RoundedRectangle(cornerRadius: YHRadius.sm)
                                        .fill(viewModel.newCommentText.isEmpty ? Color.gray : Color.yhPrimary)
                                )
                        }
                        .disabled(viewModel.newCommentText.isEmpty || viewModel.isSubmittingComment)
                    }
                    .padding(.horizontal, YHSpacing.lg)
                    .padding(.bottom, YHSpacing.sm)
                }
                .opacity(tappedPoint != nil ? 1 : 0)
                .disabled(tappedPoint == nil)
            }
            .background(Color.yhBackground)
            .navigationTitle("Add Comment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        viewModel.selectedPoint = nil
                        viewModel.newCommentText = ""
                        dismiss()
                    }
                    .foregroundStyle(Color.yhTextSecondary)
                }
            }
        }
    }
}
