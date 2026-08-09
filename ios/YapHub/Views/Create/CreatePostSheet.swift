import SwiftUI

struct CreatePostSheet: View {
    @Bindable var viewModel: CreatePostViewModel
    @Environment(AuthViewModel.self) private var authVM
    @Environment(\.dismiss) private var dismiss

    @FocusState private var focusedField: Field?

    enum Field {
        case imageURL
        case caption
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: YHSpacing.xl) {
                    // Header illustration
                    VStack(spacing: YHSpacing.sm) {
                        Image(systemName: "photo.badge.plus")
                            .font(.system(size: 48))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.yhPrimary, Color.yhAccent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                        Text("Share something with the community")
                            .font(YHFont.body(14))
                            .foregroundStyle(Color.yhTextSecondary)
                    }
                    .padding(.top, YHSpacing.xl)

                    // Image URL input
                    VStack(alignment: .leading, spacing: YHSpacing.sm) {
                        Label("Image URL", systemImage: "link")
                            .font(YHFont.caption())
                            .foregroundStyle(Color.yhTextSecondary)

                        TextField("https://example.com/image.jpg", text: $viewModel.imageURL)
                            .font(YHFont.body(14))
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.URL)
                            .focused($focusedField, equals: .imageURL)
                    }
                    .padding(.horizontal, YHSpacing.lg)

                    // Image preview
                    if !viewModel.imageURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        AsyncImage(url: URL(string: viewModel.imageURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxHeight: 250)
                                    .clipShape(RoundedRectangle(cornerRadius: YHRadius.md))
                                    .shadow(color: .black.opacity(0.1), radius: 8)
                            case .failure:
                                imageErrorView
                            case .empty:
                                ProgressView()
                                    .frame(height: 150)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .padding(.horizontal, YHSpacing.lg)
                        .transition(.opacity)
                        .animation(.easeInOut, value: viewModel.imageURL)
                    }

                    // Caption input
                    VStack(alignment: .leading, spacing: YHSpacing.sm) {
                        Label("Caption", systemImage: "text.quote")
                            .font(YHFont.caption())
                            .foregroundStyle(Color.yhTextSecondary)

                        TextField("What's on your mind?", text: $viewModel.caption, axis: .vertical)
                            .font(YHFont.body(14))
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...8)
                            .focused($focusedField, equals: .caption)
                    }
                    .padding(.horizontal, YHSpacing.lg)

                    // Submit button
                    Button {
                        focusedField = nil
                        Task {
                            await viewModel.submit()
                            if viewModel.didSubmitSuccessfully {
                                dismiss()
                            }
                        }
                    } label: {
                        HStack(spacing: YHSpacing.sm) {
                            if viewModel.isSubmitting {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "paperplane.fill")
                                Text("Post")
                            }
                        }
                    }
                    .buttonStyle(YHPrimaryButtonStyle(isDisabled: !viewModel.formValid))
                    .disabled(!viewModel.formValid || viewModel.isSubmitting)
                    .padding(.horizontal, YHSpacing.lg)
                    .padding(.top, YHSpacing.md)

                    Spacer()
                }
            }
            .background(Color.yhBackground)
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        viewModel.reset()
                        dismiss()
                    }
                    .foregroundStyle(Color.yhTextSecondary)
                }
            }
            .alert("Error", isPresented: $viewModel.showError) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "Something went wrong")
            }
        }
    }

    private var imageErrorView: some View {
        VStack(spacing: YHSpacing.sm) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 24))
                .foregroundStyle(Color.yhAccent)
            Text("Could not load image preview")
                .font(YHFont.caption())
                .foregroundStyle(Color.yhTextTertiary)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .background(Color.yhSurface)
        .clipShape(RoundedRectangle(cornerRadius: YHRadius.md))
        .padding(.horizontal, YHSpacing.lg)
    }
}
