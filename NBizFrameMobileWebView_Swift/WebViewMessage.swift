//
//  WebViewMessage.swift
//  NBizFrameMobileWebView_Swift
//
//  Created by 윤형주 on 5/23/25.
//


import Foundation
import WebKit

/// 웹뷰(JavaScript)에서 메시지를 받아 처리하는 유틸리티 클래스
final class WebViewMessage {
    
    /// 웹에서 전달된 메시지를 분석하고 서비스 코드에 따라 분기 처리
    static func callMethod(webView: WKWebView, message: WKScriptMessage) {
        print(message.body)

        // JavaScript에서 전달된 메시지가 문자열일 경우
        if let bodyString = message.body as? String {
            let data = Data(bodyString.utf8)
            do {
                // 문자열을 JSON으로 파싱
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let uid = json["uid"] ?? ""
                    let svcid = json["svcid"] ?? ""

                    // 각 서비스 코드에 따른 처리
                    if svcid as! String == "PERMISSION" {
                        // PERMISSION 요청 응답 처리
                        self.send(webView: webView,
                                  uid: uid as! String,
                                  svcid: svcid as! String,
                                  reason: AppConstants.CODE_SUCCESS,
                                  retval: "PERMISSION")

                    } else if svcid as! String == "LOGIN" {
                        // 로그인 시 토큰 저장
                        let userId = json["userId"] as? String ?? ""
                        let token = UserDefaults.standard.string(forKey: "token") ?? ""
                        print("userId : \(userId)")
                        print("token : \(token)")

                        if !userId.isEmpty && !token.isEmpty {
                            PushTokenMng.saveToken(token: token, userId: userId)
                            self.send(webView: webView,
                                      uid: uid as! String,
                                      svcid: svcid as! String,
                                      reason: AppConstants.CODE_SUCCESS,
                                      retval: "LOGIN SUCCESS")
                        } else {
                            self.send(webView: webView,
                                      uid: uid as! String,
                                      svcid: svcid as! String,
                                      reason: AppConstants.CODE_ERROR,
                                      retval: "parameter null")
                        }

                    } else if svcid as! String == "LOGOUT" {
                        // 로그아웃 시 토큰 삭제 + 저장된 토큰 제거
                        UserDefaults.standard.removeObject(forKey: "accessToken")
                        UserDefaults.standard.removeObject(forKey: "refreshToken")

                        let userId = json["userId"] as? String ?? ""
                        let token = UserDefaults.standard.string(forKey: "token") ?? ""
                        print("userId : \(userId)")
                        print("token : \(token)")

                        if !userId.isEmpty {
                            PushTokenMng.removeToken(token: token, userId: userId)
                            self.send(webView: webView,
                                      uid: uid as! String,
                                      svcid: svcid as! String,
                                      reason: AppConstants.CODE_SUCCESS,
                                      retval: "LOGOUT SUCCESS")
                        } else {
                            self.send(webView: webView,
                                      uid: uid as! String,
                                      svcid: svcid as! String,
                                      reason: AppConstants.CODE_ERROR,
                                      retval: "parameter null")
                        }

                    } else if svcid as! String == "SET_ACCESS_TOKEN" {
                        // accessToken, refreshToken 저장
                        let accessToken = json["accessToken"] as? String ?? ""
                        let refreshToken = json["refreshToken"] as? String ?? ""

                        if !accessToken.isEmpty {
                            UserDefaults.standard.set(accessToken, forKey: "accessToken")
                            UserDefaults.standard.set(refreshToken, forKey: "refreshToken")
                            self.send(webView: webView,
                                      uid: uid as! String,
                                      svcid: svcid as! String,
                                      reason: AppConstants.CODE_SUCCESS,
                                      retval: "SUCCESS")
                        } else {
                            self.send(webView: webView,
                                      uid: uid as! String,
                                      svcid: svcid as! String,
                                      reason: AppConstants.CODE_ERROR,
                                      retval: "accessToken null")
                        }

                    } else if svcid as! String == "GET_ACCESS_TOKEN" {
                        // 저장된 accessToken, refreshToken 반환
                        let accessToken = UserDefaults.standard.string(forKey: "accessToken")
                        let refreshToken = UserDefaults.standard.string(forKey: "refreshToken")
                        print("accessToken : \(accessToken ?? "")")
                        print("refreshToken : \(refreshToken ?? "")")

                        if !(accessToken ?? "").isEmpty && !(refreshToken ?? "").isEmpty {
                            let rVal = "{\"accessToken\":\"\(accessToken ?? "")\",\"refreshToken\":\"\(refreshToken ?? "")\"}"
                            self.send(webView: webView,
                                      uid: uid as! String,
                                      svcid: svcid as! String,
                                      reason: AppConstants.CODE_SUCCESS,
                                      retval: rVal)
                        } else {
                            self.send(webView: webView,
                                      uid: uid as! String,
                                      svcid: svcid as! String,
                                      reason: AppConstants.CODE_ERROR,
                                      retval: "accessToken null")
                        }

                    } else {
                        // 정의되지 않은 서비스 요청
                        self.send(webView: webView,
                                  uid: uid as! String,
                                  svcid: svcid as! String,
                                  reason: AppConstants.CODE_ERROR,
                                  retval: "not allow service")
                    }
                }
            } catch let error as NSError {
                print("JSON 파싱 실패: \(error.localizedDescription)")
            }
        }
    }

    /// 자바스크립트 콜백을 웹뷰로 전달
    static func send(webView: WKWebView, uid: String, svcid: String, reason: Int, retval: String) {
        let jsonData: [String: Any] = [
            AppConstants.UID: uid,
            AppConstants.SVCID: svcid,
            AppConstants.REASON: reason,
            AppConstants.RETVAL: retval
        ]

        var jsonObj: String = ""
        do {
            let jsonCreate = try JSONSerialization.data(withJSONObject: jsonData, options: .prettyPrinted)
            jsonObj = String(data: jsonCreate, encoding: .utf8) ?? ""
        } catch {
            print("콜백 JSON 생성 실패: \(error.localizedDescription)")
        }

        // 자바스크립트 함수 호출 (웹 -> 앱 -> 웹 구조)
        webView.evaluateJavaScript("fn_callbackWebApp(\(jsonObj));", completionHandler: nil)
    }
}
