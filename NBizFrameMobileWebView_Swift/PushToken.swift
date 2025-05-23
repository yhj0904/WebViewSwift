//
//  PushToken.swift
//  NBizFrameMobileWebView_Swift
//
//  Created by 윤형주 on 5/23/25.
//


import Foundation

// MARK: - PushToken
struct PushToken: Codable {
    
    let appId: String
    
    let token: String
    
    let userId: String
    
}
