import Foundation

/*
// Base API Response
struct APIResponse<T: Codable>: Codable {
    let status: String
    let data: T?
}

// OTP Request Response
struct OTPRequestResponse: Codable {
    let otpRequestId: String
    let expiresIn: Int
    let message: String
    
    enum CodingKeys: String, CodingKey {
        case otpRequestId = "otpRequestId"
        case expiresIn = "expiresIn"
        case message = "message"
    }
}

// OTP Verify Response
struct OTPVerifyResponse: Codable {
    let isUserExist: Bool
    let user: User?
    
    enum CodingKeys: String, CodingKey {
        case isUserExist = "isUserExist"
        case user = "user"
    }
}
*/





struct OTPResponse: Codable {
    let status: String
    let data: OTPData?
    let error: OTPError?
}
struct OTPData: Codable {
    let otpRequestId: String
    let expiresIn: Int
    let message: String
}
struct OTPError: Codable {
    let code: String
    let message: String
    let details: String
}


struct OTPVerifyResponse: Codable {
    let status: String
    let data: OTPVerifyData?
    let error: OTPVerifyError?
}
struct OTPVerifyData: Codable {
    let isUserExist: Bool?
    let user: User?
}
struct OTPVerifyError: Codable {
    let code: String
    let message: String
    let details: String
}

struct OTPRegisterResponse: Codable {
    let status: String
    let data: OTPRegisterData?
    let error: OTPRegisterError?
}
struct OTPRegisterData: Codable {
    let isUserSaved: Bool?
    let user: User?
}
struct OTPRegisterError: Codable {
    let code: String
    let message: String
    let details: String
}
