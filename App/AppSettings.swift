//
//  AppSettings.swift
//  App
//
//  Created by John Hanna on 3/10/26.
//

import SwiftUI

import SwiftUI

struct AppSettingsView: View {

    @AppStorage("appearanceMode") var appearanceMode = 0
    @AppStorage("appFontSize") var appFontSize: Double = 16

    var body: some View {

        Form {

            Section(header:
                Text("Appearance")
                    .font(.system(size: appFontSize, weight: .semibold))
            ) {

                Picker("Theme", selection: $appearanceMode) {

                    Text("System")
                        .font(.system(size: appFontSize))
                        .tag(0)
                    Text("Light")
                        .font(.system(size: appFontSize))
                        .tag(1)
                    Text("Dark")
                        .font(.system(size: appFontSize))
                        .tag(2)

                }
                .pickerStyle(.segmented)

            }

            Section(header:
                Text("Text Size")
                    .font(.system(size: appFontSize, weight: .semibold))
            ) {

                HStack {
                    Text("A")
                        .font(.system(size: 12))

                    Slider(value: $appFontSize, in: 12...30)

                    Text("A")
                        .font(.system(size: 24))
                }

                Button("Reset Font Size") {
                    appFontSize = 16
                }
                .font(.system(size: appFontSize))

            }

        }
        .navigationTitle("Settings")
    }
}
