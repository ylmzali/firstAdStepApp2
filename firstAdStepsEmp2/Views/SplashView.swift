import SwiftUI

struct SplashView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Theme.purple400.ignoresSafeArea()
            
            VStack {
                Image("logo-white")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 120)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1.0 : 0.0)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0)) {
                isAnimating = true
            }
            
            // Uygulama başlangıç kontrolleri
            Task {
                // Session kontrolü
                if sessionManager.isAuthenticated {
                    // Ana ekrana yönlendir
                    navigationManager.goToHome()
                } else {
                    // Telefon doğrulama ekranına yönlendir
                    navigationManager.goToPhoneVerification()
                }
            }
        }
    }
} 