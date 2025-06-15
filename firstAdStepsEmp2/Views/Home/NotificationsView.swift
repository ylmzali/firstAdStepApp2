import SwiftUI

struct NotificationsView: View {
    @State private var notifications: [AppNotification] = [
        AppNotification(title: "Yeni Rota Atandı", message: "Kadıköy - Üsküdar rotası size atandı.", date: "12 Haz 2024", isRead: false),
        AppNotification(title: "Rapor Hazır", message: "Beşiktaş - Levent rotası için raporunuz hazır.", date: "10 Haz 2024", isRead: true),
        AppNotification(title: "Rezervasyon Onaylandı", message: "Bakırköy - Florya rezervasyonunuz onaylandı.", date: "9 Haz 2024", isRead: false)
    ]

    var body: some View {
        NavigationView {
            List {
                ForEach(notifications) { notification in
                    NotificationRow(notification: notification)
                }
            }
            .listStyle(.plain)
            .navigationTitle("Bildirimler")
        }
    }
}

struct AppNotification: Identifiable {
    let id = UUID()
    let title: String
    let message: String
    let date: String
    let isRead: Bool
}

struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Circle()
                .fill(notification.isRead ? Color.gray.opacity(0.3) : Color.blue)
                .frame(width: 12, height: 12)
                .padding(.top, 6)
            VStack(alignment: .leading, spacing: 4) {
                Text(notification.title)
                    .font(.headline)
                    .foregroundColor(notification.isRead ? .gray : .black)
                Text(notification.message)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(notification.date)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.vertical, 8)
        .background(notification.isRead ? Color(.systemGray6) : Color(.systemGray5).opacity(0.5))
        .cornerRadius(10)
    }
} 