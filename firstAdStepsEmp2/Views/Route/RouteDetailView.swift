import SwiftUI
import MapKit

struct RouteDetailView: View {
    let route: Route

    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0082, longitude: 28.9784), // İstanbul
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Header Section
                    VStack(alignment: .leading, spacing: 16) {
                        // Title and Status
                        VStack(alignment: .leading, spacing: 12) {
                            Text(route.title)
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            StatusBadge(status: route.status)
                                .scaleEffect(1.1)
                        }
                        
                        // Reklam Durumu Kartı
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "megaphone.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Reklam Durumu")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                    
                                    Text(route.status.rawValue.capitalized)
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.7))
                                }
                                
                                Spacer()
                                
                                Text("\(route.completion)%")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.blue.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Canlı Takip Butonu
                        if route.canStartLiveTracking {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "location.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.green)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Canlı Takip")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.white)
                                        
                                        Text("Reklamınızı gerçek zamanlı takip edin")
                                            .font(.system(size: 12))
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "arrow.right.circle.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.green)
                                }
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.green.opacity(0.1))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .onTapGesture {
                                    // TODO: Navigate to live tracking
                                }
                            }
                        }
                        
                        // Reklam Tarihi Bilgisi
                        if let assignedDate = route.formattedAssignedDate {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "calendar.circle.fill")
                                        .foregroundColor(.orange)
                                    Text("Reklam Tarihi")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                
                                Text(assignedDate)
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.leading, 28)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.orange.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.orange.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        
                        // Ekip Paylaşımı Bilgisi
                        if route.shareWithEmployees {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "person.2.circle.fill")
                                        .foregroundColor(.purple)
                                    Text("Ekip Paylaşımı")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.white)
                                }
                                
                                if !route.sharedEmployeeIds.isEmpty {
                                    Text("\(route.sharedEmployeeIds.count) çalışan ile paylaşıldı")
                                        .font(.system(size: 14))
                                        .foregroundColor(.white.opacity(0.8))
                                        .padding(.leading, 28)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.purple.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.purple.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    .padding(.top, 50)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 30)
                    
                    // İş Süreci Bölümü
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                                .foregroundColor(.green)
                            Text("İş Süreci")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 12) {
                            WorkflowStepRow(
                                icon: "plus.circle.fill",
                                title: "Reklam Talebi Oluşturuldu",
                                description: "Reklam talebiniz sisteme kaydedildi",
                                color: .green,
                                isCompleted: true
                            )
                            
                            WorkflowStepRow(
                                icon: "doc.text.circle.fill",
                                title: "Çalışma Planı Hazırlanıyor",
                                description: "Uzman ekibimiz detaylı çalışma planı hazırlıyor",
                                color: .blue,
                                isCompleted: route.status.isInProposalPhase || route.status.isAfterProposal
                            )
                            
                            WorkflowStepRow(
                                icon: "envelope.circle.fill",
                                title: "Plan Firma Onayına Gönderildi",
                                description: "Çalışma planı e-posta ile firmanıza gönderildi",
                                color: .orange,
                                isCompleted: route.status.isAfterProposal
                            )
                            
                            WorkflowStepRow(
                                icon: "checkmark.circle.fill",
                                title: "Firma Onayı",
                                description: "Çalışma planı firma tarafından onaylanacak",
                                color: .purple,
                                isCompleted: route.status.isAfterApproval
                            )
                            
                            WorkflowStepRow(
                                icon: "creditcard.circle.fill",
                                title: "Ödeme İşlemi",
                                description: "Onay sonrası ödeme işlemi gerçekleştirilecek",
                                color: .yellow,
                                isCompleted: route.status.isAfterPayment
                            )
                            
                            WorkflowStepRow(
                                icon: "flag.circle.fill",
                                title: "Son Onay",
                                description: "Ödeme sonrası son onay ve aktivasyon",
                                color: .red,
                                isCompleted: route.status.isAfterFinalApproval
                            )
                            
                            WorkflowStepRow(
                                icon: "location.circle.fill",
                                title: "Canlı Takip",
                                description: "Rota aktif olacak ve gerçek zamanlı takip edilebilecek",
                                color: .green,
                                isCompleted: route.status == .active
                            )
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.green.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.green.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // İletişim Bilgileri
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Image(systemName: "phone.circle.fill")
                                .foregroundColor(.yellow)
                            Text("İletişim")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.white)
                        }
                        
                        VStack(spacing: 12) {
                            ContactInfoRow(
                                icon: "phone.fill",
                                title: "Telefon",
                                value: "+90 212 555 0123",
                                action: { /* Telefon arama */ }
                            )
                            
                            ContactInfoRow(
                                icon: "envelope.fill",
                                title: "E-posta",
                                value: "destek@buisyurur.com",
                                action: { /* E-posta gönderme */ }
                            )
                            
                            ContactInfoRow(
                                icon: "message.fill",
                                title: "WhatsApp",
                                value: "+90 532 555 0123",
                                action: { /* WhatsApp mesajı */ }
                            )
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.yellow.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
                                )
                        )
                    }
                    .padding(.horizontal, 24)
                    
                    // Reklam Açıklaması
                    if !route.description.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "text.quote.circle.fill")
                                    .foregroundColor(.blue)
                                Text("Reklam Açıklaması")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                            
                            Text(route.description)
                                .font(.system(size: 14))
                                .foregroundColor(.white.opacity(0.8))
                                .lineLimit(nil)
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                                )
                        )
                        .padding(.horizontal, 24)
                    }
                    
                    // Çalışma Planı Sekmesi (sadece proposal aşamasında göster)
                    if route.status.isInProposalPhase {
                        RouteProposalView(route: route)
                            .padding(.horizontal, 24)
                    }
                    
                    // Harita Görünümü
                    RouteMapView(region: $region)
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100)
                }
            }
            
            // Fixed Close Button
            VStack {
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                            .background(
                                Circle()
                                    .fill(Color.black.opacity(0.5))
                                    .frame(width: 40, height: 40)
                            )
                    }
                    .padding(.trailing, 20)
                    .padding(.top, 20)
                }
                Spacer()
            }
        }
    }
}

// MARK: - Supporting Views

struct WorkflowStepRow: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    let isCompleted: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : icon)
                .font(.system(size: 20))
                .foregroundColor(isCompleted ? .green : color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
        }
    }
}

struct ContactInfoRow: View {
    let icon: String
    let title: String
    let value: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(.yellow)
                    .frame(width: 20)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(value)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Image(systemName: "arrow.right")
                    .font(.system(size: 12))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Route Info View
struct RouteInfoView: View {
    let route: Route

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Rota Bilgileri")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            VStack(alignment: .leading, spacing: 16) {
                // Description
                if !route.description.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "text.alignleft")
                                    .foregroundColor(.white.opacity(0.8))
                                Text("Açıklama")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            
                            Text(route.description)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.9))
                                .lineLimit(nil)
                            
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                )
                        )
                }

                // Progress Section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                            .foregroundColor(.white.opacity(0.8))
                        Text("İlerleme Durumu")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(route.completion)%")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(ProgressColor.fromCompletion(route.completion).color)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 12)
                            
                            // Progress
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            ProgressColor.fromCompletion(route.completion).color,
                                            ProgressColor.fromCompletion(route.completion).color.opacity(0.7)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(route.completion) / 100, height: 12)
                        }
                    }
                    .frame(height: 12)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
                
                // Creation Date Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.white.opacity(0.8))
                        Text("Oluşturulma Tarihi")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                    }
                    
                    if let createdDate = route.formattedCreatedDate {
                        Text(createdDate)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                    }
                    
                    if let relativeCreatedTime = route.relativeCreatedTime {
                        Text(relativeCreatedTime)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                )
            }
        }
    }
}

// Route Reports View
struct RouteReportsView: View {
    let route: Route
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Rapor Bilgileri")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 16),
                GridItem(.flexible(), spacing: 16)
            ], spacing: 16) {
                ReportCard(title: "Görüntülenme", value: "1,234", icon: "eye.fill", color: .blue)
                ReportCard(title: "Geçiş", value: "567", icon: "figure.walk", color: .green)
                ReportCard(title: "Ortalama Yaş", value: "32", icon: "person.fill", color: .orange)
                ReportCard(title: "Cinsiyet Dağılımı", value: "%60 Erkek", icon: "person.2.fill", color: .purple)
            }
        }
    }
}

// Route Map View
struct RouteMapView: View {
    @Binding var region: MKCoordinateRegion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Konum Bilgileri")
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Map(coordinateRegion: $region)
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        }
    }
}

// Helper Views
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)
            Text(value)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
        }
        .padding(.vertical, 4)
    }
}

struct ReportCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(color.opacity(0.2))
                    )
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

#Preview {
    RouteDetailView(route: Route.preview)
}
