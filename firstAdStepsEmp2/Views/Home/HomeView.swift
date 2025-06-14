import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var navigationManager: NavigationManager
    @EnvironmentObject private var sessionManager: SessionManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Üst Bar
                HStack {
                    // Kullanıcı Bilgileri
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(sessionManager.currentUser?.firstName ?? "") \(sessionManager.currentUser?.lastName ?? "")")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text(sessionManager.currentUser?.email ?? "")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    // Sağ Butonlar
                    HStack(spacing: 16) {
                        Button(action: {
                            // Bildirimler aksiyonu
                        }) {
                            Image(systemName: "bell.fill")
                                .foregroundColor(Theme.gray400)
                                .font(.title3)
                        }
                        
                        Button(action: {
                            // Ayarlar aksiyonu
                        }) {
                            Image(systemName: "gearshape.fill")
                                .foregroundColor(Theme.gray400)
                                .font(.title3)
                        }
                        
                        Button(action: {
                            sessionManager.clearSession()
                            navigationManager.goToSplash()
                        }) {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(Color.red)
                                .font(.title3)
                        }
                    }
                }
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.vertical)
                
                // Banner
                TabView {
                    ForEach(1...4, id: \.self) { index in
                        Image("banner-\(index)")
                            .resizable()
                            .scaledToFill()
                            .frame(height: 200)
                            .cornerRadius(12)
                    }
                }
                .cornerRadius(12)
                .tabViewStyle(PageTabViewStyle())
                .frame(height: 200)
                .padding(.horizontal)
                
                // Hızlı Erişim Menüsü
                VStack(alignment: .leading, spacing: 15) {
                    Text("Hızlı Erişim")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    HStack(spacing: 15) {
                        QuickAccessButton(
                            title: "Rotalar",
                            icon: "map",
                            color: .blue
                        )
                        
                        QuickAccessButton(
                            title: "İstatistikler",
                            icon: "chart.bar",
                            color: .green
                        )
                        
                        QuickAccessButton(
                            title: "Raporlar",
                            icon: "doc.text",
                            color: .orange
                        )
                        
                        Spacer()
                    }
                }
                .padding()
                
                // Son Aktiviteler
                VStack(alignment: .leading, spacing: 15) {
                    Text("Son Aktiviteler")
                        .font(.headline)
                        .foregroundColor(.black)
                    
                    ForEach(1...3, id: \.self) { _ in
                        ActivityCard()
                    }
                }
                .padding()
            }
        }
        .background(Color(.systemGray6))
        .navigationBarBackButtonHidden(true)
    }
}

// MARK: - Quick Access Button
struct QuickAccessButton: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            VStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 50, height: 50)
                    .background(color.opacity(0.1))
                    .cornerRadius(12)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.black)
            }
        }
        // .frame(maxWidth: .infinity)
    }
}

// MARK: - Activity Card
struct ActivityCard: View {
    var body: some View {
        HStack(spacing: 15) {
            Rectangle()
                .fill(Theme.purple200.opacity(0.5))
                .frame(width: 50, height: 50)
                .cornerRadius(8, corners: .allCorners)
                .overlay(
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.black)
                )
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Rota Tamamlandı")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("Kadıköy - Üsküdar")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            Text("2 saat önce")
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    HomeView()
        .environmentObject(NavigationManager.shared)
        .environmentObject(SessionManager.shared)
} 
