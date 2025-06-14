//
//  PostContentView.swift
//  Nola
//
//  Created by loac on 09/06/2025.
//

import Foundation
import SwiftUI

/// 文章内容编辑页面
struct PostContentView: View {
    
    @ObservedObject var vm: PostViewModel
    @Binding var post: Post
    
    @State private var isLoading = false
    
    // 文章内容
    @State private var content: PostContent? = nil
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // 是否正在保存文章
    @State private var isSaving = false
    
    
    // 标记当前是否已经加载过，防止重复执行 task 导致文章刷新
    @State private var isLoaded = false
    
    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
            } else {
                TextEditor(
                    text: Binding {
                        return content?.content ?? ""
                    } set: { newValue in
                        content?.content = newValue
                    }
                )
                .padding(5)
                .frame(maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .messageAlert(isPresented: $showAlert, message: alertMessage)
        .toolbar {
            NavigationLink {
                MarkdownView(content: content?.content ?? "", isMarkdown: true)
                    .navigationTitle("文章预览")
            } label: {
                Label("预览文章", systemImage: SFSymbol.play.rawValue)
            }
            
            Button {
                savePostContent()
            } label: {
                Text("保存")
            }
        }
        .task {
            if !isLoaded {
                isLoading = true
                let ret = await vm.getPostContent(id: post.postId)
                if let err = ret.error {
                    // 加载失败
                    alertMessage = err
                    showAlert = true
                } else if let postContent = ret.content {
                    // 获得文章内容
                    content = postContent
                }
                withAnimation {
                    isLoading = false
                }
                isLoaded = true
            }
        }
        .loadingAlert(isPresented: $isSaving, message: "正在保存", closableAfter: .seconds(10))
        .onDisappear {
            // 关闭时保存文章
            savePostContent()
        }
        .navigationTitle(post.title)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    /// 保存文章内容
    private func savePostContent() {
        Task {
            isSaving = true
            if let err = await vm.updatePostContent(id: post.postId, content: content?.content ?? "") {
                // 发生错误
                alertMessage = err
                showAlert = true
            }
            withAnimation {
                isSaving = false
            }
        }
    }
}
