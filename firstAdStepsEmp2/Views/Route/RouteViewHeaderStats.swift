//
//  RouteViewHeaderStats.swift
//  firstAdStepsEmp2
//
//  Created by Ali YILMAZ on 24.06.2025.
//

import SwiftUI

struct RouteViewHeaderStats: View {
    @ObservedObject var viewModel: RouteViewModel
    
    var body: some View {
        if !viewModel.routes.isEmpty {
            statsContainer
        }
    }
    
    private var statsContainer: some View {
        HStack(spacing: 16) {
            totalRoutesBox
            pendingRoutesBox
            completedRoutesBox
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.black)
    }
    
    private var totalRoutesBox: some View {
        RouteFuturisticStatBox(
            icon: "bolt.fill",
            color: .yellow,
            title: "Toplam Rota",
            value: String(viewModel.routes.count)
        )
    }
    
    private var pendingRoutesBox: some View {
        RouteFuturisticStatBox(
            icon: "eye.fill",
            color: .blue,
            title: "Bekleyen",
            value: String(viewModel.routes.filter { $0.status == .pending }.count)
        )
    }
    
    private var completedRoutesBox: some View {
        RouteFuturisticStatBox(
            icon: "checkmark.seal.fill",
            color: .green,
            title: "Tamamlandı",
            value: String(viewModel.routes.filter { $0.status == .completed }.count)
        )
    }
}

#Preview {
    RouteViewHeaderStats(viewModel: RouteViewModel(routes: [Route.preview], formVal: Route(
        id: UUID().uuidString,
        userId: SessionManager.shared.currentUser?.id ?? "",
        title: "",
        description: "",
        status: .pending,
        assignedDate: nil,
        completion: 0,
        createdAt: ISO8601DateFormatter().string(from: Date())
    )))
}
