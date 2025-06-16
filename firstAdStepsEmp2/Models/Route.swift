import Foundation

// User Model
struct Route: Codable, Identifiable {
    let id: String
    let userId: String
    var title: String
    var description: String
    var status: String
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
         status: String,
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
        status = try container.decode(String.self, forKey: .status)
        assignedRouteDetailId = try container.decodeIfPresent(String.self, forKey: .assignedRouteDetailId)
        assignedDate = try container.decodeIfPresent(String.self, forKey: .assignedDate)
        completion = try container.decode(Int.self, forKey: .completion)
        createdAt = try container.decode(String.self, forKey: .createdAt)
    }

    // Preview için test verisi
    static let preview = Route(
        id: "1",
        userId: "1233",
        title: "Kadıköy - Üsküdar",
        description: "Kadıköy'den Üsküdar'a giden rota",
        status: "Bekliyor",
        assignedRouteDetailId: "1",
        assignedDate: "2024-03-20T12:00:00Z",
        completion: 0,
        createdAt: "2024-03-20T12:00:00Z"
    )
}
