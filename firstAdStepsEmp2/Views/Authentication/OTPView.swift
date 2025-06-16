import SwiftUI

struct OTPView: View {
    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject private var navigationManager: NavigationManager
    
    let phoneNumber: String
    let countryCode: String
    let otpRequestId: String
    
    @State private var otpCode = ""
    @State private var timeRemaining = 120 // 2 minutes
    @State private var timer: Timer?
    @State private var errorMessage: String?
    
    var body: some View {
        VStack(spacing: 20) {
            VStack {
                Image("logo-black")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 220, height: 120)
            }
            .padding(.top, 45)
            
            Text("Doğrulama Kodu")
                .font(.title)
                .fontWeight(.bold)
            
            Text("\(countryCode) \(phoneNumber) numaralı telefonunuza gönderilen 6 haneli doğrulama kodunu giriniz.")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            TextField("Doğrulama Kodu", text: $otpCode)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.title2)
                .frame(height: 50)
                .frame(maxWidth: .infinity)
                .background(Color.white)
                .cornerRadius(10)
                .padding(.horizontal, 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Theme.purple400.opacity(0.3), lineWidth: 1)
                )
                .onChange(of: otpCode) { newValue in
                    // Sadece rakam girişine izin ver
                    let filtered = newValue.filter { $0.isNumber }
                    if filtered != newValue {
                        otpCode = filtered
                    }
                    
                    // Maksimum 6 rakam
                    if filtered.count > 4 {
                        otpCode = String(filtered.prefix(4))
                    }
                }

            
            
            if timeRemaining > 0 {
                Text("Kalan süre: \(timeRemaining / 60):\(String(format: "%02d", timeRemaining % 60))")
                    .foregroundColor(.gray)
            } else {
                Button("Kodu Tekrar Gönder") {
                    viewModel.requestOTP(
                        phoneNumber: phoneNumber,
                        countryCode: countryCode
                    ) { result in
                        switch result {
                        case .success(let data):
                            navigationManager.goToOTPVerification(
                                phoneNumber: phoneNumber,
                                countryCode: countryCode,
                                otpRequestId: data.otpRequestId
                            )
                        case .failure:
                            // Error is handled in ViewModel and shown via errorMessage
                            break
                        }
                    }
                    
                }
                .foregroundColor(.blue)
            }

            Button(action: {
                viewModel.verifyOTP(
                    phoneNumber: phoneNumber,
                    countryCode: countryCode,
                    otpRequestId: otpRequestId,
                    otpCode: otpCode
                ) { result in
                    switch result {
                    case .success(let data):
                        if data.isUserExist == true, let user = data.user {
                            print("✅ User verified successfully")
                            print("📱 User data: \(user)")
                            navigationManager.goToHome()
                        } else {
                            print("❌ User verification failed")
                            navigationManager.goToRegistration(phoneNumber: phoneNumber, countryCode: countryCode)
                        }
                    case .failure:
                        // Error is handled in ViewModel and shown via errorMessage
                        break
                    }
                }
            }) {
                Text("Doğrula")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(otpCode.isEmpty && otpCode.count != 4 ? Theme.gray300 : Theme.purple400)
                    .cornerRadius(12)
            }
            .disabled(otpCode.count != 4 || SessionManager.shared.isLoading)
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("Doğrulama Kodu")
        .navigationBarHidden(true)
        .onAppear {
            startTimer()
        }
        .onDisappear {
            timer?.invalidate()
        }
        .overlay {
            if SessionManager.shared.isLoading {
                LoadingView()
            }
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timer?.invalidate()
            }
        }
    }
}

#Preview {
    OTPView(
        phoneNumber: "5551234567",
        countryCode: "+90",
        otpRequestId: "123456"
    )
    .environmentObject(NavigationManager.shared)
}
