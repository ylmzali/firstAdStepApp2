import SwiftUI
import UserNotifications

class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    @Published var isPermissionGranted = false
    @Published var pendingNotifications: [UNNotificationRequest] = []
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.isPermissionGranted = granted
                if granted {
                    self.registerForRemoteNotifications()
                }
            }
        }
    }
    
    private func checkPermission() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isPermissionGranted = settings.authorizationStatus == .authorized
            }
        }
    }
    
    private func registerForRemoteNotifications() {
        DispatchQueue.main.async {
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    // MARK: - Local Notifications
    
    func scheduleLocalNotification(title: String, body: String, timeInterval: TimeInterval = 5) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Bildirim planlanırken hata oluştu: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleRouteNotification(routeName: String, startTime: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Rota Hatırlatması"
        content.body = "\(routeName) rotası \(startTime.formatted()) tarihinde başlayacak"
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: startTime),
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "route-\(routeName)",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Rota bildirimi planlanırken hata oluştu: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        // Bildirime tıklandığında yapılacak işlemler
        if let routeId = userInfo["routeId"] as? String {
            // Rota detayına yönlendir
            NotificationCenter.default.post(
                name: .routeNotificationTapped,
                object: nil,
                userInfo: ["routeId": routeId]
            )
        }
        
        completionHandler()
    }
    
    // MARK: - Remote Notifications
    
    func handleRemoteNotification(_ userInfo: [AnyHashable: Any]) {
        // Push notification verilerini işle
        if let routeId = userInfo["routeId"] as? String {
            // Rota güncellemesi
            NotificationCenter.default.post(
                name: .routeUpdated,
                object: nil,
                userInfo: ["routeId": routeId]
            )
        }
    }
    
    // MARK: - Notification Management
    
    func removeAllPendingNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func removeNotification(withIdentifier identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func getPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                self.pendingNotifications = requests
            }
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let routeNotificationTapped = Notification.Name("routeNotificationTapped")
    static let routeUpdated = Notification.Name("routeUpdated")
} 