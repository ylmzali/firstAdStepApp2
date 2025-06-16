import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @State private var showEditProfile = false
    @State private var showLogoutAlert = false
    @State private var showSupport = false
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            VStack(spacing: 24) {
                // Avatar ve isim
                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 96, height: 96)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.gray, lineWidth: 2))
                        .shadow(radius: 6)
                    Text("\(sessionManager.currentUser?.firstName ?? "") \(sessionManager.currentUser?.lastName ?? "")")
                        .font(.title2).bold()
                        .foregroundColor(.black)
                    Text(sessionManager.currentUser?.companyName ?? "")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                .padding(.top, 32)

                // Bilgi kartı
                VStack(spacing: 12) {
                    ProfileInfoRow(icon: "envelope.fill", text: sessionManager.currentUser?.email ?? "-", color: .black)
                    ProfileInfoRow(icon: "phone.fill", text: sessionManager.currentUser?.phoneNumber ?? "-", color: .black)
                    if let company = sessionManager.currentUser?.companyName, !company.isEmpty {
                        ProfileInfoRow(icon: "building.2.fill", text: company, color: .black)
                    }
                    if let company_address = sessionManager.currentUser?.companyAddress, !company_address.isEmpty {
                        ProfileInfoRow(icon: "map.fill", text: company_address, color: .black)
                    }
                }
                .padding()
                .background(Color(.systemGray5).opacity(0.15))
                .cornerRadius(18)
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
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
                        .background(Color.black)
                        .cornerRadius(12)
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
                        .background(Color.gray)
                        .cornerRadius(12)
                    }

                    Spacer()

                    VStack {
                        Button(role: .destructive) {
                            showLogoutAlert = true
                        } label: {
                            Label("Çıkış Yap", systemImage: "rectangle.portrait.and.arrow.right")
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
    var color: Color = .black

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.gray)
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
            VStack(spacing: 24) {
                Text("Yardım & Destek")
                    .font(.title2).bold()
                    .padding(.top)
                VStack(alignment: .leading, spacing: 16) {
                    Text("SSS")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 8) {
                        Text("• Rezervasyon nasıl yapılır?")
                        Text("• Canlı takip nasıl çalışır?")
                        Text("• Raporlar nereden görüntülenir?")
                    }
                    .font(.body)
                    .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)

                Button(action: {
                    // WhatsApp ile destek
                    if let url = URL(string: "https://wa.me/905555555555") {
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
                    .background(Color.green)
                    .cornerRadius(12)
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
                    .background(Color.red.opacity(0.08))
                    .cornerRadius(12)
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
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
            Form {
                Section(header: Text("Kişisel Bilgiler")) {
                    TextField("Ad", text: $firstName)
                    TextField("Soyad", text: $lastName)
                    TextField("E-posta", text: $email)
                    TextField("Telefon", text: $phone)
                }
                Section(header: Text("Şirket Bilgileri")) {
                    TextField("Şirket Adı", text: $companyName)
                    TextField("Vergi Numarası", text: $companyTaxNumber)
                    TextField("Vergi Dairesi", text: $companyTaxOffice)
                    TextField("Şirket Adresi", text: $companyAddress)
                }
            }
            .navigationTitle("Profili Düzenle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        // Kaydet aksiyonu
                    }
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
