import SwiftUI

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Uygulama kapatılırken yapılacak temizlik işlemleri
        // Örneğin: Log dosyalarını kapatma, geçici dosyaları temizleme vb.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Uygulama arka plana alındığında
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Uygulama ön plana geldiğinde
    }
} 