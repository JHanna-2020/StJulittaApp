//
//  SermonCard.swift
//  App
//
//  Created by John Hanna on 3/10/26.
//

import SwiftUI
struct SermonCard: View {

    var title: String
    var thumbnail: String
    @AppStorage("appFontSize") var appFontSize: Double = 16

    var body: some View {

        VStack(alignment: .leading) {

            Image(thumbnail)
                .resizable()
                .scaledToFill()
                .frame(height: 180)
                .clipped()
                .cornerRadius(12)

            Text(title)
                .font(.system(size: appFontSize + 2, weight: .semibold))
                .foregroundColor(.primary)
                .padding(.top, 5)

        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(radius: 3)
        )
    }
}
