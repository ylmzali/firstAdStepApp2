import UIKit
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configure appearance
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.black
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        // Check notification permissions
        checkNotificationPermissions()
        
        return true
    }
    
    private func checkNotificationPermissions() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                switch settings.authorizationStatus {
                case .notDetermined:
                    self.requestNotificationPermission()
                case .denied:
                    // Permission denied
                    break
                case .authorized, .provisional, .ephemeral:
                    self.registerForRemoteNotifications()
                @unknown default:
                    break
                }
            }
        }
    }
    
    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    self.registerForRemoteNotifications()
                } else if let error = error {
                    // Handle permission error
                }
            }
        }
    }
    
    private func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        
        // Save device token
        SessionManager.shared.saveDeviceToken(token)
        
        // Send to backend if user is authenticated
        if SessionManager.shared.isAuthenticated {
            SessionManager.shared.sendDeviceTokenToBackend()
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // Handle registration error
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // Handle remote notification
        completionHandler(.newData)
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // App is terminating
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // App entered background
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // App will enter foreground
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle deep link
        handleDeepLink(url)
        return true
    }
    
    private func handleDeepLink(_ url: URL) {
        // Parse URL components
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return
        }
        
        // Extract route ID from URL
        if let routeId = components.queryItems?.first(where: { $0.name == "routeId" })?.value {
            // Process route ID
        }
    }
} 