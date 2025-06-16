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
            status: "Bekliyor",
            assignedRouteDetailId: "",
            assignedDate: nil,
            completion: 0,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    )

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
                    ForEach(viewModel.routes) { route in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(route.title)
                                    .font(.headline)
                                Spacer()
                                Text(route.status)
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            HStack(spacing: 16) {
                                Spacer()
                                Text(route.assignedDate ?? "")
                                    .font(.caption2)
                                    .foregroundColor(.gray)
                            }
                            ProgressView(value: Double(route.completion) / 100.0)
                                .tint(.blue)
                        }
                        .padding(.vertical, 8)
                    }
                }
                .listStyle(.plain)
            }
            .navigationBarHidden(true)
            .sheet(isPresented: $showNewRoute, onDismiss: {
                // Sheet kapandığında formu sıfırla
                viewModel.resetForm()
            }) {
                NewRouteSheet(viewModel: viewModel)
            }
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

struct NewRouteSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: RouteViewModel
    @State private var selectedDate = Date()
    @State private var errorMessage: String?

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Rota Bilgileri")) {
                    TextField("Rota Adı", text: $viewModel.formVal.title)
                    DatePicker("Tarih", selection: $selectedDate, displayedComponents: .date)
                        .onChange(of: selectedDate) { newValue in
                            viewModel.formVal.assignedDate = ISO8601DateFormatter().string(from: newValue)
                        }
                }
                Section(header: Text("Rota Açıklaması")) {
                    TextEditor(text: $viewModel.formVal.description)
                        .frame(height: 200)
                }
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
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
