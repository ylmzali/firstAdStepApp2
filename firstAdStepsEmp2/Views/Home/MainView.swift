import SwiftUI

struct MainView: View {
    @EnvironmentObject private var sessionManager: SessionManager
    @Binding var selectedTab: Int

    var body: some View {
        ZStack {
            // Beyaz-gri arka plan
            LinearGradient(
                gradient: Gradient(colors: [Color(.systemGray6), Color(.white)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // HERO Alanı
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Açık Hava Reklamcılığında Yeni Teknoloji")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        Text("Mobil reklam ekranlarımızla markanızı şehrin kalbine taşıyın.")
                            .font(.title3)
                            .foregroundColor(.gray)

                        Image("bazaar_bg")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, minHeight: 180, maxHeight: 180)
                            .clipped()
                            .cornerRadius(20)
                            .shadow(color: .gray.opacity(0.15), radius: 20, x: 0, y: 10)

                    }
                    .padding(.top, 32)

                    // İstatistikler
                    HStack(alignment: .top, spacing: 18) {
                        FuturisticStatBox(icon: "bolt.fill", color: .yellow, title: "Ekranlar", value: "30")
                        FuturisticStatBox(icon: "eye.fill", color: .blue, title: "Gösterim", value: "1.2M")
                        FuturisticStatBox(icon: "location.fill", color: .green, title: "Şehir", value: "12")
                    }
                    .padding(.vertical)

                    // Call to Action
                    Button(action: {
                        selectedTab = 1
                    }) {
                        HStack {
                            Image(systemName: "calendar.badge.plus")
                            Text("Hemen Rezervasyon Yap")
                                .fontWeight(.bold)
                        }
                        .font(.title3)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(18)
                        .shadow(color: .gray.opacity(0.15), radius: 10, x: 0, y: 6)
                    }
                    .padding(.vertical)

                    // Nasıl Çalışır
                    VStack(spacing: 22) {
                        Text("Nasıl Çalışır?")
                            .font(.headline)
                            .foregroundColor(.black)
                        HStack(alignment: .top, spacing: 12) {
                            HowItWorksStep(icon: "1.circle.fill", title: "Rezervasyon", desc: "Rota ve tarih seçerek rezervasyon yapın.")
                            HowItWorksStep(icon: "2.circle.fill", title: "Canlı Takip", desc: "Ekranınızı haritadan izleyin.")
                            HowItWorksStep(icon: "3.circle.fill", title: "Raporlama", desc: "Görsel ve istatistik alın.")
                        }
                    }
                    .padding(.bottom, 32)
                }
                .padding()
            }
        }
    }
}

struct FuturisticStatBox: View {
    let icon: String
    let color: Color
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(.white)
                .padding(16)
                .background(
                    Circle()
                        .fill(color)
                        .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 2)
                )
                .frame(width: 60, height: 60)
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.black)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: color.opacity(0.08), radius: 8, x: 0, y: 4)
        )
    }
}

struct HowItWorksStep: View {
    let icon: String
    let title: String
    let desc: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.black)
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.black)
            Text(desc)
                .font(.caption)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
    }
} 

#Preview {
    MainView(selectedTab: .constant(0))
}
