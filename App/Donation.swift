//
//  Donation.swift
//  App
//
//  Created by John Hanna on 3/10/26.
//
import SwiftUI
struct Donation: View {
    @State private var showCopiedToast = false
    @AppStorage("appFontSize") var appFontSize: Double = 16

    var body: some View {
        ScrollView {
            VStack(spacing: 25) {

               

                Text("Give easily using Zelle or by mailing a check. Tap the email below to copy it.")
                    .font(.system(size: appFontSize))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)

                VStack(spacing: 12) {
                    Text("Zelle")
                        .font(.system(size: appFontSize + 4, weight: .semibold))

                    Text("Tap to copy email")
                        .font(.system(size: appFontSize - 1))
                        .foregroundColor(.secondary)

                    Text(verbatim: "zelle@stjulittapearland.org")
                        .font(.system(size: appFontSize + 2, weight: .semibold))
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray5))
                        .foregroundStyle(Color.accentColor)
                        .cornerRadius(10)
                        .onTapGesture {
                            UIPasteboard.general.string = "zelle@stjulittapearland.org"
                            withAnimation(.easeInOut(duration: 0.25)) {
                                showCopiedToast = true
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    showCopiedToast = false
                                }
                            }
                        }
                        .textSelection(.enabled)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)

                VStack(spacing: 10) {
                    Text("Mail a Check")
                        .font(.system(size: appFontSize + 4, weight: .semibold))

                    Text("Make payable to:\nSt. Julitta Coptic Orthodox Church")
                        .font(.system(size: appFontSize))
                        .multilineTextAlignment(.center)

                    Text("11601 Shadow Creek Parkway\nSuite 111, #590\nPearland, TX 77584")
                        .font(.system(size: appFontSize))
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 50)
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Support the Church")
                    .font(.system(size: appFontSize + 6, weight: .semibold))
            }
        }

       
        .overlay(
            VStack {
                if showCopiedToast {
                    Text("Email copied to clipboard")
                        .font(.system(size: appFontSize - 1))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(.ultraThinMaterial)
                        .cornerRadius(10)
                        .shadow(radius: 4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                Spacer()
            }
            .padding(.top, 20)
        )
        .animation(.easeInOut(duration: 0.25), value: showCopiedToast)
    }
}
