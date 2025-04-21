//
//  BlogSettingView.swift
//  Nola
//
//  Created by loac on 12/04/2025.
//

import SwiftUI

struct BlogSettingView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State private var isLoading = false
    
    // 站点标题
    @State private var title = ""
    // 站点副标题
    @State private var subtitle = ""
    // LOGO
    @State private var logo = ""
    // favicon
    @State private var favicon = ""
    
    var body: some View {
        List {
            Section("博客设置") {
                HStack {
                    Text("站点标题")
                    Spacer()
                    TextField("输入站点标题（必填）", text: $title)
                        .multilineTextAlignment(.trailing)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .disabled(isLoading)
                }
                
                HStack {
                    Text("站点副标题")
                    Spacer()
                    TextField("输入站点副标题", text: $subtitle)
                        .multilineTextAlignment(.trailing)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .disabled(isLoading)
                }
                
                HStack {
                    Text("LOGO")
                    Spacer()
                    TextField("Logo", text: $logo)
                        .multilineTextAlignment(.trailing)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .disabled(isLoading)
                }
                
                HStack {
                    Text("Favicon")
                    Spacer()
                    TextField("Favicon", text: $favicon)
                        .multilineTextAlignment(.trailing)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .disabled(isLoading)
                }
            }
            
            Section("备案设置") {
                HStack {
                    Text("ICP 备案号")
                    Spacer()
                    TextField("苏ICP备XXXXXXXXX号", text: $favicon)
                        .multilineTextAlignment(.trailing)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .disabled(isLoading)
                }
                
                HStack {
                    Text("公网安备号")
                    Spacer()
                    TextField("苏公安网备XXXXXXX号", text: $favicon)
                        .multilineTextAlignment(.trailing)
                        .textInputAutocapitalization(.never)
                        .submitLabel(.done)
                        .disabled(isLoading)
                }
            }
        }
        .navigationTitle("博客设置")
        .toolbar {
            Button("完成") {
                dismiss()
            }
        }
    }
}

#Preview {
    BlogSettingView()
}
