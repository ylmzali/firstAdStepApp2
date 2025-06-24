import Foundation
import SwiftUI

enum RouteStatus: String, Codable {
    case pending = "pending"           // Rota oluşturuldu
    case proposal_pending = "proposal_pending"  // Çalışma planı hazırlanıyor
    case proposal_ready = "proposal_ready"  // Çalışma planı hazır, firma onayı bekleniyor
    case proposal_approved = "proposal_approved"  // Çalışma planı onaylandı, ödeme bekleniyor
    case payment_pending = "payment_pending"  // Ödeme bekleniyor
    case payment_completed = "payment_completed"  // Ödeme tamamlandı, son onay bekleniyor
    case final_approval = "final_approval"  // Son onay, canlı takip öncesi
    case scheduled = "scheduled"       // Tarih atandı, başlama bekleniyor
    case active = "active"             // Aktif, canlı takip edilebilir
    case paused = "paused"             // Duraklatıldı
    case completed = "completed"       // Tamamlandı
    case cancelled = "cancelled"       // İptal edildi
    
    var statusColor: Color {
        switch self {
        case .pending: return .gray
        case .proposal_pending: return .blue
        case .proposal_ready: return .orange
        case .proposal_approved: return .purple
        case .payment_pending: return .yellow
        case .payment_completed: return .green
        case .final_approval: return .red
        case .scheduled: return .purple
        case .active: return .green
        case .paused: return .gray
        case .completed: return .blue
        case .cancelled: return .red
        }
    }
    
    var statusDescription: String {
        switch self {
        case .pending:
            return "Rota oluşturuldu"
        case .proposal_pending:
            return "Çalışma planı hazırlanıyor"
        case .proposal_ready:
            return "Çalışma planı hazır"
        case .proposal_approved:
            return "Plan onaylandı"
        case .payment_pending:
            return "Ödeme bekleniyor"
        case .payment_completed:
            return "Ödeme tamamlandı"
        case .final_approval:
            return "Son onay bekleniyor"
        case .scheduled:
            return "Tarih atandı"
        case .active:
            return "Aktif"
        case .paused:
            return "Duraklatıldı"
        case .completed:
            return "Tamamlandı"
        case .cancelled:
            return "İptal edildi"
        }
    }
    
    var canStartLiveTracking: Bool {
        return self == .active
    }
    
    var isWaitingForProposal: Bool {
        return self == .proposal_pending || self == .proposal_ready
    }
    
    var isWaitingForPayment: Bool {
        return self == .payment_pending
    }
    
    var isWaitingForApproval: Bool {
        return self == .proposal_approved || self == .final_approval
    }
    
    var isScheduled: Bool {
        return self == .scheduled
    }
    
    var isInProposalPhase: Bool {
        return self == .proposal_pending || self == .proposal_ready || self == .proposal_approved
    }
    
    var isAfterProposal: Bool {
        return self == .proposal_approved || self == .payment_pending || self == .payment_completed || self == .final_approval || self == .scheduled || self == .active || self == .completed
    }
    
    var isAfterApproval: Bool {
        return self == .payment_pending || self == .payment_completed || self == .final_approval || self == .scheduled || self == .active || self == .completed
    }
    
    var isAfterPayment: Bool {
        return self == .payment_completed || self == .final_approval || self == .scheduled || self == .active || self == .completed
    }
    
    var isAfterFinalApproval: Bool {
        return self == .scheduled || self == .active || self == .completed
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
    var assignedDate: String?
    var completion: Int
    var shareWithEmployees: Bool
    var sharedEmployeeIds: [String] // Seçilen çalışanların ID'leri
    var createdAt: String

    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case title
        case description
        case status
        case assignedDate
        case completion
        case shareWithEmployees
        case sharedEmployeeIds
        case createdAt = "createdAt"
    }

    // Normal initializer
    init(id: String,
         userId: String,
         title: String,
         description: String,
         status: RouteStatus,
         assignedDate: String?,
         completion: Int,
         shareWithEmployees: Bool = false,
         sharedEmployeeIds: [String] = [],
         createdAt: String
    ) {
        self.id = id
        self.userId = userId
        self.title = title
        self.description = description
        self.status = status
        self.assignedDate = assignedDate
        self.completion = completion
        self.shareWithEmployees = shareWithEmployees
        self.sharedEmployeeIds = sharedEmployeeIds
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
        assignedDate = try container.decodeIfPresent(String.self, forKey: .assignedDate)
        completion = try container.decode(Int.self, forKey: .completion)
        shareWithEmployees = try container.decodeIfPresent(Bool.self, forKey: .shareWithEmployees) ?? false
        sharedEmployeeIds = try container.decodeIfPresent([String].self, forKey: .sharedEmployeeIds) ?? []
        createdAt = try container.decode(String.self, forKey: .createdAt)
    }

    // MARK: - Computed Properties for Formatted Dates
    
    /// Formatlanmış atama tarihi (örn: 24 Haziran 2025)
    var formattedAssignedDate: String? {
        guard let assignedDate = assignedDate else { return nil }
        return assignedDate.toTurkishDate
    }
    
    /// Formatlanmış atama tarihi ve saati (örn: 24 Haziran 2025, 13:19)
    var formattedAssignedDateTime: String? {
        guard let assignedDate = assignedDate else { return nil }
        return assignedDate.toTurkishDateTime
    }
    
    /// Kısa formatlanmış atama tarihi (örn: 24.06.2025)
    var shortAssignedDate: String? {
        guard let assignedDate = assignedDate else { return nil }
        return assignedDate.toShortDate
    }
    
    /// Kısa formatlanmış atama tarihi ve saati (örn: 24.06.2025 13:19)
    var shortAssignedDateTime: String? {
        guard let assignedDate = assignedDate else { return nil }
        return assignedDate.toShortDateTime
    }
    
    /// Göreceli atama zamanı (örn: 2 saat önce)
    var relativeAssignedTime: String? {
        guard let assignedDate = assignedDate else { return nil }
        return assignedDate.toRelativeTime
    }
    
    /// Formatlanmış oluşturma tarihi (örn: 24 Haziran 2025)
    var formattedCreatedDate: String? {
        return createdAt.toTurkishDate
    }
    
    /// Kısa formatlanmış oluşturma tarihi (örn: 24.06.2025)
    var shortCreatedDate: String? {
        return createdAt.toShortDate
    }
    
    /// Göreceli oluşturma zamanı (örn: 2 saat önce)
    var relativeCreatedTime: String? {
        return createdAt.toRelativeTime
    }

    // MARK: - Live Tracking Status
    
    /// Canlı takip yapılabilir mi?
    var canStartLiveTracking: Bool {
        guard status.canStartLiveTracking else { return false }
        guard let assignedDate = assignedDate, let date = assignedDate.toDate else { return false }
        
        // Atama tarihi geldi mi?
        return Date() >= date
    }
    
    /// Canlı takip durumu açıklaması
    var liveTrackingStatusDescription: String {
        if !status.canStartLiveTracking {
            return status.statusDescription
        }
        
        guard let assignedDate = assignedDate, let date = assignedDate.toDate else {
            return "Tarih ataması bekleniyor"
        }
        
        if Date() < date {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd.MM.yyyy HH:mm"
            return "Başlama tarihi: \(formatter.string(from: date))"
        }
        
        return "Canlı takip başlatılabilir"
    }
    
    /// Canlı takip buton rengi
    var liveTrackingButtonColor: Color {
        if canStartLiveTracking {
            return .green
        } else if status.isInProposalPhase {
            return .blue
        } else if status.isWaitingForPayment {
            return .yellow
        } else if status.isWaitingForApproval {
            return .red
        } else if status.isScheduled {
            return .purple
        } else {
            return .gray
        }
    }

    // Preview için test verisi
    static let preview = Route(
        id: "1",
        userId: "1233",
        title: "Kadıköy - Üsküdar Kadıköy'den Üsküdar'a giden rota Kadıköy'den Üsküdar'a giden rota",
        description: "Kadıköy - Üsküdar Kadıköy'den Üsküdar'a giden rota Kadıköy'den Üsküdar'a giden rota",
        status: .active,
        // assignedDate: "2024-03-20T12:00:00Z",
        assignedDate: nil,
        completion: 80,
        shareWithEmployees: true,
        sharedEmployeeIds: ["1", "2", "1233"],
        createdAt: "2024-03-20T12:00:00Z"
    )
}
