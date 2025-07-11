//
//  CommentDetailView.swift
//  Nola
//
//  Created by loac on 2025/7/11.
//

import Foundation
import SwiftUI

/// 评论详情 View
struct CommentDetailView: View {
    
    @Environment(\.dismiss) var dismiss

    
    @State private var comment: Comment
    
    @ObservedObject private var vm: CommentViewModel
    
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    // 保存回调事件 （修改后的评论, 是否是删除操作）
    private var onSavedCallback: (_ comment: Comment, _ delete: Bool) -> Void = { _, _ in }
    
    init (
        comment: Comment,
        vm: CommentViewModel,
        onSavedCallback: @escaping (_ comment: Comment, _ delete: Bool) -> Void = { _, _ in }
    ) {
        _comment = State(initialValue: comment)
        self.vm = vm
        self.onSavedCallback = onSavedCallback
    }
    
    var body: some View {
        Form {
            Section("基本信息") {
                ListItem(label: "名称") {
                    TextField("名称", text: $comment.displayName)
                        .textInputAutocapitalization(.never)
                }
                ListItem(label: "邮箱") {
                    TextField("邮箱", text: $comment.email)
                        .textInputAutocapitalization(.never)
                }
                ListItem(label: "站点") {
                    TextField(
                        "站点",
                        text: Binding(
                            get: {
                                comment.site ?? ""
                            },
                            set: { value in
                                if value.isEmpty {
                                    comment.site = nil
                                } else {
                                    comment.site = value
                                }
                            }
                        )
                    )
                    .textInputAutocapitalization(.never)
                }
                
                ListItem(label: "评论") {
                    NavigationLink {
                        List {
                            Section("摘要内容") {
                                ZStack {
                                    TextEditor(text: $comment.content)
                                        .frame(minHeight: 240)
                                        .submitLabel(.done)
                                        .textInputAutocapitalization(.never)
                                }
                                .listRowInsets(EdgeInsets())
                                .padding(.defaultSpacing)
                            }
                        }
                        .navigationTitle("评论内容")
                    } label: {
                        HStack {
                            Spacer()
                            Text(comment.content.prefix(min(15, comment.content.count)) + "...")
                                .lineLimit(1)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
            }
            
            
            Section("审核状态") {
                Toggle("通过审核", isOn: $comment.isPass)
            }
        }
        .navigationTitle("修改评论")
        .navigationBarTitleDisplayMode(.inline)
        .messageAlert(isPresented: $showAlert, message: alertMessage)
        .toolbar {
            Button("保存") {
                Task {
                    await saveComment()
                }
            }
        }
    }
    
    
    /// 保存评论
    private func saveComment() async {
        if let err = await vm.updateComment(
            commentId: comment.commentId,
            content: comment.content,
            site: comment.site,
            displayName: comment.displayName,
            email: comment.email,
            isPass: comment.isPass
        ) {
            alertMessage = err
            showAlert = true
        } else {
            // 保存成功
            onSavedCallback(comment, false)
            dismiss()
        }
    }
}
