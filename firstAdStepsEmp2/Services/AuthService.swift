import Foundation

class AuthService {
    static let shared = AuthService()
    private let baseURL = AppConfig.API.baseURL
    private let appToken = AppConfig.API.appToken
    
    private init() {}
    
    // MARK: - OTP Request
    func requestOTP(
        phoneNumber: String,
        countryCode: String,
        completion: @escaping (Result<OTPResponse, ServiceError>) -> Void
    ) {
        let parameters = [
            "phone_number": phoneNumber,
            "country_code": countryCode
        ]
        
        makeRequest(
            endpoint: "requestotp",
            method: .post,
            parameters: parameters,
            completion: completion
        )
    }
    
    // MARK: - OTP Verify
    func verifyOTP(
        phoneNumber: String,
        countryCode: String,
        otpRequestId: String,
        otpCode: String,
        completion: @escaping (Result<OTPVerifyResponse, ServiceError>) -> Void
    ) {
        guard otpCode.count == 4 else {
            completion(.failure(.invalidOTPLength))
            return
        }
        
        let parameters = [
            "country_code": countryCode,
            "phone_number": phoneNumber,
            "otp_request_id": otpRequestId,
            "otp_code": otpCode
        ]
        
        makeRequest(
            endpoint: "verifyotp",
            method: .post,
            parameters: parameters,
            completion: completion
        )
    }
    
    // MARK: - Register
    func register(
        phoneNumber: String,
        countryCode: String,
        firstName: String,
        lastName: String,
        email: String,
        companyName: String?,
        companyTaxNumber: String?,
        companyTaxOffice: String?,
        companyAddress: String?,
        completion: @escaping (Result<OTPRegisterResponse, ServiceError>) -> Void
    ) {
        var parameters: [String: Any] = [
            "phone_number": phoneNumber,
            "country_code": countryCode,
            "first_name": firstName,
            "last_name": lastName,
            "email": email
        ]
        
        if let companyName = companyName {
            parameters["company_name"] = companyName
        }
        if let companyTaxNumber = companyTaxNumber {
            parameters["company_tax_number"] = companyTaxNumber
        }
        if let companyTaxOffice = companyTaxOffice {
            parameters["company_tax_office"] = companyTaxOffice
        }
        if let companyAddress = companyAddress {
            parameters["company_address"] = companyAddress
        }
        
        makeRequest(
            endpoint: "adduser",
            method: .post,
            parameters: parameters,
            completion: completion
        )
    }
    
    // MARK: - Helper Methods
    private func makeRequest<T: Decodable>(
        endpoint: String,
        method: HTTPMethod,
        parameters: [String: Any]? = nil,
        completion: @escaping (Result<T, ServiceError>) -> Void
    ) {
        guard let url = URL(string: "\(baseURL)/\(endpoint)") else {
            completion(.failure(.invalidUrl))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(appToken, forHTTPHeaderField: "app_token")
        
        if let parameters = parameters {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                print("🌐 REQUEST URL: \(url)")
                print("🌐 REQUEST METHOD: \(method.rawValue)")
                print("🌐 REQUEST HEADERS: \(request.allHTTPHeaderFields ?? [:])")
                print("🌐 REQUEST BODY: \(String(data: request.httpBody ?? Data(), encoding: .utf8) ?? "")")
            } catch {
                completion(.failure(.invalidData))
                return
            }
        }
        
        let session = URLSession.shared
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("❌ Network error: \(error.localizedDescription)")
                completion(.failure(.networkError))
                return
            }
            
            guard let data = data else {
                completion(.failure(.invalidData))
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                print("🌐 RESPONSE STATUS: \(httpResponse.statusCode)")
                print("🌐 RESPONSE BODY: \(String(data: data, encoding: .utf8) ?? "")")
                
                switch httpResponse.statusCode {
                case 200...299:
                    do {
                        let decoder = JSONDecoder()
                        decoder.keyDecodingStrategy = .convertFromSnakeCase
                        let result = try decoder.decode(T.self, from: data)
                        completion(.success(result))
                    } catch {
                        print("❌ Decoding error: \(error)")
                        completion(.failure(.invalidData))
                    }
                case 401:
                    completion(.failure(.unauthorized))
                case 403:
                    completion(.failure(.invalidAppToken))
                case 404:
                    completion(.failure(.notFound))
                case 400, 402, 405...499:
                    if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                        completion(.failure(.custom(message: errorResponse.message)))
                    } else {
                        completion(.failure(.invalidData))
                    }
                case 500...599:
                    completion(.failure(.serverError("Sunucu hatası: \(httpResponse.statusCode)")))
                default:
                    completion(.failure(.unknown("Beklenmeyen durum kodu: \(httpResponse.statusCode)")))
                }
            } else {
                completion(.failure(.invalidResponse))
            }
        }.resume()
    }
}


