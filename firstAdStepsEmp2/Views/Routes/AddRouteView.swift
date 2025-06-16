//
//  AddRouteView.swift
//  firstAdStepsEmp2
//
//  Created by Ali YILMAZ on 15.06.2025.
//

import SwiftUI

struct AddRouteView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var viewModel = RouteViewModel(
        routes: [],
        formVal: Route(
            id: UUID().uuidString,
            userId: "123",
            title: "",
            description: "",
            status: "Bekliyor",
            assignedDate: nil,
            completion: 0,
            createdAt: ISO8601DateFormatter().string(from: Date())
        )
    )

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                CustomTextField(
                    text: $viewModel.formVal.title,
                    placeholder: "Rota Adı",
                    icon: "map"
                )
                
                CustomTextField(
                    text: Binding(
                        get: { $viewModel.formVal.description ?? "" },
                        set: { $viewModel.formVal.description = $0 }
                    ),
                    placeholder: "Açıklama",
                    icon: "text.alignleft"
                )
                
                // Konum seçimi için özel bir picker veya harita bileşeni eklenebilir
                // Örnek:
                // LocationPickerView(selectedLat: $viewModel.formVal.startLat, selectedLng: $viewModel.formVal.startLng, label: "Başlangıç Konumu")
                // LocationPickerView(selectedLat: $viewModel.formVal.endLat, selectedLng: $viewModel.formVal.endLng, label: "Bitiş Konumu")
                
                
                DatePicker(
                    "Tarih",
                    selection: Binding(
                        get: { $viewModel.formVal.assignedDate ?? "" },
                        set: { $viewModel.formVal.assignedDate = $0 }
                    ),
                    displayedComponents: .date
                )
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                
                if let error = $viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
                
                Button(action: {
                    // $viewModel.createRoute()
                }) {
                    if $viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Rota Oluştur")
                            .frame(maxWidth: .infinity)
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(viewModel.isLoading)
            }
            .padding()
        }
        .navigationTitle("Yeni Rota")
        .onChange(of: viewModel.isRouteCreated) { created in
            if created {
                navigationManager.goToHome()
            }
        }
        .overlay {
            if viewModel.isLoading {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                ProgressView()
                    .scaleEffect(1.5)
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
            }
        }
    }
}
