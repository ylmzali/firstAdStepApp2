import SwiftUI

struct RoutesView: View {
    @State private var showNewRoute = false
    @StateObject private var viewModel = RouteViewModel(
        routes: [],
        formVal: Route(
            id: UUID().uuidString,
            userId: SessionManager.shared.currentUser?.id ?? "",
            title: "",
            description: "",
            status: .pending,
            assignedRouteDetailId: "",
            assignedDate: nil,
            completion: 0,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    )
    @EnvironmentObject private var navigationManager: NavigationManager
    @State private var selectedRoute: Route?

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Stats
                        if !viewModel.routes.isEmpty {
                            HStack(spacing: 16) {
                                RouteFuturisticStatBox(icon: "bolt.fill", color: .yellow, title: "Toplam Rota", value: String(viewModel.routes.count))

                                RouteFuturisticStatBox(icon: "eye.fill", color: .blue, title: "Bekleyen", value: String(viewModel.routes.filter { $0.status == .pending }.count))
                                RouteFuturisticStatBox(icon: "checkmark.seal.fill", color: .green, title: "Tamamlandı", value: String(viewModel.routes.filter { $0.status == .completed }.count))
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.black)
                        }
                    
                        // Route List
                        if viewModel.routes.isEmpty {
                                VStack(spacing: 6) {
                                    Image(systemName: "map")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 80, height: 80)
                                        .foregroundColor(.white.opacity(0.3))
                                        .padding(.bottom, 8)
                                    
                                    Text("Henüz bir siparişiniz yok.")
                                        .font(.title3).bold()
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    Text("Yeni bir sipariş oluşturmak için sağ üstteki  Yeni Sipariş butonunu kullanabilirsiniz.")
                                        .multilineTextAlignment(.center)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.6))
                                        .padding(.bottom, 12)
                                    
                                    Button(action: { showNewRoute = true }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "plus.circle.fill")
                                            Text("Yeni Rota")
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.1))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                )
                                        )
                                    }
                                    Button(action: { viewModel.loadRoutes() }) {
                                        HStack(spacing: 6) {
                                            Image(systemName: "arrow.forward.circle.fill")
                                            Text("Yenile")
                                        }
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 12)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color.white.opacity(0.1))
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                                )
                                        )
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(minHeight: 500)
                                .padding(.top, 50)

                        } else {
                            VStack(alignment: .leading) {
                                Text("Reklam Rotaları")
                                    .font(.system(size: 17, weight: .semibold))
                                    .foregroundColor(.white)
                                    .padding(.horizontal)
                                    .padding(.top, 30)
                                
                                LazyVStack(spacing: 12) {
                                    ForEach(viewModel.routes) { route in
                                        Button(action: {
                                            selectedRoute = route
                                        }) {
                                            RouteRowView(route: route)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 16)
                                .padding(.bottom, 100)
                            }
                        }
                    }
                }
                .refreshable {
                    viewModel.loadRoutes()
                }
                .scrollIndicators(.hidden)
                .tint(.white)
                .overlay(
                    VStack {
                        HStack {
                            Spacer()
                            if SessionManager.shared.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.2)
                                    .padding()
                                    .background(
                                        Circle()
                                            .fill(Color.black.opacity(0.7))
                                            .frame(width: 40, height: 40)
                                    )
                            }
                            Spacer()
                        }
                        .padding(.top, 20)
                        Spacer()
                    }
                )
            }
            // .navigationBarTitleDisplayMode(.inline)
            // .navigationBarHidden(true)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { showNewRoute = true }) {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill")
                            Text("Yeni Oluştur")
                        }
                        .foregroundColor(.white)
                    }
                }
            }
            .navigationTitle("Reklamlar")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .sheet(isPresented: $showNewRoute, onDismiss: {
                viewModel.resetForm()
            }) {
                NewRouteSheet(viewModel: viewModel)
            }
            .sheet(item: $selectedRoute) { route in
                RouteDetailView(route: route)
            }
            .onAppear {
                viewModel.loadRoutes()
            }
            .overlay {
                if SessionManager.shared.isLoading {
                    LoadingView()
                }
            }
        }
    }
}

/*
// Route Row View
struct RouteRowView: View {
    let route: Route
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text(route.title)
                    .font(.headline)
                Spacer()
                StatusBadge(status: route.status)
            }
            
            // Description
            if !route.description.isEmpty {
                Text(route.description)
                    .font(.headline)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            
            // Footer
            HStack {
                // Date
                if let date = route.assignedDate {
                    Label(date, systemImage: "calendar")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                // Progress
                ProgressView(value: Double(route.completion) / 100.0)
                    .frame(width: 100)
                    .tint(progressColor)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
    }
    
    private var progressColor: Color {
        switch route.status {
        case "Tamamlandı":
            return .green
        case "Devam Ediyor":
            return .blue
        default:
            return .gray
        }
    }
}
 */

// Stat kutusu
struct RouteFuturisticStatBox: View {
    let icon: String
    let color: Color
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .padding(8)
                .background(color.opacity(0.12))
                .clipShape(Circle())
                .frame(width: 50, height: 50)
            Text(value)
                .font(.title3).bold()
                .foregroundColor(.white)
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

/*
// Status Badge View
struct StatusBadge: View {
    let status: String
    
    var body: some View {
        Text(status)
            .font(.caption)
            .foregroundColor(statusColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor.opacity(0.1))
            .cornerRadius(8)
    }
    
    private var statusColor: Color {
        switch status {
        case "Tamamlandı":
            return .green
        case "Devam Ediyor":
            return .blue
        case "Bekliyor":
            return .black
        default:
            return .gray
        }
    }
}
*/





struct RouteRowView: View {
    let route: Route
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(route.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.white)
                    
                    if !route.description.isEmpty {
                        Text(route.description)
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                StatusBadge(status: route.status)
                    .scaleEffect(0.9)
            }
            
            // Progress & Date Section
            HStack(spacing: 12) {
                // Progress Bar with Label
                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text("İlerleme")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(route.completion)%")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(ProgressColor.fromCompletion(route.completion).color)
                    }
                    
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.2))
                                .frame(height: 8)
                            
                            // Progress
                            RoundedRectangle(cornerRadius: 4)
                                .fill(ProgressColor.fromCompletion(route.completion).color)
                                .frame(width: geometry.size.width * CGFloat(route.completion) / 100, height: 8)
                        }
                    }
                    .frame(height: 8)
                }
                
                /*
                Spacer()
                
                // Date
                if let date = route.assignedDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 14))
                        Text(date)
                            .font(.system(size: 14))
                    }
                    .foregroundColor(.secondary)
                }
                 */
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
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

struct StatusBadge: View {
    let status: RouteStatus
    
    var body: some View {
        Text(status.rawValue)
            .font(.system(size: 12, weight: .medium))
            .foregroundColor(status.statusColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(status.statusColor.opacity(0.15))
            )
    }
}






struct NewRouteSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: RouteViewModel
    @State private var selectedDate = Date()
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                Form {
                    Section(header: Text("Rota Bilgileri").foregroundColor(.white)) {
                        TextField("Rota Adı", text: $viewModel.formVal.title)
                            .foregroundColor(.white)
                            .textFieldStyle(PlainTextFieldStyle())
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                        
                        DatePicker("Tarih", selection: $selectedDate, displayedComponents: .date)
                            .foregroundColor(.white)
                            .onChange(of: selectedDate) { newValue in
                                viewModel.formVal.assignedDate = ISO8601DateFormatter().string(from: newValue)
                            }
                    }
                    .listRowBackground(Color.black)
                    
                    Section(header: Text("Rota Açıklaması").foregroundColor(.white)) {
                        TextEditor(text: $viewModel.formVal.description)
                            .frame(height: 200)
                            .foregroundColor(.white)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.white.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    )
                            )
                    }
                    .listRowBackground(Color.black)
                    
                    if let error = errorMessage {
                        Section {
                            Text(error)
                                .foregroundColor(.red)
                                .font(.caption)
                        }
                        .listRowBackground(Color.black)
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color.black)
            }
            .navigationTitle("Yeni Rota Oluştur")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Kapat") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        SessionManager.shared.isLoading = true
                        viewModel.createRoute(route: viewModel.formVal) { result in
                            SessionManager.shared.isLoading = false
                            switch result {
                            case .success:
                                // Yeni rota eklendiyse, rotaları tekrar yükle
                                viewModel.loadRoutes()
                                dismiss()
                            case .failure(let error):
                                errorMessage = error.localizedDescription
                            }
                        }
                    }
                    .disabled(SessionManager.shared.isLoading)
                    .foregroundColor(.white)
                }
            }
            .onAppear {
                // Form açıldığında tarih alanını sıfırla
                selectedDate = Date()
                viewModel.formVal.assignedDate = ISO8601DateFormatter().string(from: selectedDate)
            }
            .overlay {
                if SessionManager.shared.isLoading {
                    LoadingView()
                }
            }
        }
    }
}

#Preview {
    RoutesView()
}
