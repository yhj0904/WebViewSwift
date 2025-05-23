//
//  Reachaility.swift
//  NBizFrameMobileWebView_Swift
//
//  Created by 윤형주 on 5/23/25.
//

import Foundation
import SystemConfiguration

class Reachability {
    
    /// 현재 네트워크에 연결되어 있는지 여부를 반환
    class func networkConnected() -> Bool {
        
        // 0.0.0.0 주소를 기반으로 네트워크 도달 가능성 확인용 sockaddr_in 구조체 초기화
        var zeroAddress = sockaddr_in(
            sin_len: 0,
            sin_family: 0,
            sin_port: 0,
            sin_addr: in_addr(s_addr: 0),
            sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
        )
        
        // 구조체 크기 및 주소 패밀리 설정
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)

        // Reachability 객체 생성 (0.0.0.0 주소 사용)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) { zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        // Reachability 플래그 초기화
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)

        // Reachability 플래그를 가져올 수 없으면 false 반환
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        
        // 인터넷에 연결 가능한지 여부
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        
        // 추가 연결이 필요한지 여부 (예: VPN, 로그인 등)
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0

        // 인터넷에 연결 가능하고 추가 연결이 필요하지 않은 경우에만 true 반환
        return (isReachable && !needsConnection)
    }
}
