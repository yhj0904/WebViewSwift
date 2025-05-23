//
//  PushTokenMng.swift
//  NBizFrameMobileWebView_Swift
//
//  Created by 윤형주 on 5/23/25.
//

import Foundation

/// 푸시 토큰 저장/삭제 요청을 처리하는 유틸리티 클래스
class PushTokenMng {
    
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
