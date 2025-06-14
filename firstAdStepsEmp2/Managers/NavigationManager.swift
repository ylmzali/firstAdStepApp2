class NavigationManager: ObservableObject {
    static let shared = NavigationManager()
    
    @Published var currentScreen: Screen = .splash
    
    enum Screen {
        case splash
        case login
        case register
        case home
    }
    
    func goToSplash() {
        currentScreen = .splash
    }
    
    func goToLogin() {
        currentScreen = .login
    }
    
    func goToRegister() {
        currentScreen = .register
    }
    
    func goToHome() {
        currentScreen = .home
    }
} 