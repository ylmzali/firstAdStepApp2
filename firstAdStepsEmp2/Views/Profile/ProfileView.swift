import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    @State private var showSupport = false
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 24) {
                // Avatar ve isim
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white.opacity(0.3), lineWidth: 2))
                        .shadow(radius: 6)
                    Text("\(sessionManager.currentUser?.firstName ?? "") \(sessionManager.currentUser?.lastName ?? "")")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                    Text(sessionManager.currentUser?.companyName ?? "")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.top, 32)

                // Bilgi kartı
                VStack(spacing: 12) {
                    ProfileInfoRow(icon: "envelope.fill", text: sessionManager.currentUser?.email ?? "-", color: .white)
                    ProfileInfoRow(icon: "phone.fill", text: sessionManager.currentUser?.phoneNumber ?? "-", color: .white)
                    if let company = sessionManager.currentUser?.companyName, !company.isEmpty {
                        ProfileInfoRow(icon: "building.2.fill", text: company, color: .white)
                    }
                    if let company_address = sessionManager.currentUser?.companyAddress, !company_address.isEmpty {
                        ProfileInfoRow(icon: "map.fill", text: company_address, color: .white)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 18)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                .padding(.horizontal)

                // Aksiyonlar
                VStack(spacing: 16) {
                    Button {
                        showEditProfile = true
                    } label: {
                        HStack {
                            Image(systemName: "pencil")
                            Text("Profili Düzenle")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }

                    Button {
                        showSupport = true
                    } label: {
                        HStack {
                            Image(systemName: "questionmark.circle")
                            Text("Yardım & Destek")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                    }

                    Spacer()

                    VStack {
                        Button(role: .destructive) {
                            showLogoutAlert = true
                        } label: {
                            Label("Çıkış Yap", systemImage: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.red)
                        }
                    }
                    .alert(isPresented: $showLogoutAlert) {
                        Alert(
                            title: Text("Çıkış Yap"),
                            message: Text("Oturumunuzu kapatmak istediğinize emin misiniz?"),
                            primaryButton: .destructive(Text("Çıkış Yap")) {
                                sessionManager.clearSession()
                            },
                            secondaryButton: .cancel()
                        )
                    }

                    

                    Spacer()

                }
                .padding(.horizontal)

            }
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileSheet()
        }
        .sheet(isPresented: $showSupport) {
            SupportView(showDeleteAlert: $showDeleteAlert)
        }
    }
}

struct ProfileInfoRow: View {
    let icon: String
    let text: String
    var color: Color = .white

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white.opacity(0.7))
                .frame(width: 24, height: 24)
            Text(text)
                .font(.body)
                .foregroundColor(color)
            Spacer()
        }
    }
}

struct SupportView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var showDeleteAlert: Bool
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Yardım & Destek")
                        .font(.title2).bold()
                        .foregroundColor(.white)
                        .padding(.top)
                    VStack(alignment: .leading, spacing: 16) {
                        Text("SSS")
                            .font(.headline)
                            .foregroundColor(.white)
                        VStack(alignment: .leading, spacing: 8) {
                            Text("• Rezervasyon nasıl yapılır?")
                            Text("• Canlı takip nasıl çalışır?")
                            Text("• Raporlar nereden görüntülenir?")
                        }
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white.opacity(0.1))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    )

                    Button(action: {
                        // WhatsApp ile destek
                        if let url = URL(string: "https://wa.me/905426943496") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "message.fill")
                            Text("WhatsApp ile Destek Al")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.green.opacity(0.2))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.green.opacity(0.4), lineWidth: 1)
                                )
                        )
                    }

                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        HStack {
                            Image(systemName: "trash")
                            Text("Hesabımı Sil")
                        }
                        .font(.headline)
                        .foregroundColor(.red)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.red.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .alert(isPresented: $showDeleteAlert) {
                        Alert(
                            title: Text("Hesabınızı silmek üzeresiniz!"),
                            message: Text("Bu işlem geri alınamaz. Emin misiniz?"),
                            primaryButton: .destructive(Text("Hesabımı Sil")) {
                                // Hesap silme işlemi
                            },
                            secondaryButton: .cancel()
                        )
                    }


                    Spacer()
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                        .foregroundColor(.white)
                }
            }
        }
    }
}

struct EditProfileSheet: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @Environment(\.dismiss) var dismiss
    @State private var firstName: String = ""
    @State private var lastName: String = ""
    @State private var email: String = ""
    @State private var phone: String = ""
    @State private var companyName: String = ""
    @State private var companyTaxNumber: String = ""
    @State private var companyTaxOffice: String = ""
    @State private var companyAddress: String = ""

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Form {
                    Section(header: Text("Kişisel Bilgiler").foregroundColor(.white)) {
                        TextField("Ad", text: $firstName)
                            .foregroundColor(.white)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        
                        TextField("Soyad", text: $lastName)
                            .foregroundColor(.white)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        
                        TextField("E-posta", text: $email)
                            .foregroundColor(.white)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        
                        TextField("Telefon", text: $phone)
                            .foregroundColor(.white)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    .listRowBackground(Color.black)
                    
                    Section(header: Text("Şirket Bilgileri").foregroundColor(.white)) {
                        TextField("Şirket Adı", text: $companyName)
                            .foregroundColor(.white)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        
                        TextField("Vergi Numarası", text: $companyTaxNumber)
                            .foregroundColor(.white)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        
                        TextField("Vergi Dairesi", text: $companyTaxOffice)
                            .foregroundColor(.white)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        
                        TextField("Şirket Adresi", text: $companyAddress)
                            .foregroundColor(.white)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    .listRowBackground(Color.black)
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
            }
            .navigationTitle("Profili Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        // Kaydet aksiyonu
                    }
                    .foregroundColor(.white)
                }
            }
            .onAppear {
                let user = sessionManager.currentUser
                firstName = user?.firstName ?? ""
                lastName = user?.lastName ?? ""
                email = user?.email ?? ""
                phone = user?.phoneNumber ?? ""
                companyName = user?.companyName ?? ""
                companyTaxNumber = user?.companyTaxNumber ?? ""
                companyTaxOffice = user?.companyTaxOffice ?? ""
                companyAddress = user?.companyAddress ?? ""
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(NavigationManager.shared)
        .environmentObject(SessionManager.shared)
}
