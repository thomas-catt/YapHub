import SwiftUI

struct ContentView: View {
    @Environment(AuthViewModel.self) private var authVM
    @State private var selectedTab: Tab = .home
    @State private var previousTab: Tab = .home
    @State private var showCreateSheet = false
    @State private var feedVM = FeedViewModel()
    @State private var createPostVM = CreatePostViewModel()

    enum Tab {
        case home
        case create
        case account
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            FeedView(feedVM: feedVM)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(Tab.home)

            // Create tab (placeholder that triggers sheet)
            Color.clear
                .tabItem {
                    Label("Create", systemImage: "plus.circle.fill")
                }
                .tag(Tab.create)

            AccountView()
                .tabItem {
                    Label("Account", systemImage: "person.circle.fill")
                }
                .tag(Tab.account)
        }
        .tint(Color.yhPrimary)
        .onChange(of: selectedTab) { oldValue, newValue in
            if newValue != .create {
                previousTab = newValue
            } else {
                if authVM.isLoggedIn {
                    showCreateSheet = true
                } else {
                    // Redirect directly to account tab to show login
                    selectedTab = .account
                }
            }
        }
        .onChange(of: showCreateSheet) { _, isPresented in
            if !isPresented && selectedTab == .create {
                selectedTab = previousTab
            }
        }
        .sheet(isPresented: $showCreateSheet) {
            // Refresh feed when sheet is dismissed after successful creation
            if createPostVM.didSubmitSuccessfully {
                createPostVM.didSubmitSuccessfully = false
                Task {
                    await feedVM.refreshAfterCreate()
                }
            }
        } content: {
            CreatePostSheet(viewModel: createPostVM)
        }
    }
}

#Preview {
    ContentView()
        .environment(AuthViewModel())
}
