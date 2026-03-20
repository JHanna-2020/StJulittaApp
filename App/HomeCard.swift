//
//  HomeCard.swift
//  App
//
//  Created by John Hanna on 3/10/26.
//
import SwiftUI
struct HomeCard: View {

    var title: String
    var icon: String

    var body: some View {

        VStack(spacing: 15) {

            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundColor(.blue)

            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
        }
        .frame(height: 140)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5)
        )
    }
}
