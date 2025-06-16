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
    
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var vm: PostViewModel
    @Binding var post: Post
    // 当前是否是新增文章
    @Binding var isAddPost: Bool
    
    @State private var isLoading = false
    
    // 文章内容
    @State private var content: PostContent? = nil
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    // 标记 Alert 确认后是否 dismiss 当前页面（用于处理一些必须回退到上一页的错误）
    @State private var dismissAfterAlert = false
    
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
        .messageAlert(isPresented: $showAlert, message: alertMessage) {
            if dismissAfterAlert {
                // 当前弹窗消息确认后需要 dismiss
                dismiss()
            }
        }
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
                
                // 当前是新增的文章
                if isAddPost {
                    // 先添加文章
                    if await addNewPost() {
                        // 添加文章成功，在 addNewPost 会将当前自动转换为编辑模式（即 isAddPost = false）
                    } else {
                        // 添加新文章失败, addNewPost 方法失败后会自动 dismiss，所以这里直接 return
                        return
                    }
                }
                
                let ret = await vm.getPostContent(id: post.postId)
                if let err = ret.error {
                    // 加载失败
                    alertMessage = err
                    showAlert = true
                } else if let postContent = ret.content {
                    // 获得文章内容
                    withAnimation {
                        content = postContent
                    }
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
    
    /// 添加新文章，并将新添加的文章作为当前编辑的文章
    /// - Returns: 成功 true，失败 false。失败时会自动弹出弹窗，并且确认了弹窗后会自动 dismiss 当前页面。
    private func addNewPost() async -> Bool {
        let currTimestamp = Int(Date().timeIntervalSince1970 * 1000)
        // 当前是新增文章，先添加文章，然后再转换为编辑文章模式
        let ret = await vm.addPost(
            title: post.title.isEmpty ? "未命名" : post.title,
            autoGenerateExcerpt: post.autoGenerateExcerpt,
            excerpt: post.excerpt,
            // 如果文章别名为空，默认使用当前时间戳毫秒
            slug: post.slug.isEmpty ? String(currTimestamp) : post.slug,
            allowComment: post.allowComment,
            status: post.status,
            visible: post.visible,
            content: "",
            categoryId: post.category?.id,
            tagIds: post.tags.map { $0.id },
            cover: post.cover,
            pinned: post.pinned,
            password: nil
        )
        
        if let error = ret.error {
            // 新建文章发生错误
            alertMessage = error
            showAlert = true
            // 新建文章发生错误，编辑文章无法继续，错误确认后需要回退上一页
            dismissAfterAlert = true
            return false
        } else if let post = ret.post {
            // 新建文章成功
            withAnimation {
                self.post = post
                // 转为编辑模式
                self.isAddPost = false
            }
            return true
        } else {
            // 文章和错误信息都为 nil
            alertMessage = "未知错误，请稍后重试"
            showAlert = true
            // 新建文章发生错误，编辑文章无法继续，错误确认后需要回退上一页
            dismissAfterAlert = true
            return false
        }
    }
    
    /// 保存文章内容
    private func savePostContent() {
        Task {
            isSaving = true
            
            if !isAddPost {
                // 只有当前不是新增文章，才触发保存操作
                if let err = await vm.updatePostContent(id: post.postId, content: content?.content ?? "") {
                    // 发生错误
                    alertMessage = err
                    showAlert = true
                }
            }
            
            withAnimation {
                isSaving = false
            }
        }
    }
}
