//
//  AppConstants.swift
//  NBizFrameMobileWebView_Swift
//
//  Created by 윤형주 on 5/23/25.
//


import Foundation

final class AppConstants {
    
    static let APP_ID = "MOBILE";

    static let PUSH_SAVE_TOKEN_URL = "http://192.168.10.54:8080/api/token/register";

    static let PUSH_REMOVE_TOKEN_URL = "http://192.168.10.54:8080/api/token/delete";

    static let PUSH_CHANNEL_ID = "알림";

    static let PUSH_CHANNEL_NM = "NBizFrameMobile 알림";

    static let PUSH_CHANNEL_DES = "NBizFrameMobile 알림 서비스 입니다";
    
    static let APP_URL = "http://192.168.10.54:8080/swagger-ui/index.html";

    //nexacro 로 반환될 이벤트 속성명
    static let UID = "uid";

    static let SVCID = "svcid";

    static let REASON = "reason";

    static let RETVAL = "returnvalue";

    static let CODE_SUCCESS = 0; //처리결과 코드(성공)

    static let CODE_ERROR = -1; //처리결과 코드(실패)
    
}
