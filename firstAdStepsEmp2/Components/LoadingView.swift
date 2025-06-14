//
//  LoadingView.swift
//  firstAdSteps
//
//  Created by Ali YILMAZ on 3.06.2025.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            VStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                Text("Lütfen bekleyin...")
                    .foregroundColor(.white)
                    .padding(.top, 8)
            }
            .padding()
            .background(Color.gray.opacity(0.8))
            .cornerRadius(12)
        }
    }
}
