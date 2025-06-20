import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var sessionManager: SessionManager
    @State private var selectedTab = 0
    @State private var isRefreshing = false
    @State private var showSearch = false
    @State private var searchText = ""
    
    var body: some View {
        ZStack {
            // Content View
            TabContentView(selectedTab: $selectedTab)
            
            // Custom Tab Bar - Absolute positioned at bottom
            VStack {
                Spacer()
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
        .navigationBarHidden(true)
    }
}

// MARK: - Tab Content View
struct TabContentView: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        Group {
            switch selectedTab {
            case 0:
                MainView(selectedTab: $selectedTab)
            case 1:
                RoutesView()
            case 2:
                NotificationsView()
            case 3:
                ProfileView()
            default:
                MainView(selectedTab: $selectedTab)
            }
        }
    }
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    @Binding var selectedTab: Int
    
    var body: some View {
        HStack(spacing: 0) {
            CustomTabButton(
                title: "Ana Sayfa",
                icon: "house",
                isSelected: selectedTab == 0
            ) {
                // withAnimation(.easeInOut(duration: 0.2)) {
                    selectedTab = 0
                // }
            }
            
            CustomTabButton(
                title: "Reklamlar",
                icon: "cart",
                isSelected: selectedTab == 1
            ) {
                    selectedTab = 1
            }
            
            CustomTabButton(
                title: "Bildirimler",
                icon: "bell",
                isSelected: selectedTab == 2
            ) {
                    selectedTab = 2
            }
            
            CustomTabButton(
                title: "Profil",
                icon: "person",
                isSelected: selectedTab == 3
            ) {
                    selectedTab = 3
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black)
                .shadow(color: Color.black.opacity(0.15), radius: 15, x: 0, y: -5)
        )
        .padding(.horizontal, 20)
        .padding(.bottom, 0)
        .background(Color.clear)
    }
}

// MARK: - Custom Tab Button
struct CustomTabButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(isSelected ? .white : .gray)
                    .shadow(color: Color.white.opacity(0.15), radius: 15, x: 0, y: -5)

                Text(title)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(isSelected ? .white : .gray)
                    .shadow(color: Color.white.opacity(0.15), radius: 15, x: 0, y: -5)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.clear.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Original TabView (Commented Out)
/*
struct HomeView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var sessionManager: SessionManager
    @State private var selectedTab = 0
    @State private var isRefreshing = false
    @State private var showSearch = false
    @State private var searchText = ""
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Ana Sayfa
            MainView(selectedTab: $selectedTab)
                .tabItem {
                    // Image(selectedTab == 0 ? "HomeHover" : "Home")
                    Image(systemName: selectedTab == 2 ? "house" : "house")
                    Text("Ana Sayfa")
                }
                .tag(0)
            
            // Siparişler
            RoutesView()
                .tabItem {
                    // Image(selectedTab == 1 ? "BuyHover" : "Buy")
                    Image(systemName: selectedTab == 2 ? "cart" : "cart")
                    Text("Siparişler")
                }
                .tag(1)
            
            // Bildirimler
            NotificationsView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "heart" : "heart")
                    Text("Bildirimler")
                }
                .tag(2)
            
            // Profil
            ProfileView()
                .tabItem {
                    // Image(selectedTab == 3 ? "ProfileHover" : "Profile")
                    Image(systemName: selectedTab == 2 ? "person" : "person")
                    Text("Profil")
                }
                .tag(3)
        }
        .tint(Color.white)
        .navigationBarHidden(true)
    }
}
*/

#Preview {
    HomeView()
        .environmentObject(NavigationManager.shared)
        .environmentObject(SessionManager.shared)
} 
