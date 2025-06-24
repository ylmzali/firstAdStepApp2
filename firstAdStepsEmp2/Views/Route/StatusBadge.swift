//
//  StatusBadge.swift
//  firstAdStepsEmp2
//
//  Created by Ali YILMAZ on 23.06.2025.
//

import SwiftUI

struct StatusBadge: View {
    let status: RouteStatus
    
    var body: some View {
        Text(status.statusDescription)
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
