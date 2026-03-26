//
//  SignalGroup.swift
//  App
//
//  Created by John Hanna on 3/21/26.
//
import SwiftUI
struct SignalGroup: View {
    @AppStorage("appFontSize") var appFontSize: Double = 16
    var body: some View {
        Image("img")
        Text("Join the Church Signal Group for Communication")
       
        Button(action: openSignalGroup) {
            HStack(spacing: 8) {
                Text("Join the St. Julitta Singal Group")
                    .font(.system(size: appFontSize, weight: .semibold))
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .foregroundColor(.white)
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.blue)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.2), radius: 6, x: 0, y: 3)
        }
        .padding(.horizontal)
    }
}
    
func openSignalGroup() {
    if let url = URL(string:
                        "https://signal.group/#CjQKID1qlPy127u1DpsgKY_09WqcIgbBdFehYg8NemjSkP_KEhBIk5ViDKSMmMoYhFPUv7Ys") {
        UIApplication.shared.open(url)
    }
}
