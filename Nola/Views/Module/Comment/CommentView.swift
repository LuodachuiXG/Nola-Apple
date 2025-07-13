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
    
    // 要删除的评论 ID（要删除的评论, 父评论（如果有））
    @State private var deleteCommentId: (id: Int, parentId: Int?)? = nil
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
    
    // MARK: - 评论选项
    // 评论排序
    @State private var sortFilter: CommentSort? = nil
    // 评论状态，是否通过审核
    @State private var statusFilter: Bool? = nil
    // 评论是否树形展示
    @AppStorage("comment_tree") private var treeFilter: Bool = false
    // 关键词搜索
    @State private var keywordFilter: String? = nil
    // 关键词输入临时变量
    @State private var keywordFilterEnter = ""
    // 是否显示关键词搜索弹窗
    @State private var showKeywordFilterAlert = false
    // 当前是否在筛选状态（评论是否树形展示，不算过滤条件）
    private var isFilter: Bool {
        sortFilter != nil || statusFilter != nil || keywordFilter != nil
    }
    // MARK: - 评论选项
    
    
    var body: some View {
        ZStack {
            if !firstRefresh {
                ProgressView()
            }
            
            ScrollView(showsIndicators: true) {
                LazyVStack(alignment:.leading, spacing: .defaultSpacing) {
                    if isFilter {
                        // 当前评论在筛选状态，显示筛选指示器
                        CommentFilterIndicator(
                            id: .constant(nil),
                            status: $statusFilter.animation(),
                            sort: $sortFilter.animation(),
                            keyword: $keywordFilter.animation()
                        ) {
                            // 刷新评论
                            Task {
                                await refreshComments()
                            }
                        }
                    }
                    
                    ForEach(vm.comments, id: \.commentId) { comment in
                        CommentCard(comment: comment) { postId in
                            // 评论上的文章名被点击事件
                            Task {
                                await navigateToPostDetail(postId: postId)
                            }
                            
                        } onPassClick: { cmt, child, isPass in
                            // 通过审核点击事件
                            Task {
                                // 稍微延迟 450 毫秒，防止因 contextMenu 回缩动画导致异常
                                try await Task.sleep(nanoseconds: 450_000_000)
                                if let child = child {
                                    // 当前是对子评论的修改
                                    await passComment(
                                        id: child.commentId,
                                        parentId: cmt.commentId,
                                        isPass: isPass
                                    )
                                } else {
                                    // child 为 nil，当前是对顶层评论的修改
                                    await passComment(id: cmt.commentId, isPass: isPass)
                                }
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
                        } onDelete: { cmt, child in
                            // 删除评论事件
                            if let child = child {
                                // 当前是对子评论的删除操作
                                deleteCommentId = (child.commentId, cmt.commentId)
                            } else {
                                // 当前是对底层评论的删除操作
                                deleteCommentId = (cmt.commentId, nil)
                            }
                            
                            showDeleteCommentAlert = true
                        } onEdit: { cmt, child in
                            // 编辑评论事件
                            path.append(CommentRoute.Detail(comment: cmt, child: child))
                        } onReply: { cmt, child in
                            // 回复评论事件
                            path.append(CommentRoute.Reply(comment: cmt, child: child))
                        }
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
                .padding(.defaultSpacing)
            }
            .refreshable {
                await refreshComments()
            }
        }
        .toolbar {
            Menu {
                // 评论展示方式
                Menu {
                    Picker("评论展示",  selection: $treeFilter.animation()) {
                        Text("平铺展示").tag(false)
                        Text("树形展示").tag(true)
                    }
                    .onChange(of: treeFilter, { _, newValue in
                        // 不处理清空 (newValue == false) 的情况，因为在其他地方已经处理，防止重复刷新
                        Task {
                            await refreshComments()
                        }
                    })
                } label: {
                    Text("评论展示")
                }
                
                // 只有在平铺显示评论的情况下，下面的筛选才有效（后端接口决定，即使传了参数，也无效）
                if treeFilter == false {
                    // 评论状态
                    Menu {
                        Picker("评论状态",  selection: $statusFilter.animation()) {
                            Text("已审核").tag(true)
                            Text("未审核").tag(false)
                        }
                        .onChange(of: statusFilter, { _, newValue in
                            // 不处理清空 (newValue == nil) 的情况，因为在其他地方已经处理，防止重复刷新
                            if newValue != nil {
                                // 评论状态筛选，刷新评论
                                Task {
                                    await refreshComments()
                                }
                            }
                        })
                    } label: {
                        Text("评论状态")
                    }
                    
                    // 评论排序
                    Menu {
                        Picker("评论排序",  selection: $sortFilter.animation()) {
                            ForEach(CommentSort.allCases, id: \.self) { sort in
                                Text(sort.desc).tag(sort)
                            }
                        }
                        .onChange(of: sortFilter, { _, newValue in
                            // 不处理清空 (newValue == nil) 的情况，因为在其他地方已经处理，防止重复刷新
                            if newValue != nil {
                                // 评论排序筛选，刷新评论
                                Task {
                                    await refreshComments()
                                }
                            }
                        })
                    } label: {
                        Text("评论排序")
                    }
                    
                    // 评论关键词过滤
                    Button {
                        showKeywordFilterAlert = true
                    } label: {
                        Label("关键字搜索", systemImage: SFSymbol.character.rawValue)
                    }
                    
                    if isFilter {
                        // 当前处于筛选模式
                        Button {
                            clearFilter()
                        } label: {
                            Label("清除筛选", systemImage: SFSymbol.x.rawValue)
                        }
                    }
                }
            } label: {
                Label("评论选项", systemImage: SFSymbol.filter.rawValue)
            }
        }
        .navigationDestination(for: Post.self, destination: { post in
            // 文章详情页
            PostDetailView(post: post, viewModel: postVM) { _, _ in }
        })
        .navigationDestination(for: CommentRoute.self, destination: { route in
            switch route {
            case .Detail(let comment, let child):
                // 评论详情
                // 如果 child 不为空，则认为是对某个父评论的子评论进行的操作
                CommentDetailView(comment: child ?? comment, vm: vm) { newComment, delete in
                    // 评论保存事件
                    if !delete {
                        vm.updateExistComment(
                            comment: newComment,
                            // 如果 child 不等于 nil，证明当前是修改某个父评论的子评论，直接将 comment 传给 parent。
                            parent: child != nil ? comment : nil
                        )
                    } else {
                        // 评论删除（目前 CommentDetailView 暂未添加删除操作）
                        // TODO
                    }
                }
            case .Reply(let comment, let child):
                // 回复评论
                // 如果 child 不为空，则认为是对某个父评论的子评论进行的操作
                CommentReplyView(comment: child ?? comment, vm: vm) { newComment in
                    // 回复成功
                    vm.addExistComment(
                        comment: newComment,
                        // 如果当前是树形结构，始终认为回复的 comment 为 父评论
                        parent: treeFilter == true ? comment : (
                            // 如果 child 不等于 nil，证明当前是修改某个父评论的子评论，
                            // 直接将 comment 传给 parent。
                            child != nil ? comment : nil
                        )
                    )
                }
            }
            
        })
        .navigationTitle("评论")
        .navigationBarTitleDisplayMode(.inline)
        .messageAlert(isPresented: $showAlert, message: alertMessage)
        .confirmAlert(isPresented: $showDeleteCommentAlert, message: "确定要删除评论吗") {
            // 删除评论
            if let delete = deleteCommentId {
                deleteComment(id: delete.id, parentId: delete.parentId)
            }
        }
        // 关键词搜索弹窗
        .alert("关键字搜索", isPresented: $showKeywordFilterAlert) {
            TextField("评论内容、邮箱、名称", text: $keywordFilterEnter)
                .textInputAutocapitalization(.never)
            Button("搜索") {
                if !keywordFilterEnter.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    // 关键词不为空，搜索
                    withAnimation {
                        keywordFilter = keywordFilterEnter
                    }
                } else {
                    // 关键词为空，清空
                    withAnimation {
                        keywordFilter = nil
                    }
                }
                // 刷新评论
                Task {
                    await refreshComments()
                }
            }
            
            Button("取消" , role: .cancel) {
                // 清空关键词临时输入内容
                keywordFilterEnter = ""
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
        if let err = await vm.getComments(
            isPass: statusFilter,
            key: keywordFilter,
            sort: sortFilter,
            tree: treeFilter
        ) {
            alertMessage = err
            showAlert = true
        }
        firstRefresh = true
        isLoading = false
    }
    
    
    /// 通过审核
    /// - Parameters:
    ///   - id: 要修改的评论
    ///   - parentId: 父评论（如果有），此选项是为了在云端修改完成后，本地修改状态时减少每次查找的时间复杂度，
    ///               如果此项不为 nil，则认为上面的 id 指的是某个评论的子评论。
    ///   - isPass: 是否通过审核
    private func passComment(id: Int, parentId: Int? = nil, isPass: Bool = true) async {
        if let err = await vm.passComment(id: id, parentId: parentId, isPass: isPass) {
            alertMessage = err
            showAlert = true
        }
    }
    
    /// 删除评论
    /// - Parameters:
    ///   - id: 要删除的评论
    ///   - parentId: 父评论（如果有），此选项是为了在云端修改完成后，本地修改状态时减少每次查找的时间复杂度，
    ///               如果此项不为 nil，则认为上面的 id 指的是某个评论的子评论。
    private func deleteComment(id: Int, parentId: Int? = nil) {
        Task {
            if let err = await vm.deleteComment(id: id, parentId: parentId) {
                alertMessage = err
                showAlert = true
            }
            
            deleteCommentId = nil
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

    
    // 加载下一页
    private func loadNextPage() {
        isLoading = true
        Task {
            if let err = await vm.getComments(
                isPass: statusFilter,
                key: keywordFilter,
                sort: sortFilter,
                tree: treeFilter,
                loadMore: true
            ) {
                alertMessage = err
                showAlert = true
            }
            isLoading = false
        }
    }
    
    /// 清除筛选
    private func clearFilter() {
        withAnimation {
            sortFilter = nil
            statusFilter = nil
            keywordFilter = nil
            keywordFilterEnter = ""
        }
        
        // 刷新评论
        Task {
            await refreshComments()
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
                        .textInputAutocapitalization(.never)
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
            // 如果回复的评论有父评论，证明他已经是子评论，所以父评论和回复的评论相同。
            // 否则回复的是顶级评论，直接将父评论设为当前评论
            parentCommentId: comment.parentCommentId ?? comment.commentId,
            // 如果回复的评论有父评论，证明他已经是子评论，需要设置 replyCommentId。
            // 否则回复的是底层评论，不用设置 replyCommentId。
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

/// 评论过滤指示器
private struct CommentFilterIndicator: View {
    // 评论 ID
    @Binding var id: Int?
    // 评论状态（是否通过审核）
    @Binding var status: Bool?
    // 评论排序
    @Binding var sort: CommentSort?
    // 关键词
    @Binding var keyword: String?
    
    // 筛选清除事件
    var onClear: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: .defaultSpacing) {
            if let id = id {
                FilterIndicatorContainer(
                    title: "评论 ID",
                    content: String(id),
                    color: Color(UIColor.systemBlue)
                ) {
                    self.id = nil
                    onClear()
                }
            }
            
            if let status = status {
                FilterIndicatorContainer(
                    title: "评论状态",
                    content:  status ? "已审核" : "未审核",
                    color: status ? Color(UIColor.systemGreen) : Color(UIColor.systemRed)
                ) {
                    self.status = nil
                    onClear()
                }
            }
            
            if let sort = sort {
                FilterIndicatorContainer(
                    title: "评论排序",
                    content: sort.desc,
                    color: Color(UIColor.systemBlue)
                ) {
                    self.sort = nil
                    onClear()
                }
            }
            
            if let keyword = keyword {
                FilterIndicatorContainer(
                    title: "关键词",
                    content: keyword,
                    color: Color(UIColor.systemBlue)
                ) {
                    self.keyword = nil
                    onClear()
                }
            }
        }
    }
}

/// 评论路由类型
private enum CommentRoute: Hashable {
    /// 评论详情
    case Detail(
        comment: Comment,
        // 如果是对子评论的操作，需要传值，传了此值默认认为上面的 comment 为父评论
        child: Comment?
    )
    /// 回复评论
    case Reply(
        comment: Comment,
        // 如果是对子评论的操作，需要传值，传了此值默认认为上面的 comment 为父评论
        child: Comment?
    )
}



#Preview {
    @Previewable @State var path = NavigationPath()
    NavigationStack(path: $path) {
        CommentView(path: .constant(NavigationPath()))
    }
}
