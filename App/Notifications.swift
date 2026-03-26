//
//  Notifications.swift
//  App
//
//  Created by John Hanna on 3/21/26.
//


//
//  Notifications.swift
//  App
//

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseMessaging
import FirebaseFunctions
import UserNotifications

// MARK: - App Delegate (Push Notifications Setup)
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()

        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Notification permission granted:", granted)
        }

        application.registerForRemoteNotifications()
        Messaging.messaging().delegate = self

        return true
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }

    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("FCM Token:", fcmToken ?? "")

        // Subscribe all users to topic
        Messaging.messaging().subscribe(toTopic: "allUsers")
    }
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }
}

// MARK: - Admin Login View
struct AdminLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 16) {
            Text("Admin Login").font(.title)

            TextField("Email", text: $email)
                .textFieldStyle(.roundedBorder)

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            Button("Login") {
                login()
            }

            Text(errorMessage)
                .foregroundColor(.red)

            if isLoggedIn {
                AdminNotificationView()
            }
        }
        .padding()
    }

    func login() {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
            } else {
                isLoggedIn = true
            }
        }
    }
}

// MARK: - Send Notification View
struct AdminNotificationView: View {
    @State private var message = ""
    @State private var status = ""
    private let functions = Functions.functions()

    
    var body: some View {
        VStack(spacing: 16) {
            Text("Send Notification")
                .font(.title)

            TextField("Enter message", text: $message)
                .textFieldStyle(.roundedBorder)

            Button("Send Notification") {
                sendNotification()
            }

            Text(status)
                .foregroundColor(.gray)

            Button("Test Notification") {
                NotificationTester.sendTestNotification(
                    title: "St. Julitta Church",
                    body: "This is a test announcement"
                )
            }
        }
        .padding()
    }

    func sendNotification() {
        guard !message.isEmpty else {
            status = "Message cannot be empty"
            return
        }

        // Firebase call (will fully work once APNs is set up)
        functions.httpsCallable("sendNotification").call(["message": message]) { result, error in
            DispatchQueue.main.async {
                if let error = error {
                    status = "Error: \(error.localizedDescription)"
                } else {
                    status = "Sent ✅"
                }
            }
        }

        // Local simulation for testing now
        NotificationTester.sendTestNotification(
            title: "St. Julitta Church",
            body: message
        )

        message = ""
    }
}
