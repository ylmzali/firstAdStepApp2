import SwiftUI
import MapKit

struct ActiveRoutesMapView: View {
    @StateObject var viewModel: ActiveRoutesViewModel
    @State private var selectedSchedule: ActiveSchedule?
    @State private var showingScheduleDetail = false
    @State private var showingFilterSheet = false
    @State private var selectedAnnotation: RouteMapAnnotation?
    @State private var hasAppeared = false
    
    // Filter state'leri viewModel'den al
    @State private var selectedEmployeeId: Int? {
        didSet {
            viewModel.selectedEmployeeId = selectedEmployeeId
        }
    }
    
    private let navigationManager = NavigationManager.shared
    
    var body: some View {
        ZStack {
            MapWithPolylines(
                region: viewModel.region,
                annotations: viewModel.mapAnnotations,
                polylines: viewModel.directionPolylines + viewModel.sessionPolylines,
                areaCircles: viewModel.areaCircles,
                onAnnotationTap: { annotation in
                    selectedAnnotation = annotation
                }
            )
            .ignoresSafeArea()
                
            // Top Controls
            VStack {
                HStack {
                    
                    // Filters Button
                    Button(action: {
                        showingFilterSheet = true
                    }) {
                        HStack {
                            Image(systemName: "line.3.horizontal.decrease.circle.fill")
                            Text("Filtreler")
                        }
                        .padding(8)
                        .foregroundColor(.white)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(24)
                    }

                    Spacer()

                    // Close Button
                    Button(action: {
                        navigationManager.goToHome()
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title)
                            .foregroundColor(.black.opacity(0.6))
                            .background(Color.white.opacity(0.6))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.top, 80)
                
                Spacer()
            }
            .ignoresSafeArea()
            
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
                    viewModel.loadActiveRoutes()
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(item: $selectedAnnotation) { annotation in
            ScheduleDetailSheet(schedule: annotation.schedule)
        }
        .sheet(isPresented: $showingFilterSheet) {
            FilterSheet(
                selectedEmployeeId: $selectedEmployeeId,
                viewModel: viewModel,
                schedules: viewModel.schedules,
                onApply: {
                    // Eğer employee filtresi varsa onu da uygula
                    if let employeeId = selectedEmployeeId {
                        viewModel.filterByEmployee(employeeId)
                    } else {
                        // Sadece route filtrelemesi yap
                        viewModel.prepareMapData()
                        // Seçilen rotalara zoom yap
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            viewModel.zoomToSelectedRoutes()
                        }
                    }
                }
            )
        }
        .onAppear {
            if !hasAppeared {
                hasAppeared = true
                
                // Delay the loading to avoid publishing changes during view updates
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    viewModel.loadActiveRoutes()
                }
            }
            
            // Debug: Polyline sayısını kontrol et
            let totalPolylines = viewModel.directionPolylines.count + viewModel.sessionPolylines.count
            print("🗺️ ActiveRoutesMapView - Total polylines: \(totalPolylines)")
            print("🗺️ ActiveRoutesMapView - Direction polylines: \(viewModel.directionPolylines.count)")
            print("🗺️ ActiveRoutesMapView - Session polylines: \(viewModel.sessionPolylines.count)")
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
    @Binding var selectedEmployeeId: Int?
    let viewModel: ActiveRoutesViewModel
    let schedules: [ActiveSchedule]
    let onApply: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("Aktif Rotalar") {
                    if schedules.isEmpty {
                        Text("Henüz rota bulunmuyor")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(schedules, id: \.routeId) { schedule in
                            if let routeId = schedule.routeId {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Rota \(routeId)")
                                            .font(.headline)
                                        Text(schedule.routeType == "fixed_route" ? "Sabit Rota" : "Alan Rota")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        if let routeId = schedule.routeId {
                                            if viewModel.selectedRouteIds.contains(routeId) {
                                                viewModel.selectedRouteIds.remove(routeId)
                                            } else {
                                                viewModel.selectedRouteIds.insert(routeId)
                                            }
                                        }
                                    }) {
                                        Image(systemName: viewModel.selectedRouteIds.contains(routeId) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(viewModel.selectedRouteIds.contains(routeId) ? .blue : .gray)
                                            .font(.title2)
                                    }
                                }
                                .padding(.vertical, 4)
                            }
                        }
                        
                        Button("Tümünü Seç") {
                            viewModel.selectedRouteIds = Set(schedules.compactMap { $0.routeId })
                        }
                        .foregroundColor(.blue)
                        
                        Button("Seçimi Temizle") {
                            viewModel.selectedRouteIds.removeAll()
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Filtreler")
            .toolbarColorScheme(.dark, for: .navigationBar)
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
