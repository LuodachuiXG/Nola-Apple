//
//  CommentView.swift
//  Nola
//
//  Created by loac on 17/06/2025.
//

import Foundation
import SwiftUI


/// 评论 View
struct CommentView: View {
    
    @Environment(\.openURL) var openUrl
    
    @Binding var path: NavigationPath
    
    @StateObject private var postVM = PostViewModel()
    
    @StateObject private var vm = CommentViewModel()
    
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    @State private var isLoading = false
    
    // 标记当前是否已经完成第一次刷新
    @State private var firstRefresh = false
    
    // 要删除的评论 ID
    @State private var deleteCommentId: Int? = nil
    // 是否显示删除评论弹窗
    @State private var showDeleteCommentAlert = false
    
    // 下拉刷新提示文字
    private var pullUpRefreshText: String {
        if let pager = vm.pager {
            if !vm.hasNextPage {
                "没有更多评论了"
            } else {
                "加载中 (\(pager.page) / \(pager.totalPages) 页)"
            }
        } else {
            "加载中"
        }
    }
    
    
    var body: some View {
        ZStack {
            if !firstRefresh {
                ProgressView()
            }
            
            ScrollView(showsIndicators: true) {
                LazyVStack(spacing: .defaultSpacing) {
                    ForEach(vm.comments, id: \.commentId) { comment in
                        CommentCard(comment: comment) { postId in
                            // 评论上的文章名被点击事件
                            Task {
                                await navigateToPostDetail(postId: postId)
                            }
                            
                        } onPassClick: {
                            // 通过审核点击事件
                            Task {
                                await passComment(ids: [comment.commentId])
                            }
                        } onSiteClick: { site in
                            // 站点地址点击事件
                            if let url = URL(string: site) {
                                openUrl(url)
                            } else {
                                // 地址非法
                                alertMessage = "地址非法"
                                showAlert = true
                            }
                        }
                        .contextMenu {
                            // 编辑评论
                            NavigationLink(value: CommentRoute.Detail(comment: comment)) {
                                Label("编辑评论", systemImage: SFSymbol.edit.rawValue)
                            }
                            
                            // 撤销或通过审核
                            Button(role: comment.isPass ? .destructive : .cancel) {
                                Task {
                                    // 稍微延迟 450 毫秒，防止因 contextMenu 回缩动画导致异常
                                    try await Task.sleep(nanoseconds: 450_000_000)
                                    await passComment(
                                        ids: [comment.commentId],
                                        isPass: !comment.isPass
                                    )
                                }
                            } label: {
                                Label(
                                    comment.isPass ? "撤销审核" : "通过审核",
                                    systemImage: comment.isPass ? SFSymbol.returnIcon.rawValue :
                                        SFSymbol.check.rawValue
                                )
                            }
                            
                            // 删除评论
                            Button(role: .destructive) {
                                deleteCommentId = comment.commentId
                                showDeleteCommentAlert = true
                            } label: {
                                Label("删除评论", systemImage: SFSymbol.trash.rawValue)
                            }
                            
                            Divider()
                            
                            // 回复评论（仅通过审核的评论可以回复）
                            if comment.isPass {
                                NavigationLink(value: CommentRoute.Reply(comment: comment)) {
                                    Label("回复评论", systemImage: SFSymbol.reply.rawValue)
                                }
                            }
                        }
                        .padding(.horizontal, .defaultSpacing)
                    }
                    
                    // 完成首次加载前不显示
                    if firstRefresh {
                        HStack {
                            Spacer()
                            if vm.hasNextPage {
                                // 还有下一页时才显示加载图标
                                ProgressView()
                            }
                            Text(pullUpRefreshText)
                                .foregroundStyle(.secondary)
                                .font(.callout)
                                .padding(.vertical, 20)
                                .onAppear {
                                    if !isLoading {
                                        // 加载下一页评论
                                        loadNextPage()
                                    }
                                }
                            Spacer()
                        }
                    }
                }
            }
            .refreshable {
                await refreshComments()
            }
        }
        .toolbar {
            
        }
        .navigationDestination(for: Post.self, destination: { post in
            // 文章详情页
            PostDetailView(post: post, viewModel: postVM) { _, _ in }
        })
        .navigationDestination(for: CommentRoute.self, destination: { route in
            switch route {
            case .Detail(let comment):
                // 评论详情
                CommentDetailView(comment: comment, vm: vm) { newComment, delete in
                    // 评论保存事件
                    if !delete {
                        vm.updateExistComment(comment: newComment)
                    } else {
                        // 评论删除
                    }
                }
            case .Reply(let comment):
                // 回复评论
                CommentReplyView(comment: comment, vm: vm) { newComment in
                    // 回复成功
                }
            }
            
        })
        .navigationTitle("评论")
        .navigationBarTitleDisplayMode(.inline)
        .messageAlert(isPresented: $showAlert, message: alertMessage)
        .confirmAlert(isPresented: $showDeleteCommentAlert, message: "确定要删除评论吗") {
            // 删除评论
            if let id = deleteCommentId {
                deleteComment(ids: [id])
            }
        }
        .task {
            if !firstRefresh {
                // 没有完成首次刷新才刷
                await refreshComments()
            }
        }
    }
    
    /// 刷新分类
    private func refreshComments() async {
        isLoading = true
        if let err = await vm.getComments() {
            alertMessage = err
            showAlert = true
        }
        firstRefresh = true
        isLoading = false
    }
    
    /// 通过审核
    /// - Parameters:
    ///   - ids: 评论 ID 数组
    ///   - isPass: 是否通过审核
    private func passComment(ids: [Int], isPass: Bool = true) async {
        if let err = await vm.passComment(ids: ids, isPass: isPass) {
            alertMessage = err
            showAlert = true
        }
    }
    
    /// 跳转文章详情页面
    /// - Parameters:
    ///   - postId: 文章 ID
    private func navigateToPostDetail(
        postId: Int
    ) async {
        // 先获取文章
        let ret = await postVM.getPostById(id: postId)
        if let err = ret.error {
            alertMessage = err
            showAlert = true
        } else if let post = ret.post {
            // 跳转详情页
            path.append(post)
        }
    }
    
    /// 更新现有的分类
    /// - Parameters:
    ///   - category: 新分类实体
    //    private func updateExistCategory(category: Category) {
    //        Task {
    //            if let error = await vm.updateExistCategory(category: category) {
    //                alertMessage = error
    //                showAlert = true
    //            }
    //        }
    //    }
    
    /// 删除评论
    /// - Parameters:
    ///   - ids: 评论 ID 数组
    private func deleteComment(ids: [Int]) {
        Task {
            if let err = await vm.deleteComment(ids: ids) {
                alertMessage = err
                showAlert = true
            }
            
            deleteCommentId = nil
        }
    }
    
    // 加载下一页
    private func loadNextPage() {
        isLoading = true
        Task {
            if let err = await vm.getComments(
                loadMore: true
            ) {
                alertMessage = err
                showAlert = true
            }
            isLoading = false
        }
    }
    
}

/// 回复评论 View
private struct CommentReplyView: View {
    
    @Environment(\.dismiss) var dismiss

    // 要回复的评论
    let comment: Comment
    
    @ObservedObject var vm: CommentViewModel
    
    // 回复成功后回调（回调新增的评论）
    private var onReply: (_ comment: Comment) -> Void = { _ in }
    
    @State private var replyContent: String = ""
    
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    init(
        comment: Comment,
        vm: CommentViewModel,
        onReply: @escaping (_ comment: Comment) -> Void = { _ in }
    ) {
        self.comment = comment
        self.vm = vm
        self.onReply = onReply
    }
    
    var body: some View {
        List {
            Section("回复 \(comment.displayName)") {
                ZStack {
                    TextEditor(text: $replyContent)
                        .frame(minHeight: 240)
                        .submitLabel(.done)
                }
                .listRowInsets(EdgeInsets())
                .padding(.defaultSpacing)
            }
        }
        .navigationTitle("回复评论")
        .navigationBarTitleDisplayMode(.inline)
        .messageAlert(isPresented: $showAlert, message: alertMessage)
        .toolbar {
            Button("回复") {
                Task {
                    await replyComment()
                }
            }
        }
    }
    
    /// 回复评论
    private func replyComment() async {
        // 先获取当前登录用户的个人信息
        
        if replyContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            // 回复内容为空，直接返回
            dismiss()
            return
        }
        
        guard let user = StoreManager.shared.getUser() else {
            alertMessage = "请先登录"
            showAlert = true
            return
        }
        
        let ret = await vm.addComment(
            postId: comment.postId,
            // 如果回复的评论有父评论，证明他已经是子评论，所以父评论和回复的评论相同。否则回复的是顶级评论，直接将父评论设为当前评论
            parentCommentId: comment.parentCommentId ?? comment.commentId,
            // 如果回复的评论有父评论，证明他已经是子评论，需要设置 replyCommentId。否则回复的是底层评论，不用设置 replyCommentId。
            replyCommentId: comment.parentCommentId == nil ? nil : comment.commentId,
            content: replyContent,
            site: "/",
            displayName: user.displayName,
            email: user.email,
            isPass: true
        )
        
        if let err = ret.error {
            // 发生错误
            alertMessage = err
            showAlert = true
        } else if let c = ret.comment {
            // 回复成功
            onReply(c)
            dismiss()
        }
    }
}

/// 评论路由类型
private enum CommentRoute: Hashable {
    /// 评论详情
    case Detail(comment: Comment)
    /// 回复评论
    case Reply(comment: Comment)
}



#Preview {
    @Previewable @State var path = NavigationPath()
    NavigationStack(path: $path) {
        CommentView(path: .constant(NavigationPath()))
    }
}
