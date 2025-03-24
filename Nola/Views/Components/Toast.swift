//
//  Toast.swift
//  Nola
//
//  Created by loac on 24/03/2025.
//

import Foundation
import SwiftUI
import PopupView

enum ToastType {
    case success
    case error
    case info
}

extension View {
    func toast(
        isPresented: Binding<Bool>,
        text: String,
        type: ToastType = ToastType.success,
        onDismiss: @escaping () -> Void = {}
    ) -> some View {
        return self.popup(isPresented: isPresented) {
            ToastContent(text: text, type: type)
        } customize: {
            $0.type(.floater())
                .closeOnTap(true)
                .closeOnTapOutside(true)
                .dragToDismiss(true)
                .position(.top)
                .autohideIn(2.5)
                .animation(.smooth)
                .dismissCallback {
                    onDismiss()
                    isPresented.wrappedValue = false
                }
        }
    }
}


private struct ToastContent: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    private var isLight: Bool {
        colorScheme == .light
    }
    
    let text: String
    let type: ToastType
    
    
    private var borderColor: Color {
        switch type {
        case .success:
            Color.green
        case .error:
            Color.red
        case .info:
            Color.clear
        }
    }
    
    private var textColor: Color {
        switch type {
        case .success:
            Color.green
        case .error:
            Color.red
        case .info:
            isLight ? Color.black : Color.white
        }
    }
    
    
    var body: some View {
        VStack {
            Text(text)
                .padding()
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(textColor)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
        .overlay {
            RoundedRectangle(cornerRadius: 10)
                .stroke(borderColor.opacity(0.4), lineWidth: 1.5)
        }
        .shadow(color: borderColor.opacity(0.2), radius: 20, x: 3, y: 6)
        .padding(.horizontal, 20)
    }
    
}
