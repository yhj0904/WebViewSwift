//
//  AppDelegate.swift
//  NBizFrameMobileWebView_Swift
//
//  Created by 윤형주 on 5/22/25.
//

import UIKit
import FirebaseCore
import FirebaseMessaging

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        loginAndRegisterToken()
        return true
    }
    
    private func loginAndRegisterToken() {
        let loginUrl = URL(string: "http://192.168.10.54:8080/login")!
        var request = URLRequest(url: loginUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: String] = ["username": "nauri", "password": "1234"]
        request.httpBody = try? JSONEncoder().encode(body)

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                print("❌ 응답이 HTTP 형식이 아님")
                return
            }

            //  헤더 "access"에서 토큰 추출
            if let accessToken = httpResponse.allHeaderFields["access"] as? String {
                print("✅ 로그인 성공, access 토큰: \(accessToken)")

                // FCM 토큰 획득 후 등록 API 호출
                Messaging.messaging().token { fcmToken, error in
                    if let fcmToken = fcmToken {
                        PushTokenMng.registerInitialToken(fcmToken: fcmToken, jwt: accessToken)
                    }
                }
            } else {
                print("❌ 'access' 헤더 없음 - 로그인 응답 확인 필요")
            }

        }.resume()
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        Messaging.messaging().apnsToken = deviceToken
    }
    
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
        if granted {
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

