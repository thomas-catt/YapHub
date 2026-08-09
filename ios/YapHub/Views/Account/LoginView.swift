import SwiftUI

struct LoginView: View {
    @Environment(AuthViewModel.self) private var authVM
    @State private var showRegister = false

    var body: some View {
        @Bindable var auth = authVM

        ScrollView {
            VStack(spacing: YHSpacing.xl) {
                // Header
                VStack(spacing: YHSpacing.md) {
                    Image(systemName: "bubble.left.and.bubble.right.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.yhPrimary, Color.yhAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text("Welcome to YapHub")
                        .font(YHFont.title(26))
                        .foregroundStyle(Color.yhTextPrimary)

                    Text("Log in to join the conversation")
                        .font(YHFont.body(15))
                        .foregroundStyle(Color.yhTextSecondary)
                }
                .padding(.top, YHSpacing.xxl)

                // Login form
                VStack(spacing: YHSpacing.md) {
                    VStack(alignment: .leading, spacing: YHSpacing.xs) {
                        Label("Username", systemImage: "person")
                            .font(YHFont.caption())
                            .foregroundStyle(Color.yhTextSecondary)
                        TextField("Enter your username", text: $auth.loginUsername)
                            .font(YHFont.body(15))
                            .textFieldStyle(.roundedBorder)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }

                    VStack(alignment: .leading, spacing: YHSpacing.xs) {
                        Label("Password", systemImage: "lock")
                            .font(YHFont.caption())
                            .foregroundStyle(Color.yhTextSecondary)
                        SecureField("Enter your password", text: $auth.loginPassword)
                            .font(YHFont.body(15))
                            .textFieldStyle(.roundedBorder)
                    }
                }
                .padding(.horizontal, YHSpacing.xl)

                // Error message
                if let error = authVM.errorMessage {
                    HStack(spacing: YHSpacing.sm) {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 14))
                        Text(error)
                            .font(YHFont.caption())
                    }
                    .foregroundStyle(Color.yhError)
                    .padding(.horizontal, YHSpacing.xl)
                }

                // Login button
                Button {
                    Task {
                        await authVM.login()
                    }
                } label: {
                    HStack(spacing: YHSpacing.sm) {
                        if authVM.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Log In")
                        }
                    }
                }
                .buttonStyle(YHPrimaryButtonStyle(isDisabled: authVM.loginUsername.isEmpty || authVM.loginPassword.isEmpty))
                .disabled(authVM.loginUsername.isEmpty || authVM.loginPassword.isEmpty || authVM.isLoading)
                .padding(.horizontal, YHSpacing.xl)

                // Register link
                HStack(spacing: YHSpacing.xs) {
                    Text("New here?")
                        .font(YHFont.body(14))
                        .foregroundStyle(Color.yhTextSecondary)
                    Button("Create an account") {
                        showRegister = true
                    }
                    .font(YHFont.headline(14))
                    .foregroundStyle(Color.yhPrimary)
                }

                Spacer()
            }
        }
        .background(Color.yhBackground)
        .navigationTitle("Account")
        .navigationDestination(isPresented: $showRegister) {
            RegisterView()
        }
    }
}
