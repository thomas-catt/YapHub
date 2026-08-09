import SwiftUI

struct RegisterView: View {
    @Environment(AuthViewModel.self) private var authVM
    @Environment(\.dismiss) private var dismiss

    @State private var currentStep = 0

    var body: some View {
        @Bindable var auth = authVM

        ScrollView {
            VStack(spacing: YHSpacing.xl) {
                // Progress indicator
                HStack(spacing: YHSpacing.sm) {
                    ForEach(0..<3) { step in
                        Capsule()
                            .fill(step <= currentStep ? Color.yhPrimary : Color.yhTextTertiary.opacity(0.3))
                            .frame(height: 4)
                            .animation(.easeInOut(duration: 0.3), value: currentStep)
                    }
                }
                .padding(.horizontal, YHSpacing.xl)
                .padding(.top, YHSpacing.lg)

                // Step content
                VStack(spacing: YHSpacing.xl) {
                    switch currentStep {
                    case 0:
                        stepOne(auth: auth)
                    case 1:
                        stepTwo(auth: auth)
                    case 2:
                        stepThree(auth: auth)
                    default:
                        EmptyView()
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
                .animation(.easeInOut(duration: 0.3), value: currentStep)

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

                // Navigation buttons
                HStack(spacing: YHSpacing.md) {
                    if currentStep > 0 {
                        Button {
                            withAnimation {
                                currentStep -= 1
                            }
                        } label: {
                            HStack(spacing: YHSpacing.xs) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 13, weight: .semibold))
                                Text("Back")
                            }
                            .font(YHFont.headline(15))
                            .foregroundStyle(Color.yhTextSecondary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, YHSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: YHRadius.md)
                                    .stroke(Color.yhTextTertiary.opacity(0.3), lineWidth: 1)
                            )
                        }
                    }

                    if currentStep < 2 {
                        Button {
                            withAnimation {
                                currentStep += 1
                            }
                        } label: {
                            HStack(spacing: YHSpacing.xs) {
                                Text("Next")
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 13, weight: .semibold))
                            }
                        }
                        .buttonStyle(YHPrimaryButtonStyle(isDisabled: !canProceed))
                        .disabled(!canProceed)
                    } else {
                        Button {
                            Task {
                                await authVM.register()
                                if authVM.isLoggedIn {
                                    dismiss()
                                }
                            }
                        } label: {
                            HStack(spacing: YHSpacing.sm) {
                                if authVM.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "checkmark.circle")
                                    Text("Create Account")
                                }
                            }
                        }
                        .buttonStyle(YHPrimaryButtonStyle(isDisabled: !authVM.registerFormValid))
                        .disabled(!authVM.registerFormValid || authVM.isLoading)
                    }
                }
                .padding(.horizontal, YHSpacing.xl)

                Spacer()
            }
        }
        .background(Color.yhBackground)
        .navigationTitle("Create Account")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Step 1: Display Name

    private func stepOne(auth: AuthViewModel) -> some View {
        VStack(spacing: YHSpacing.lg) {
            Image(systemName: "person.text.rectangle")
                .font(.system(size: 44))
                .foregroundStyle(Color.yhPrimary)

            Text("What should we call you?")
                .font(YHFont.headline(20))
                .foregroundStyle(Color.yhTextPrimary)

            Text("This is how other users will see your name")
                .font(YHFont.body(14))
                .foregroundStyle(Color.yhTextSecondary)
                .multilineTextAlignment(.center)

            @Bindable var bindAuth = auth
            TextField("Display name", text: $bindAuth.registerDisplayName)
                .font(YHFont.body(16))
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal, YHSpacing.xl)
        }
        .padding(.horizontal, YHSpacing.xl)
    }

    // MARK: - Step 2: Username

    private func stepTwo(auth: AuthViewModel) -> some View {
        VStack(spacing: YHSpacing.lg) {
            Image(systemName: "at")
                .font(.system(size: 44, weight: .medium))
                .foregroundStyle(Color.yhSecondary)

            Text("Choose a username")
                .font(YHFont.headline(20))
                .foregroundStyle(Color.yhTextPrimary)

            Text("Letters, numbers, dots, hyphens, and underscores only")
                .font(YHFont.body(14))
                .foregroundStyle(Color.yhTextSecondary)
                .multilineTextAlignment(.center)

            @Bindable var bindAuth = auth
            TextField("username", text: $bindAuth.registerUsername)
                .font(YHFont.body(16))
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .padding(.horizontal, YHSpacing.xl)
        }
        .padding(.horizontal, YHSpacing.xl)
    }

    // MARK: - Step 3: Password

    private func stepThree(auth: AuthViewModel) -> some View {
        VStack(spacing: YHSpacing.lg) {
            Image(systemName: "lock.shield")
                .font(.system(size: 44))
                .foregroundStyle(Color.yhAccent)

            Text("Secure your account")
                .font(YHFont.headline(20))
                .foregroundStyle(Color.yhTextPrimary)

            Text("Choose a password with at least 4 characters")
                .font(YHFont.body(14))
                .foregroundStyle(Color.yhTextSecondary)
                .multilineTextAlignment(.center)

            VStack(spacing: YHSpacing.md) {
                @Bindable var bindAuth = auth
                SecureField("Password", text: $bindAuth.registerPassword)
                    .font(YHFont.body(16))
                    .textFieldStyle(.roundedBorder)

                SecureField("Confirm password", text: $bindAuth.registerConfirmPassword)
                    .font(YHFont.body(16))
                    .textFieldStyle(.roundedBorder)

                if !authVM.registerConfirmPassword.isEmpty && !authVM.registerPasswordsMatch {
                    HStack(spacing: YHSpacing.xs) {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 12))
                        Text("Passwords do not match")
                            .font(YHFont.small())
                    }
                    .foregroundStyle(Color.yhError)
                }
            }
            .padding(.horizontal, YHSpacing.xl)
        }
        .padding(.horizontal, YHSpacing.xl)
    }

    // MARK: - Validation

    private var canProceed: Bool {
        switch currentStep {
        case 0:
            return !authVM.registerDisplayName.isEmpty
        case 1:
            return !authVM.registerUsername.isEmpty
        default:
            return true
        }
    }
}
