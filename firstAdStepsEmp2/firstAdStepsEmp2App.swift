//
//  firstAdStepsEmp2App.swift
//  firstAdStepsEmp2
//
//  Created by Ali YILMAZ on 13.06.2025.
//

import SwiftUI

@main
struct firstAdStepsEmp2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var sessionManager = SessionManager.shared
    @StateObject private var navigationManager = NavigationManager.shared
    @StateObject private var errorManager = CentralErrorManager.shared
    @StateObject private var logManager = LogManager.shared
    @StateObject private var appStateManager = AppStateManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionManager)
                .environmentObject(navigationManager)
                .environmentObject(errorManager)
                .environmentObject(logManager)
                .environmentObject(appStateManager)
                .environmentObject(notificationManager)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willTerminateNotification)) { _ in
                    // Uygulama kapatılmadan önce son temizlik işlemleri
                }
        }
    }
}
