//
//  RouteRowView.swift
//  firstAdStepsEmp2
//
//  Created by Ali YILMAZ on 23.06.2025.
//

import SwiftUI


struct RouteRowView: View {
    let route: Route
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Text(route.title)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                        
                        // Paylaşım badge'i
                        if route.shareWithEmployees {
                            HStack(spacing: 4) {
                                Image(systemName: "person.2.fill")
                                    .font(.system(size: 10))
                                Text("Paylaşılan")
                                    .font(.system(size: 10, weight: .medium))
                            }
                            .foregroundColor(.blue)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.2))
                                    .overlay(
                                        Capsule()
                                            .stroke(Color.blue.opacity(0.4), lineWidth: 1)
                                    )
                            )
                        }
                    }
                    
                    if !route.description.isEmpty {
                        Text(route.description)
                            .font(.system(size: 15))
                            .foregroundColor(.white.opacity(0.8))
                            .lineLimit(2)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    StatusBadge(status: route.status)
                        .scaleEffect(0.9)
                    
                    // Paylaşım durumu için ek bilgi
                    if route.shareWithEmployees {
                        Text("Şirket Çalışanları")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.blue.opacity(0.8))
                    }
                }
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
                
                Spacer()
                
                // Date Information
                VStack(alignment: .trailing, spacing: 4) {
                    if let assignedDate = route.shortAssignedDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.system(size: 10))
                                .foregroundColor(.white.opacity(0.6))
                            Text(assignedDate)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    
                    if let relativeTime = route.relativeAssignedTime {
                        Text(relativeTime)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            route.shareWithEmployees ? Color.blue.opacity(0.4) : Color.white.opacity(0.2),
                            lineWidth: route.shareWithEmployees ? 2 : 1
                        )
                )
        )
        // Paylaşılan rotalar için ek vurgu
        .overlay(
            Group {
                if route.shareWithEmployees {
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                        .padding(1)
                }
            }
        )
    }
}
