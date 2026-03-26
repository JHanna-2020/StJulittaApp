import SwiftUI
import FirebaseCore

@main
struct AppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate



    @AppStorage("appearanceMode") var appearanceMode = 0

    var selectedColorScheme: ColorScheme? {
        switch appearanceMode {
        case 1:
            return .light
        case 2:
            return .dark
        default:
            return nil
        }
    }

    var body: some Scene {
        WindowGroup {
            AppViewController()
                .preferredColorScheme(selectedColorScheme)
        }
    }
}
