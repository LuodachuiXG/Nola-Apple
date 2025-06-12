//
//  MarkdownView.swift
//  Nola
//
//  Created by loac on 10/06/2025.
//

import Foundation
import SwiftUI
import WebKit


/// Markdown 渲染器
struct MarkdownView: UIViewRepresentable {
    
    var content: String
    let isMarkdown: Bool
    
    func makeCoordinator() -> WebViewCoordinator {
        WebViewCoordinator(self)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = true
        webView.isOpaque = true
        
        if let htmlPath = Bundle.main.path(forResource: "markdown", ofType: "html") {
            let htmlURL = URL(filePath: htmlPath)
            // 读取网页，并允许访问 HTML 所在目录的其他文件
            webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL.deletingLastPathComponent())
        }
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
//        injectContent(to: webView)
    }
    
    /// 等到页面加载完成后渲染 Markdown 或 HTML
    func injectContent(to webView: WKWebView) {
        let escaped = content
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "\"", with: "\\\"")
            .replacingOccurrences(of: "\n", with: "\\n")
            .replacingOccurrences(of: "\r", with: "")
        
        let js = isMarkdown
        ? "window.renderMarkdown(\"\(escaped)\");"
        : "window.renderHTML(\"\(escaped)\");"
        
        webView.evaluateJavaScript(js, completionHandler: { result, error in
            if let error = error {
                print("JS error: \(error.localizedDescription)")
            }
        })
    }
    
    class WebViewCoordinator: NSObject, WKNavigationDelegate {
        let parent: MarkdownView
        
        init(_ parent: MarkdownView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.injectContent(to: webView)
        }
    }
}
