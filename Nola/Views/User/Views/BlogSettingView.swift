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
    
    @StateObject private var vm = BlogSettingViewModel()
    
    // 站点标题
    @State private var title = ""
    // 站点副标题
    @State private var subtitle = ""
    // LOGO
    @State private var logo = ""
    // favicon
    @State private var favicon = ""
    
    // ICP 备案号
    @State private var icp = ""
    // 公网安备号
    @State private var pub = ""
    
    @State private var showErrorAlert = false
    @State private var errorAlertMsg = ""
    
    var body: some View {
        List {
            Section("博客设置") {
                Input(
                    text: $title,
                    label: "站点标题",
                    placeholder: "输入站点标题（必填）",
                    required: true,
                    disable: isLoading
                )
                
                Input(
                    text: $subtitle,
                    label: "站点副标题",
                    placeholder: "输入站点副标题",
                    disable: isLoading
                )
                
                Input(
                    text: $logo,
                    label: "Logo",
                    placeholder: "Logo",
                    disable: isLoading
                )
                
                Input(
                    text: $favicon,
                    label: "Favicon",
                    placeholder: "Favicon",
                    disable: isLoading
                )
            }
            
            Section("备案设置") {
                Input(
                    text: $icp,
                    label: "ICP 备案号",
                    placeholder: "苏ICP备XXXXXXXXX号",
                    disable: isLoading
                )
                
                Input(
                    text: $pub,
                    label: "公网安备号",
                    placeholder: "苏公安网备XXXXXXX号",
                    disable: isLoading
                )
            }
        }
        .navigationTitle("博客设置")
        .toolbar {
            Button {
                updateInfo()
            } label: {
                if isLoading {
                    ProgressView()
                } else {
                    Text("保存")
                }
            }
        }
        .messageAlert(isPresented: $showErrorAlert, message: LocalizedStringKey(errorAlertMsg))
        .onAppear {
            refreshData()
        }
    }
    
    /// 刷新博客设置信息
    private func refreshData() {
        isLoading = true
        
        let group = DispatchGroup()
        
        group.enter()
        vm.getBlogInfo { info in
            title = info.title
            subtitle = info.subtitle ?? ""
            logo = info.logo ?? ""
            favicon = info.favicon ?? ""
            group.leave()
        } failure: { err in
            errorAlertMsg = err
            showErrorAlert = true
            group.leave()
        }
        
        group.enter()
        vm.getIcp { data in
            icp = data.icp ?? ""
            pub = data.public ?? ""
            group.leave()
        } failure: { err in
            errorAlertMsg = err
            showErrorAlert = true
            group.leave()
        }
        
        // 任务都完成
        group.notify(queue: .main) {
            isLoading = false
        }
    }
    
    /// 保存博客设置信息
    private func updateInfo() {
        if title.isEmpty {
            errorAlertMsg = "请输入站点标题"
            showErrorAlert = true
            return
        }
        
        isLoading = true
        
        let group = DispatchGroup()
        
        var allSucceeded = true
        
        group.enter()
        // 更新博客信息
        vm.updateBlogInfo(
            title: title,
            subtitle: subtitle.isEmpty ? nil : subtitle,
            logo: logo.isEmpty ? nil : logo,
            favicon: favicon.isEmpty ? nil : favicon
        ) {
            group.leave()
        } failure: { err in
            errorAlertMsg = err
            showErrorAlert = true
            allSucceeded = false
            group.leave()
        }
        
        group.enter()
        // 更新备案信息
        vm.updateIcp(
            icp: icp.isEmpty ? nil : icp,
            public: pub.isEmpty ? nil : pub
        ) {
            group.leave()
        } failure: { err in
            errorAlertMsg = err
            showErrorAlert = true
            allSucceeded = false
            group.leave()
        }
        
        group.notify(queue: .main) {
            isLoading = false
            if allSucceeded {
                dismiss()
            }
        }

    }
}

/// 输入框
private struct Input: View {
    
    @Binding var text: String
    
    var label: String
    
    var placeholder: String? = nil
    
    var required: Bool = false
    
    var disable: Bool = false
    
    var body: some View {
        HStack {
            if required {
                Text("*")
                    .foregroundStyle(.red)
            }
            Text(label)
            Spacer()
            TextField(placeholder ?? "", text: $text)
                .multilineTextAlignment(.trailing)
                .textInputAutocapitalization(.never)
                .submitLabel(.done)
                .disabled(disable)
        }
    }
}

#Preview {
    BlogSettingView()
}
