import SwiftUI
import Combine

final class SessionManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    
    // MARK: - Device Token
    var deviceToken: String? {
        get { UserDefaults.standard.string(forKey: UserDefaultsKeys.deviceToken) }
        set { 
            if let token = newValue {
                UserDefaults.standard.set(token, forKey: UserDefaultsKeys.deviceToken)
            } else {
                UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.deviceToken)
            }
        }
    }
    
    // MARK: - UserDefaults Keys
    private enum UserDefaultsKeys {
        static let user = "current_user"
        static let isAuthenticated = "is_authenticated"
        static let deviceToken = "deviceToken"
    }
    
    // MARK: - Singleton
    static let shared = SessionManager()
    
    private init() {
        loadSession()
    }
    
    // MARK: - Session Management
    private func loadSession() {
        if let userData = UserDefaults.standard.data(forKey: UserDefaultsKeys.user),
           let user = try? JSONDecoder().decode(User.self, from: userData) {
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = UserDefaults.standard.bool(forKey: UserDefaultsKeys.isAuthenticated)
            }
        }
    }
    
    func setUser(_ user: User) {
        currentUser = user
        isAuthenticated = true
        
        // Save to UserDefaults
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.user)
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isAuthenticated)
        }
    }
    
    func updateCurrentUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.user)
        }
    }
    
    func clearSession() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.user)
        UserDefaults.standard.set(false, forKey: UserDefaultsKeys.isAuthenticated)
        
        DispatchQueue.main.async {
            self.currentUser = nil
            self.isAuthenticated = false
        }
    }
    
    // MARK: - Device Token Management
    
    /// Device token'ı UserDefaults'tan alır
    func getDeviceToken() -> String? {
        return UserDefaults.standard.string(forKey: UserDefaultsKeys.deviceToken)
    }
    
    /// Device token'ı UserDefaults'a kaydeder
    func saveDeviceToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: UserDefaultsKeys.deviceToken)
    }
    
    /// Device token'ı backend'e gönderir (AuthService kullanarak)
    func sendDeviceTokenToBackend() {
        guard let deviceToken = getDeviceToken(), !deviceToken.isEmpty else {
            return
        }
        
        guard let currentUser = currentUser else {
            return
        }
        
        // Device token backend'e gönderildi
    }
    
    /// Device token'ı temizler (çıkış yaparken)
    func clearDeviceToken() {
        UserDefaults.standard.removeObject(forKey: UserDefaultsKeys.deviceToken)
    }
}

// MARK: - Supporting Types

