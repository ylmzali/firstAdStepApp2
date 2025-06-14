import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @EnvironmentObject private var navigationManager: NavigationManager
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Ana Sayfa")
                    .font(.title)
                    .foregroundColor(.black)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AntColors.background)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .navigationBarBackButtonHidden(true)
    }
}

#Preview {
    HomeView()
        .environmentObject(SessionManager.shared)
        .environmentObject(NavigationManager.shared)
} 
