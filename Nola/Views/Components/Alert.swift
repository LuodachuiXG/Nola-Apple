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
            Button("好的", role: .cancel) {
                isPresented.wrappedValue = false
            }
        }
    }
    
    /// 消息弹窗
    /// 显示一个 OK 确定按钮
    func messageAlert(isPresented: Binding<Bool>, message: String) -> some View {
        return self.messageAlert(isPresented: isPresented, message: LocalizedStringKey(message))
    }
    
    /// 确定弹窗
    /// 显示一个确定和取消按钮
    func confirmAlert(isPresented: Binding<Bool>, message: LocalizedStringKey, onConfirm: @escaping () -> Void) -> some View {
        return self.alert(message, isPresented: isPresented) {
            Button("取消", role: .cancel) {
                isPresented.wrappedValue = false
            }
            Button("确定", role: .destructive) {
                onConfirm()
                isPresented.wrappedValue = false
            }
        }
    }
    
    /// 确定弹窗
    /// 显示一个确定和取消按钮
    func confirmAlert(isPresented: Binding<Bool>, message: String, onConfirm: @escaping () -> Void) -> some View {
        return self.confirmAlert(isPresented: isPresented, message: LocalizedStringKey(message), onConfirm: onConfirm)
    }
}
