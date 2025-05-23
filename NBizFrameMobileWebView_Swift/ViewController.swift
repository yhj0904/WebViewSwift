//
//  ViewController.swift
//  NBizFrameMobileWebView_Swift
//
//  Created by 윤형주 on 5/22/25.
//

import UIKit
import WebKit

// MARK: - UIViewController
class ViewController: UIViewController {
    
    // 스토리보드에서 연결된 WKWebView 아웃렛
    @IBOutlet weak var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        initWebView() // 웹뷰 초기화
    }
    
    // 웹뷰 설정 및 초기화 함수
    func initWebView(){
        
        // JavaScript 활성화 설정 (iOS 버전 별로 분기)
        if #available(iOS 14.0, *) {
            webView.configuration.defaultWebpagePreferences.allowsContentJavaScript = true
        } else {
            webView.configuration.preferences.javaScriptEnabled = true
        }
        
        // 상태바 높이 계산 (iOS 버전별 대응)
        var statusBarHeight: CGFloat = 0
        if #available(iOS 15.0, *) {
            statusBarHeight = UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .map { $0 as? UIWindowScene }
                .compactMap { $0 }
                .first?.windows
                .filter({ $0.isKeyWindow }).first?
                .windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else if #available(iOS 13.0, *) {
            statusBarHeight = UIApplication.shared.keyWindow?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        } else {
            statusBarHeight = UIApplication.shared.statusBarFrame.height
        }
        
        // 상태바 높이를 고려한 웹뷰 크기 설정
        webView.frame = CGRect(x: 0, y: statusBarHeight, width: self.view.frame.width, height: self.view.frame.height - statusBarHeight)
        
        // 자바스크립트 -> 네이티브 통신을 위한 핸들러 추가
        let contentController = webView.configuration.userContentController
        contentController.add(self, name:"callbackHandler")
        
        // 자바스크립트 알림 등 UI 처리를 위한 델리게이트 지정
        webView.uiDelegate = self
        
        // 웹 페이지 로드
        if let url = URL(string: AppConstants.APP_URL) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
        
        // 웹 캐시 초기화
        WKWebsiteDataStore.default().removeData(ofTypes: [
            WKWebsiteDataTypeDiskCache,
            WKWebsiteDataTypeMemoryCache
        ], modifiedSince: Date(timeIntervalSince1970: 0)) {}
    }
    
    // 화면이 표시된 이후 네트워크 연결 여부 확인
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        guard Reachability.networkConnected() else {
            // 네트워크 미연결시 종료 알림
            let alert = UIAlertController(title: "NetworkError", message: "네트워크가 연결되어있지 않습니다.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "종료", style: .default) { _ in
                exit(0) // 앱 강제 종료
            }
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
    }
}

// MARK: - WKUIDelegate : JavaScript alert/confirm/input 처리
extension ViewController: WKUIDelegate {
    
    // alert(message)
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandler()
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // confirm(message)
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String,
                 initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandler(true)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .default) { _ in
            completionHandler(false)
        }
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    // prompt(message, defaultText)
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String,
                 defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = defaultText
        }
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            completionHandler(alert.textFields?.first?.text)
        }
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - WKScriptMessageHandler : JS -> iOS 통신 처리
extension ViewController: WKScriptMessageHandler {
    
    // 웹에서 postMessage로 전달된 메시지 수신
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
        if message.name == "callbackHandler" {
            WebViewMessage.callMethod(webView: webView, message: message) // 메시지 핸들링 로직 호출
        }
    }
}
