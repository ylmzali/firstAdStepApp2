import SwiftUI
import MapKit

struct ActiveRoutesMapView: View {
    @ObservedObject var viewModel: ActiveRoutesViewModel
    @State private var selectedAnnotation: RouteMapAnnotation?
    @State private var showingDetailSheet = false
    @State private var showingFilters = false
    @EnvironmentObject private var navigationManager: NavigationManager
    
    init(viewModel: ActiveRoutesViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        let coordinateCount = viewModel.schedules.reduce(0) { total, schedule in
            total + (schedule.screenSessions?.filter { $0.currentLat != nil && $0.currentLng != nil }.count ?? 0)
        }
        ZStack {
            MapWithPolylines(
                region: viewModel.region,
                annotations: viewModel.mapAnnotations,
                directionPolylines: viewModel.directionPolylines,
                sessionPolylines: viewModel.sessionPolylines,
                areaCircles: viewModel.areaCircles
            )
            .ignoresSafeArea()
                
                // Top Controls
                VStack {
                    HStack {
                        Spacer()
                        
                        // Filters Button
                        Button(action: {
                            showingFilters = true
                        }) {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                                .padding(8)
                        }
                        
                        // Close Button
                        Button(action: {
                            navigationManager.goToHome()
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.6))
                                .clipShape(Circle())
                                .padding(8)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 50)
                    
                    Spacer()
                    
                    // Test Statistics Cards - Sadece Schedules ve ScreenSessions
                    VStack(spacing: 12) {
                        HStack(spacing: 12) {
                            MapStatCard(
                                icon: "calendar",
                                title: "Schedules",
                                value: "\(viewModel.schedules.count)",
                                color: .blue
                            )
                            
                            MapStatCard(
                                icon: "play.circle",
                                title: "ScreenSessions",
                                value: "\(viewModel.schedules.reduce(0) { $0 + ($1.screenSessions?.count ?? 0) })",
                                color: .green
                            )
                            
                            MapStatCard(
                                icon: "checkmark.circle",
                                title: "Annotations",
                                value: "\(viewModel.mapAnnotations.count)",
                                color: .orange
                            )
                        }
                        
                        HStack(spacing: 12) {
                            MapStatCard(
                                icon: "map",
                                title: "Polylines",
                                value: "\(viewModel.directionPolylines.count + viewModel.sessionPolylines.count)",
                                color: .purple
                            )
                            
                            MapStatCard(
                                icon: "location",
                                title: "Coordinates",
                                value: "\(coordinateCount)",
                                color: .red
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 100) // TabBar için extra padding
                }
                
                // Loading Overlay
                if SessionManager.shared.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5)
                }
                
                // Error Overlay
                if let error = viewModel.error {
                    ErrorView(message: error.userMessage) {
                        viewModel.loadActiveSchedules()
                    }
                }
            }
            .navigationBarHidden(true)
        .sheet(isPresented: $showingDetailSheet) {
            if let annotation = selectedAnnotation {
                ScheduleDetailSheet(schedule: annotation.schedule)
            }
        }
        .sheet(isPresented: $showingFilters) {
            FilterSheet(
                selectedDate: $viewModel.selectedDate,
                selectedStatus: $viewModel.selectedStatus,
                selectedEmployeeId: $viewModel.selectedEmployeeId,
                onApply: {
                    viewModel.loadActiveSchedules()
                }
            )
        }
        .onAppear {
            print("🗺️ ActiveRoutesMapView appeared")
            print("📍 Current region: \(viewModel.region.center.latitude), \(viewModel.region.center.longitude)")
            print("📍 Region span: \(viewModel.region.span.latitudeDelta), \(viewModel.region.span.longitudeDelta)")
            
            // Delay the loading to avoid publishing changes during view updates
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                viewModel.loadActiveSchedules()
            }
        }
        .onChange(of: viewModel.mapAnnotations) { annotations in
            print("🗺️ Map annotations updated: \(annotations.count) annotations")
            for (index, annotation) in annotations.enumerated() {
                print("   \(index + 1). \(annotation.type) at \(annotation.coordinate.latitude), \(annotation.coordinate.longitude)")
            }
        }
    }
    
    // MARK: - Helper Functions
    private func annotationIcon(for type: RouteMapAnnotation.AnnotationType) -> String {
        switch type {
        case .start:
            return "play.circle.fill"
        case .end:
            return "stop.circle.fill"
        case .waypoint:
            return "circle.fill"
        }
    }
}

// MARK: - Annotation View
struct AnnotationView: View {
    let annotation: RouteMapAnnotation
    let onTap: () -> Void
    
    private func annotationIcon(for type: RouteMapAnnotation.AnnotationType) -> String {
        switch type {
        case .start:
            return "play.circle.fill"
        case .end:
            return "stop.circle.fill"
        case .waypoint:
            return "circle.fill"
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                Image(systemName: annotationIcon(for: annotation.type))
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(annotation.color)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 2)
                    )
                    .shadow(radius: 3)
            }
        }
    }
}

// MARK: - Map Stat Card
struct MapStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                
                Spacer()
            }
            
            HStack {
                Text(value)
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack {
                Text(title)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
            }
        }
        .padding(12)
        .background(Color.black.opacity(0.7))
        .cornerRadius(8)
    }
}

// MARK: - Schedule Detail Sheet
struct ScheduleDetailSheet: View {
    let schedule: ActiveSchedule
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rota Detayı")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        Text("ID: \(schedule.id)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Divider()
                    
                    // ScreenSessions Info
                    VStack(alignment: .leading, spacing: 12) {
                        Text("ScreenSessions: \(schedule.screenSessions?.count ?? 0)")
                            .font(.headline)
                        ForEach(schedule.screenSessions ?? []) { session in
                            HStack {
                                Text("Session ID: \(session.id)")
                                Spacer()
                                if let lat = session.currentLat, let lng = session.currentLng {
                                    Text("(\(lat), \(lng))")
                                } else {
                                    Text("Konum yok")
                                }
                            }
                            .font(.caption)
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Detay")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Kapat") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Info Row
struct MapInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

// MARK: - Filter Sheet
struct FilterSheet: View {
    @Binding var selectedDate: Date
    @Binding var selectedStatus: String?
    @Binding var selectedEmployeeId: Int?
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    private let statusOptions = ["Tümü", "Aktif", "Tamamlanan", "Beklemede"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("Tarih") {
                    DatePicker("Tarih Seçin", selection: $selectedDate, displayedComponents: .date)
                }
                
                Section("Durum") {
                    Picker("Durum", selection: $selectedStatus) {
                        Text("Tümü").tag(nil as String?)
                        ForEach(statusOptions.dropFirst(), id: \.self) { status in
                            Text(status).tag(status as String?)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
            }
            .navigationTitle("Filtreler")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("İptal") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Uygula") {
                        onApply()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    ActiveRoutesMapView(viewModel: ActiveRoutesViewModel())
}
