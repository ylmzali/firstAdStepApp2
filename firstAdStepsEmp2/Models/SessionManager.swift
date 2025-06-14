import SwiftUI
import Combine

final class SessionManager: ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var isLoading: Bool = false
    
    // MARK: - UserDefaults Keys
    private enum UserDefaultsKeys {
        static let user = "current_user"
        static let isAuthenticated = "is_authenticated"
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
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: UserDefaultsKeys.user)
            UserDefaults.standard.set(true, forKey: UserDefaultsKeys.isAuthenticated)
            
            DispatchQueue.main.async {
                self.currentUser = user
                self.isAuthenticated = true
                
                print("isAuthenticated: \(self.isAuthenticated)")
                print("currentUser: \(String(describing: self.currentUser))")

            }
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
} 
