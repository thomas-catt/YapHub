import SwiftUI

struct AccountView: View {
    @Environment(AuthViewModel.self) private var authVM

    @State private var showingLogoutConfirm = false

    var body: some View {
        NavigationStack {
            Group {
                if authVM.isLoggedIn {
                    loggedInView
                } else {
                    LoginView()
                }
            }
            .transition(.opacity)
            .animation(.easeInOut, value: authVM.isLoggedIn)
        }
    }

    // MARK: - Logged In

    private var loggedInView: some View {
        ScrollView {
            VStack(spacing: YHSpacing.xl) {
                // Profile header
                VStack(spacing: YHSpacing.md) {
                    Image(systemName: "person.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.yhPrimary, Color.yhAccent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    VStack(spacing: YHSpacing.xs) {
                        Text(authVM.displayName.isEmpty ? authVM.username : authVM.displayName)
                            .font(YHFont.title(24))
                            .foregroundStyle(Color.yhTextPrimary)

                        Text("@\(authVM.username)")
                            .font(YHFont.body(15))
                            .foregroundStyle(Color.yhTextSecondary)
                    }
                }
                .padding(.top, YHSpacing.xxl)

                Divider()
                    .padding(.horizontal, YHSpacing.xl)

                // Logout button
                Button {
                    showingLogoutConfirm = true
                } label: {
                    HStack(spacing: YHSpacing.sm) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .font(.system(size: 17))
                        Text("Log Out")
                            .font(YHFont.headline(16))
                    }
                    .foregroundStyle(Color.yhError)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, YHSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: YHRadius.md)
                            .stroke(Color.yhError.opacity(0.3), lineWidth: 1)
                            .fill(Color.yhError.opacity(0.05))
                    )
                }
                .padding(.horizontal, YHSpacing.xl)

                Spacer()
            }
            .confirmationDialog("Log Out", isPresented: $showingLogoutConfirm, titleVisibility: .visible) {
                Button("Log Out", role: .destructive) {
                    Task {
                        await authVM.logout()
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("Are you sure you want to log out?")
            }
        }
        .background(Color.yhBackground)
        .navigationTitle("Account")
    }
}
