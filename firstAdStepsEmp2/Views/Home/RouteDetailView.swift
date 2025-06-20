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
                                // .mask(MeshGradientBackground())
                            
                            StatusBadge(status: route.status)
                                .scaleEffect(1.1)
                        }
                        
                        // Date Section
                        if let assignedDateValue = route.assignedDate,
                           let assignedDate = assignedDateValue.toDate {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "calendar.circle.fill")
                                        .foregroundColor(.white.opacity(0.8))
                                    Text(DateFormatter.turkishDateString(from: assignedDate))
                                        .font(.headline)
                                        .foregroundColor(.white)
                                }
                                
                                HStack {
                                    Image(systemName: "clock.circle.fill")
                                        .foregroundColor(.white.opacity(0.8))
                                    Text(DateFormatter.timeString(from: assignedDate))
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))
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
                        } else {
                            VStack(alignment: .center, spacing: 16) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 48))
                                    .foregroundColor(.orange)
                                Text("Henüz onaylanıp rota ataması yapılmadı!")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.orange.opacity(0.2))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.orange.opacity(0.4), lineWidth: 2)
                                    )
                            )
                        }
                    }
                    .padding(.top, 50)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 50)
                    
                    // Content Sections
                    VStack(spacing: 50) {
                        RouteInfoView(route: route)
                        RouteReportsView(route: route)
                        RouteMapView(region: $region)
                    }
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
