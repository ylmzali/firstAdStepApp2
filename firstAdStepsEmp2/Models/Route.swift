import Foundation
import SwiftUI

enum RouteStatus: String, Codable {
    case pending = "pending"
    case approved = "approved"
    case active = "active"
    case paused = "paused"
    case completed = "completed"
    case cancelled = "cancelled"
    
    var statusColor: Color {
        switch self {
        case .pending: return .gray
        case .approved: return .blue
        case .active: return .green
        case .paused: return .yellow
        case .completed: return .black
        case .cancelled: return .red
        }
    }
}

// Progress Color based on completion percentage
enum ProgressColor {
    case low      // 0-30%
    case medium   // 31-70%
    case high     // 71-100%
    
    static func fromCompletion(_ completion: Int) -> ProgressColor {
        switch completion {
        case 0...30:
            return .low
        case 31...70:
            return .medium
        case 71...100:
            return .high
        default:
            return .low
        }
    }
    
    var color: Color {
        switch self {
        case .low:
            return .red
        case .medium:
            return .orange
        case .high:
            return .green
        }
    }
}

// User Model
struct Route: Codable, Identifiable {
    let id: String
    let userId: String
    var title: String
    var description: String
    var status: RouteStatus
    var assignedRouteDetailId: String?
    var assignedDate: String?
    var completion: Int
    var createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case title
        case description
        case status
        case assignedRouteDetailId
        case assignedDate
        case completion
        case createdAt = "createdAt"
    }

    // Normal initializer
    init(id: String,
         userId: String,
         title: String,
         description: String,
         status: RouteStatus,
         assignedRouteDetailId: String?,
         assignedDate: String?,
         completion: Int,
         createdAt: String
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.description = description
        self.status = status
        self.assignedRouteDetailId = assignedRouteDetailId
        self.assignedDate = assignedDate
        self.completion = completion
        self.createdAt = createdAt
    }

    // Decoder initializer
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decode(String.self, forKey: .id)
        userId = try container.decode(String.self, forKey: .userId)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        status = try container.decode(RouteStatus.self, forKey: .status)
        assignedRouteDetailId = try container.decodeIfPresent(String.self, forKey: .assignedRouteDetailId)
        assignedDate = try container.decodeIfPresent(String.self, forKey: .assignedDate)
        completion = try container.decode(Int.self, forKey: .completion)
        createdAt = try container.decode(String.self, forKey: .createdAt)
    }

    // Preview için test verisi
    static let preview = Route(
        id: "1",
        userId: "1233",
        title: "Kadıköy - Üsküdar Kadıköy'den Üsküdar'a giden rota Kadıköy'den Üsküdar'a giden rota",
        description: "Kadıköy - Üsküdar Kadıköy'den Üsküdar'a giden rota Kadıköy'den Üsküdar'a giden rota",
        status: .active,
        assignedRouteDetailId: "1",
        // assignedDate: "2024-03-20T12:00:00Z",
        assignedDate: nil,
        completion: 80,
        createdAt: "2024-03-20T12:00:00Z"
    )
}
