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
}
