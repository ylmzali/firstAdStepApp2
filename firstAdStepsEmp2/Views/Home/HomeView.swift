import SwiftUI

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
                    Image(selectedTab == 0 ? "HomeHover" : "Home")
                    Text("Ana Sayfa")
                }
                .tag(0)
            
            // Siparişler
            RoutesView()
                .tabItem {
                    Image(selectedTab == 1 ? "BuyHover" : "Buy")
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
                    Image(selectedTab == 3 ? "ProfileHover" : "Profile")
                    Text("Profil")
                }
                .tag(3)
        }
        .tint(Theme.purple400)
        .navigationBarHidden(true)
    }
}

#Preview {
    HomeView()
        .environmentObject(NavigationManager.shared)
        .environmentObject(SessionManager.shared)
} 
