//
//  LoadingAlert.swift
//  Nola
//
//  Created by loac on 11/04/2025.
//

import SwiftUI

struct LoadingAlert: View {
    
    @Binding var isPresented: Bool
    
    let message: LocalizedStringKey
    
    // 是否可以点击关闭
    var closable: Bool = false
    
    // 在延迟后可以点击关闭
    var closableAfter: Duration? = nil
    
    // 关闭事件
    var onClose: () -> Void = {}
    
    @State private var canClose = false
    
    
    var body: some View {
        ZStack {
            // 底部容器
            VStack {}
                .ignoresSafeArea()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black.opacity(0.01))
                .onTapGesture {
                    if closable || canClose {
                        onClose()
                        $isPresented.wrappedValue = false
                    }
                }
                .task {
                    if $isPresented.wrappedValue && closableAfter != nil {
                        try? await Task.sleep(for: closableAfter!)
                        canClose = true
                    }
                }
            
            VStack {
                ProgressView {
                    Text(message).padding(.top, 5)
                }.padding(.top, canClose ? 12 : 0)
                
                if canClose {
                    Text("点击关闭")
                        .transition(.opacity)
                        .font(.caption)
                }
            }
            .frame(width: 120, height: 120)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
            .shadow(color:.black.opacity(0.2), radius: 20)
            .onTapGesture {
                if canClose {
                    onClose()
                    $isPresented.wrappedValue = false
                }
            }
        }
    }
}

extension View {
    
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
        return self.overlay {
            if isPresented.wrappedValue {
                LoadingAlert(
                    isPresented: isPresented,
                    message: message,
                    closable: closable,
                    closableAfter: closableAfter,
                    onClose: onClose
                )
            }
        }
    }
}


#Preview {
    LoadingAlert(
        isPresented: .constant(true), message: "加载中", closableAfter: .milliseconds(1000)
    )
}
