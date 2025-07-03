import Foundation
import CoreLocation

// MARK: - Active Routes Response Model
struct ActiveRoutesResponse: Codable {
    let success: Bool
    let message: String
    let data: ActiveRoutesData
}

struct ActiveRoutesData: Codable {
    let schedules: [ActiveSchedule]
}

struct ActiveSchedule: Codable, Identifiable {
    let id: Int
    let routeId: Int?
    let assignedPlanId: Int?
    let assignedScreenId: Int?
    let assignedEmployeeId: Int?
    let scheduleDate: String?
    let startTime: String?
    let endTime: String?
    let displayDurationMinutes: Int?
    let pricePerHour: Double?
    let budget: Double?
    let routeType: String? // 'fixed_route' veya 'area_route'
    let startLat: Double?
    let startLng: Double?
    let endLat: Double?
    let endLng: Double?
    let centerLat: Double?
    let centerLng: Double?
    let radiusMeters: Int?
    let status: String?
    let createdBy: String?
    let createdAt: String?
    let screenSessions: [ScreenSession]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case routeId = "route_id"
        case assignedPlanId = "assigned_plan_id"
        case assignedScreenId = "assigned_screen_id"
        case assignedEmployeeId = "assigned_employee_id"
        case scheduleDate = "schedule_date"
        case startTime = "start_time"
        case endTime = "end_time"
        case displayDurationMinutes = "display_duration_minutes"
        case pricePerHour = "price_per_hour"
        case budget
        case routeType = "route_type"
        case startLat = "start_lat"
        case startLng = "start_lng"
        case endLat = "end_lat"
        case endLng = "end_lng"
        case centerLat = "center_lat"
        case centerLng = "center_lng"
        case radiusMeters = "radius_meters"
        case status
        case createdBy = "created_by"
        case createdAt = "created_at"
        case screenSessions
    }
}

struct ScreenSession: Codable, Identifiable {
    let id: Int
    let assignedScheduleId: Int
    let sessionDate: String
    let actualStartTime: String?
    let actualEndTime: String?
    let actualDurationMin: Int?
    let currentLat: Double?
    let currentLng: Double?
    let batteryLevel: Int?
    let signalStrength: Int?
    let status: String?
    let lastUpdate: String?

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: currentLat ?? 0.0, longitude: currentLng ?? 0.0)
    }
}

 
