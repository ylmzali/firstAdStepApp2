import Foundation
import MapKit
import SwiftUI

@MainActor
class ActiveRoutesViewModel: ObservableObject {
    @Published var schedules: [ActiveSchedule] = []
    @Published var error: ServiceError?
    @Published var selectedEmployeeId: Int?
    @Published var selectedRouteIds: Set<Int> = [] // Seçili rota ID'leri
    
    // Map properties
    @Published var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 41.0251, longitude: 28.9934), // İstanbul merkez
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    @Published var mapAnnotations: [RouteMapAnnotation] = []
    @Published var directionPolylines: [PolylineWrapper] = [] // Directions API'den gelen polyline
    @Published var sessionPolylines: [PolylineWrapper] = []   // ScreenSession'dan gelen polyline
    @Published var areaCircles: [MKCircle] = []          // Area route için çemberler
    
    private let service = ActiveRoutesService.shared
    
    init() {
        // loadActiveRoutes()
    }
    
    func loadActiveRoutes() {
        let userId = SessionManager.shared.currentUser?.id ?? "0"
        
        service.getActiveRoutes(date: Date(), userId: userId, status: "active", employeeId: selectedEmployeeId) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    let hasValidRouteData = response.data.schedules.contains { schedule in
                        schedule.routeType != nil && schedule.routeType != ""
                    }
                    
                    if hasValidRouteData {
                        self?.schedules = response.data.schedules
                        self?.prepareMapData()
                    } else {
                        self?.error = ServiceError.custom(message: "Aktif rota bulunamadı. Lütfen daha sonra tekrar deneyin veya filtre ayarlarınızı kontrol edin.")
                    }
                    
                case .failure(let error):
                    self?.error = error
                }
            }
        }
    }
    
    // Map için annotation ve polyline hazırlama
    func prepareMapData() {
        print("🔵 -- prepareMapData başladı")
        print("🔵 -- Schedules count: \(schedules.count)")
        print("🔵 -- Selected route IDs: \(selectedRouteIds)")
        
        // Clear existing data
        self.directionPolylines = []
        self.sessionPolylines = []
        self.areaCircles = []
        
        // Annotations
        var annotations: [RouteMapAnnotation] = []
        var sessionPolylines: [PolylineWrapper] = []
        var directionPolylines: [PolylineWrapper] = []
        var areaCircles: [MKCircle] = []
        
        // Sadece seçili rotaları filtrele (boşsa tümünü göster)
        let filteredSchedules = selectedRouteIds.isEmpty ? schedules : schedules.filter { schedule in
            guard let routeId = schedule.routeId else { return false }
            return selectedRouteIds.contains(routeId)
        }
        
        print("🔵 -- Filtered schedules count: \(filteredSchedules.count)")
        
        for (index, schedule) in filteredSchedules.enumerated() {
            print("🔵 -- Processing schedule \(index + 1): \(schedule.id), routeType: \(schedule.routeType ?? "nil")")
            
            // Route type'a göre farklı gösterim
            if let routeType = schedule.routeType, routeType == "fixed_route" {
                print("🔵 -- Fixed route detected for schedule \(schedule.id)")
                
                // Fixed Route: Başlangıç ve bitiş noktası arasında polyline
                if let startLat = schedule.startLat, let startLng = schedule.startLng,
                   let endLat = schedule.endLat, let endLng = schedule.endLng {
                    
                    print("🔵 -- Creating direction polyline for schedule \(schedule.id)")
                    
                    // Başlangıç ve bitiş annotation'ları
                    let startAnnotation = RouteMapAnnotation(
                        coordinate: CLLocationCoordinate2D(latitude: startLat, longitude: startLng),
                        type: .start,
                        color: .blue,
                        schedule: schedule,
                        isLarge: true
                    )
                    annotations.append(startAnnotation)
                    
                    let endAnnotation = RouteMapAnnotation(
                        coordinate: CLLocationCoordinate2D(latitude: endLat, longitude: endLng),
                        type: .end,
                        color: .red,
                        schedule: schedule,
                        isLarge: true
                    )
                    annotations.append(endAnnotation)
                    
                    // Direction polyline oluştur (başlangıçtan bitişe)
                    let coordinates = [
                        CLLocationCoordinate2D(latitude: startLat, longitude: startLng),
                        CLLocationCoordinate2D(latitude: endLat, longitude: endLng)
                    ]
                    print("🔵 -- Direction coordinates for schedule \(schedule.id): start(\(startLat), \(startLng)) -> end(\(endLat), \(endLng))")
                    let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                    let wrapper = PolylineWrapper(
                        polyline: polyline,
                        type: .direction,
                        scheduleId: schedule.id
                    )
                    directionPolylines.append(wrapper)
                    print("🔵 -- Direction polyline created for schedule \(schedule.id)")
                } else {
                    print("🔵 -- Missing coordinates for schedule \(schedule.id)")
                }
            } else if let routeType = schedule.routeType, routeType == "area_route" {
                print("🔵 -- Area route detected for schedule \(schedule.id)")
                
                // Area Route: Merkez nokta etrafında çember
                if let centerLat = schedule.centerLat, let centerLng = schedule.centerLng {
                    // Merkez annotation
                    let centerAnnotation = RouteMapAnnotation(
                        coordinate: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng),
                        type: .waypoint,
                        color: .blue,
                        schedule: schedule,
                        isLarge: true
                    )
                    annotations.append(centerAnnotation)
                    
                    // Çember oluştur (radius_meters cinsinden)
                    let radius = schedule.radiusMeters ?? 1000 // Varsayılan 1000 metre
                    let circle = MKCircle(center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng), radius: CLLocationDistance(radius))
                    areaCircles.append(circle)
                    print("🔵 -- Area circle created for schedule \(schedule.id) with radius \(radius)")
                }
            }
            
            // Screen session'ları için polyline oluştur
            if let screenSessions = schedule.screenSessions, screenSessions.count > 1 {
                print("🔵 -- Creating session polyline for schedule \(schedule.id), sessions count: \(screenSessions.count)")
                
                var coordinates: [CLLocationCoordinate2D] = []
                
                for session in screenSessions {
                    if let lat = session.currentLat, let lng = session.currentLng {
                        coordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lng))
                    }
                }
                
                if coordinates.count > 1 {
                    let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
                    let wrapper = PolylineWrapper(
                        polyline: polyline,
                        type: .session,
                        scheduleId: schedule.id
                    )
                    sessionPolylines.append(wrapper)
                    print("🔵 -- Session polyline created for schedule \(schedule.id) with \(coordinates.count) coordinates")
                } else {
                    print("🔵 -- Not enough coordinates for session polyline in schedule \(schedule.id)")
                }
            } else {
                print("🔵 -- No screen sessions or not enough sessions for schedule \(schedule.id)")
            }
        }
        
        print("🔵 -- Final counts - Direction polylines: \(directionPolylines.count), Session polylines: \(sessionPolylines.count)")
        
        // UI'ı güncelle
        DispatchQueue.main.async { [weak self] in
            self?.mapAnnotations = annotations
            self?.directionPolylines = directionPolylines
            self?.sessionPolylines = sessionPolylines
            self?.areaCircles = areaCircles
            
            // Debug: Polyline sayısını kontrol et
            let totalPolylines = directionPolylines.count + sessionPolylines.count
            print("🔵 -- Polyline sayısı: \(totalPolylines)")
            print("🔵 -- Direction polylines: \(directionPolylines.count)")
            print("🔵 -- Session polylines: \(sessionPolylines.count)")
            
            // Zoom to routes
            self?.zoomToSelectedRoutes()
        }
    }
    
    // Filter Methods
    func filterByEmployee(_ employeeId: Int?) {
        selectedEmployeeId = employeeId
        loadActiveRoutes()
    }
    
    func clearFilters() {
        selectedEmployeeId = nil
        loadActiveRoutes()
    }
    
    // Seçilen rotaların tümünü kapsayan bölgeye zoom yap
    func zoomToSelectedRoutes() {
        // Hiçbiri seçili değilse tüm rotaları göster
        let routesToShow = selectedRouteIds.isEmpty ? Set(schedules.compactMap { $0.routeId }) : selectedRouteIds
        guard !routesToShow.isEmpty else { return }
        
        // Seçilen rotaları filtrele
        let selectedSchedules = schedules.filter { schedule in
            guard let routeId = schedule.routeId else { return false }
            return routesToShow.contains(routeId)
        }
        
        guard !selectedSchedules.isEmpty else { return }
        
        var allCoordinates: [CLLocationCoordinate2D] = []
        
        for schedule in selectedSchedules {
            if let routeType = schedule.routeType {
                if routeType == "fixed_route" {
                    // Fixed route için başlangıç ve bitiş noktaları
                    if let startLat = schedule.startLat, let startLng = schedule.startLng {
                        allCoordinates.append(CLLocationCoordinate2D(latitude: startLat, longitude: startLng))
                    }
                    if let endLat = schedule.endLat, let endLng = schedule.endLng {
                        allCoordinates.append(CLLocationCoordinate2D(latitude: endLat, longitude: endLng))
                    }
                } else if routeType == "area_route" {
                    // Area route için merkez nokta
                    if let centerLat = schedule.centerLat, let centerLng = schedule.centerLng {
                        allCoordinates.append(CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng))
                    }
                }
            }
            
            // Screen session koordinatlarını da ekle
            if let screenSessions = schedule.screenSessions {
                for session in screenSessions {
                    if let lat = session.currentLat, let lng = session.currentLng {
                        allCoordinates.append(CLLocationCoordinate2D(latitude: lat, longitude: lng))
                    }
                }
            }
        }
        
        guard !allCoordinates.isEmpty else { return }
        
        // Tüm koordinatları kapsayan bölge hesapla
        let region = calculateRegionForCoordinates(allCoordinates)
        
        // Harita bölgesini güncelle
        DispatchQueue.main.async { [weak self] in
            self?.region = region
        }
    }
    
    // Koordinat listesi için bölge hesapla
    private func calculateRegionForCoordinates(_ coordinates: [CLLocationCoordinate2D]) -> MKCoordinateRegion {
        guard !coordinates.isEmpty else {
            return MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 41.0251, longitude: 28.9934), // İstanbul merkez
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
        }
        
        var minLat = coordinates[0].latitude
        var maxLat = coordinates[0].latitude
        var minLng = coordinates[0].longitude
        var maxLng = coordinates[0].longitude
        
        for coordinate in coordinates {
            minLat = min(minLat, coordinate.latitude)
            maxLat = max(maxLat, coordinate.latitude)
            minLng = min(minLng, coordinate.longitude)
            maxLng = max(maxLng, coordinate.longitude)
        }
        
        let centerLat = (minLat + maxLat) / 2
        let centerLng = (minLng + maxLng) / 2
        
        // Span hesapla (biraz daha genişlet)
        let latDelta = (maxLat - minLat) * 1.2 // %20 daha geniş
        let lngDelta = (maxLng - minLng) * 1.2
        
        // Minimum span değerleri
        let minSpan = 0.01 // Yaklaşık 1km
        let finalLatDelta = max(latDelta, minSpan)
        let finalLngDelta = max(lngDelta, minSpan)
        
        return MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: centerLat, longitude: centerLng),
            span: MKCoordinateSpan(latitudeDelta: finalLatDelta, longitudeDelta: finalLngDelta)
        )
    }
    
    private func colorForSchedule(_ id: Int) -> Color {
        let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink, .yellow, .teal, .indigo, .mint]
        return colors[id % colors.count]
    }
}

// MARK: - Map Annotation Model
struct RouteMapAnnotation: Identifiable, Equatable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let type: AnnotationType
    let color: Color
    let schedule: ActiveSchedule
    let isLarge: Bool // true: büyük ikon (schedule), false: küçük ikon (screen session)
    
    enum AnnotationType: Equatable { 
        case start, end, waypoint 
    }
    
    static func == (lhs: RouteMapAnnotation, rhs: RouteMapAnnotation) -> Bool {
        lhs.id == rhs.id
    }
}

struct RoutePolyline: Identifiable {
    let id = UUID()
    let coordinates: [CLLocationCoordinate2D]
    let color: Color
    let lineWidth: CGFloat
    let routeType: RouteType
    
    enum RouteType {
        case schedule      // Başlangıç-bitiş rotası
        case screenSession // Gezinti verisi rotası
    }
}

// MARK: - Polyline Wrapper
struct PolylineWrapper {
    let polyline: MKPolyline
    let type: PolylineType
    let scheduleId: Int
    
    enum PolylineType {
        case direction  // Başlangıç-bitiş rotası
        case session    // Screen session rotası
    }
} 


