import UIKit
import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print("🚀 AppDelegate: Uygulama başlatılıyor...")
        // Uygulama başlangıç ayarları
        setupAppearance()
        return true
    }
    
    private func setupAppearance() {
        print("🎨 AppDelegate: Görünüm ayarları yapılıyor...")
        // Navigation bar görünümü
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(Color("Background"))
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Tab bar görünümü
        UITabBar.appearance().backgroundColor = UIColor(Color("Background"))
        UITabBar.appearance().unselectedItemTintColor = UIColor.gray
        UITabBar.appearance().tintColor = UIColor.white
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("✅ AppDelegate: Device token başarıyla alındı!")
        print("📱 Device Token Data: \(deviceToken)")
        
        // Push notification token'ı kaydet
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        print("🔑 Device Token String: \(token)")
        print("🔑 Token Length: \(token.count) karakter")
        
        // SessionManager üzerinden device token'ı kaydet
        SessionManager.shared.saveDeviceToken(token)
        
        // Eğer kullanıcı giriş yapmışsa backend'e gönder
        if SessionManager.shared.isAuthenticated {
            print("👤 Kullanıcı giriş yapmış, device token backend'e gönderiliyor...")
            SessionManager.shared.sendDeviceTokenToBackend()
        } else {
            print("❌ Kullanıcı giriş yapmamış, device token backend'e gönderilmedi")
        }
        
        print("✅ Device token işlemi tamamlandı")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ AppDelegate: Remote notification kaydı başarısız!")
        print("❌ Hata: \(error.localizedDescription)")
        print("❌ Hata Detayı: \(error)")
    }
}

// MARK: - Supporting Types

struct EmptyData: Codable {}

// MARK: - AppConfig Extension

extension AppConfig.Endpoints {
    static let updateDeviceToken = "/updateDeviceToken"
} 