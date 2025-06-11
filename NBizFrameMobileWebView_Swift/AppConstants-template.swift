//
//  AppConstants-template.swift
//  NBizFrameMobileWebView_Swift
//
//  Created by 윤형주 on 6/11/25.
//

import Foundation

final class AppConstantsTemplate {
    
    static let APP_ID = "MOBILE";

    static let PUSH_SAVE_TOKEN_URL = "/api/token/register";

    static let PUSH_REMOVE_TOKEN_URL = "/api/token/delete";

    static let PUSH_CHANNEL_ID = "알림";

    static let PUSH_CHANNEL_NM = "알림 Name";

    static let PUSH_CHANNEL_DES = "알림 서비스";
    
    static let APP_URL = "https://localhost:8080/";

    static let UID = "uid";

    static let SVCID = "svcid";

    static let REASON = "reason";

    static let RETVAL = "returnvalue";

    static let CODE_SUCCESS = 0; //처리결과 코드(성공)

    static let CODE_ERROR = -1; //처리결과 코드(실패)
    
}
