import SwiftUI

struct OrdersView: View {
    @State private var showNewRoute = false
    // Sample data
    let orders: [RouteOrder] = [
        RouteOrder(name: "Kadıköy - Üsküdar", status: "Aktif", start: "Kadıköy", end: "Üsküdar", date: "12 Haz 2024", completion: 75),
        RouteOrder(name: "Beşiktaş - Levent", status: "Tamamlandı", start: "Beşiktaş", end: "Levent", date: "10 Haz 2024", completion: 100),
        RouteOrder(name: "Bakırköy - Florya", status: "Bekliyor", start: "Bakırköy", end: "Florya", date: "15 Haz 2024", completion: 0)
    ]

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Text("Siparişleriniz")
                        .font(.title2).bold()
                    Spacer()
                    Button(action: { showNewRoute = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Yeni Rota Oluştur")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.black)
                        .cornerRadius(12)
                    }
                }
                .padding()

                List {
                    ForEach(orders) { order in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(order.name)
                                    .font(.headline)
                                Spacer()
                                Text(order.status)
                                    .font(.caption)
                                    .foregroundColor(order.statusColor)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(order.statusColor.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            HStack(spacing: 16) {
                                Label(order.start, systemImage: "play.fill")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Label(order.end, systemImage: "flag.checkered")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                Text(order.date)
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            ProgressView(value: Double(order.completion) / 100.0)
                                .tint(order.statusColor)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(.plain)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showNewRoute) {
                NewRouteSheet()
            }
        }
    }
}

struct RouteOrder: Identifiable {
    let id = UUID()
    let name: String
    let status: String
    let start: String
    let end: String
    let date: String
    let completion: Int

    var statusColor: Color {
        switch status {
        case "Aktif": return .green
        case "Tamamlandı": return .blue
        case "Bekliyor": return .orange
        default: return .gray
        }
    }
}

struct NewRouteSheet: View {
    @Environment(\.dismiss) var dismiss
    @State private var routeName = ""
    @State private var start = ""
    @State private var end = ""
    @State private var date = Date()

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rota Bilgileri")) {
                    TextField("Rota Adı", text: $routeName)
                    TextField("Başlangıç Noktası", text: $start)
                    TextField("Bitiş Noktası", text: $end)
                    DatePicker("Tarih", selection: $date, displayedComponents: .date)
                }
            }
            .navigationTitle("Yeni Rota Oluştur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        // Rota kaydetme işlemi
                        dismiss()
                    }
                }
            }
        }
    }
} 