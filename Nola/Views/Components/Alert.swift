//
//  Alert.swift
//  Nola
//
//  Created by loac on 06/04/2025.
//

import SwiftUI


extension View {
    
    /// 消息弹窗
    /// 显示一个 OK 确定按钮
    func messageAlert(isPresented: Binding<Bool>, message: LocalizedStringKey) -> some View {
        return self.alert(message, isPresented: isPresented) {
            Button("好的") {
                isPresented.wrappedValue = false
            }
        }
    }
    
    /// 加载弹窗
    /// - Parameters:
    ///   - isPresented: 是否显示
    ///   - message: 显示的文字
    ///   - closable: 是否可以点击外部关闭，默认不可关闭
    ///   - closableAfter: 在多少秒后可以点击关闭，默认不可关闭
    ///   - onClose: 关闭事件（改变 isPresented 关闭弹窗不会触发）
    func loadingAlert(
        isPresented: Binding<Bool>,
        message: LocalizedStringKey,
        closable: Bool = false,
        closableAfter: Duration? = nil,
        onClose: @escaping () -> Void = {}
    ) -> some View {
        var canClose = false
        return self.overlay {
            if isPresented.wrappedValue {
                ZStack {
                    // 底部容器
                    VStack {
                        Text("123")
                    }
                    .ignoresSafeArea()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(.black.opacity(0.4))
                    .onTapGesture {
                        print(123)
                        if closable || canClose {
                            onClose()
                            isPresented.wrappedValue = false
                        }
                    }
                    .task {
                        if isPresented.wrappedValue && closableAfter != nil {
                            try? await Task.sleep(for: closableAfter!)
                            canClose = true
                        }
                    }
                    
                    VStack(spacing: 15) {
                        ProgressView {
                            Text(message).padding(.top, 5)
                        }
                    }
                    .frame(width: 120, height: 120)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
                }
            }
        }
    }
}
