//
//  PushTokenMng.swift
//  NBizFrameMobileWebView_Swift
//
//  Created by 윤형주 on 5/23/25.
//

import Foundation
import UIKit

struct RegisterTokenRequest: Codable {
    let appId: String
    let userId: String
    let deviceId: String
    let fcmToken: String
}

/// 푸시 토큰 저장/삭제 요청을 처리하는 유틸리티 클래스
class PushTokenMng {
    
    
    static func registerInitialToken(fcmToken: String, jwt: String) {
        let requestData = RegisterTokenRequest(
            appId: AppConstants.APP_ID,
            userId: "nauri", //UIDevice.current.identifierForVendor?.uuidString ?? "unknown-user",
            deviceId: UIDevice.current.name,
            fcmToken: fcmToken
        )
        
        do {
            let jsonData = try JSONEncoder().encode(requestData)
            
            var request = URLRequest(url: URL(string: AppConstants.PUSH_SAVE_TOKEN_URL)!)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("Bearer \(jwt)", forHTTPHeaderField: "Authorization") // 토큰 추가

            URLSession.shared.dataTask(with: request) { data, response, error in
                if let data = data {
                    print("✅ 푸시 토큰 등록 응답: \(String(data: data, encoding: .utf8) ?? "응답 없음")")
                } else {
                    print("❌ 토큰 등록 실패: \(error?.localizedDescription ?? "no data")")
                }
            }.resume()
            
        } catch {
            print("❌ JSON 인코딩 실패: \(error.localizedDescription)")
        }
    }

    
    // ------- 구버전 ---------
    /// 푸시 토큰을 서버에 저장 요청
    /// - Parameters:
    ///   - token: 디바이스에서 발급받은 FCM 또는 APNS 토큰
    ///   - userId: 사용자 ID
    static func saveToken(token: String, userId: String) {
        let pushToken = PushToken(appId: AppConstants.APP_ID, token: token, userId: userId)
        do {
            let encoder = JSONEncoder()
            let pushData = try encoder.encode(pushToken)
            
            // POST 요청으로 푸시 토큰 등록
            HTTPManager.requestPOST(
                url: AppConstants.PUSH_SAVE_TOKEN_URL,
                encodingData: pushData
            ) { data in
                // 응답 데이터 핸들링 필요 시 작성
            }
        } catch {
            print("푸시 토큰 저장 인코딩 실패:", error)
        }
    }
    
    /// 푸시 토큰을 서버에서 제거 요청
    /// - Parameters:
    ///   - token: 디바이스에서 발급받은 FCM 또는 APNS 토큰
    ///   - userId: 사용자 ID
    static func removeToken(token: String, userId: String) {
        let pushToken = PushToken(appId: AppConstants.APP_ID, token: token, userId: userId)
        do {
            let encoder = JSONEncoder()
            let pushData = try encoder.encode(pushToken)
            
            // POST 요청으로 푸시 토큰 삭제
            HTTPManager.requestPOST(
                url: AppConstants.PUSH_REMOVE_TOKEN_URL,
                encodingData: pushData
            ) { data in
                // 응답 데이터 핸들링 필요 시 작성
            }
        } catch {
            print("푸시 토큰 삭제 인코딩 실패:", error)
        }
    }
}
