import Foundation
import Combine

@MainActor
class UserViewModel: ObservableObject {
    @Published var errorMessage: String?
    @Published var isUserUpdated = false
    
    private let userService = UserService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Get User
    func getUser(
        userId: String,
        completion: @escaping (Result<User, ServiceError>) -> Void
    ) {
        SessionManager.shared.isLoading = true
        errorMessage = nil
        
        userService.getUser(userId: userId) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                SessionManager.shared.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.status == "success",
                       let data = response.data,
                       let issetUser = data.issetUser,
                       issetUser == true,
                       let user = data.user {
                        completion(.success(user))
                    } else if let error = response.error {
                        self.errorMessage = error.message
                        completion(.failure(.custom(message: error.message)))
                    } else {
                        self.errorMessage = "Kullanıcı bilgileri getirilemedi"
                        completion(.failure(.invalidData))
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Update User
    func updateUser(
        user: User,
        completion: @escaping (Result<User, ServiceError>) -> Void
    ) {
        SessionManager.shared.isLoading = true
        errorMessage = nil
        isUserUpdated = false
        
        userService.updateUser(user: user) { [weak self] result in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                SessionManager.shared.isLoading = false
                
                switch result {
                case .success(let response):
                    if response.status == "success",
                       let data = response.data,
                       let isUserUpdated = data.isUserUpdated,
                       isUserUpdated == true,
                       let updatedUser = data.user {
                        self.isUserUpdated = true
                        completion(.success(updatedUser))
                    } else if let error = response.error {
                        self.errorMessage = error.message
                        completion(.failure(.custom(message: error.message)))
                    } else {
                        self.errorMessage = "Kullanıcı bilgileri güncellenemedi"
                        completion(.failure(.invalidData))
                    }
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    completion(.failure(error))
                }
            }
        }
    }
    
    // MARK: - Refresh User Data
    func refreshUserData(
        userId: String,
        sessionManager: SessionManager,
        completion: @escaping (Bool) -> Void
    ) {
        getUser(userId: userId) { result in
            switch result {
            case .success(let user):
                sessionManager.updateCurrentUser(user)
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    // MARK: - Save User Profile
    func saveUserProfile(
        userId: String,
        firstName: String,
        lastName: String,
        email: String,
        phone: String,
        countryCode: String,
        companyName: String,
        companyTaxNumber: String,
        companyTaxOffice: String,
        companyAddress: String,
        sessionManager: SessionManager,
        completion: @escaping (Bool) -> Void
    ) {
        let updatedUser = User(
            id: userId,
            firstName: firstName,
            lastName: lastName,
            email: email,
            countryCode: countryCode,
            phoneNumber: phone,
            companyName: companyName.isEmpty ? nil : companyName,
            companyTaxNumber: companyTaxNumber.isEmpty ? nil : companyTaxNumber,
            companyTaxOffice: companyTaxOffice.isEmpty ? nil : companyTaxOffice,
            companyAddress: companyAddress.isEmpty ? nil : companyAddress,
            status: sessionManager.currentUser?.status ?? "active",
            createdAt: sessionManager.currentUser?.createdAt ?? ""
        )
        
        updateUser(user: updatedUser) { result in
            switch result {
            case .success(let user):
                sessionManager.updateCurrentUser(user)
                completion(true)
            case .failure:
                completion(false)
            }
        }
    }
    
    // MARK: - Reset State
    func resetState() {
        errorMessage = nil
        SessionManager.shared.isLoading = false
        isUserUpdated = false
    }
} 