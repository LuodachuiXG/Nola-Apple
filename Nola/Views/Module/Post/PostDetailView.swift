//
//  PostDetailView.swift
//  Nola
//
//  Created by loac on 20/05/2025.
//

import Foundation
import SwiftUI
import SDWebImageSwiftUI

/// 文章详情 View
struct PostDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    // 当前查看的文章
    @State var post: Post
    
    // 文章 ViewModel
    @ObservedObject private var vm: PostViewModel
    
    // 标记当前是否是添加文章
    @State private var isAddPost = false
    // 标记当前是否自动根据文章标题生成文章别名（手动修改别名后置 false）
    @State private var autoGenerateSlugByTitle = true
    
    // 保存回调事件 （修改后的文章, 是否是永久删除操作）
    private var onSavedCallback: (_ post: Post, _ delete: Bool) -> Void = { _, _ in }
    
    // 标记当前文章数据是否改变，用于在 dismiss 时触发上面的 onSaved 方法
    @State private var dataChange: Bool = false
    
    // 当前文章的分类和标签
    @State private var category: Category?
    @State private var tags: [Tag]
    private var tagsItemLabel: String {
        // 标签选项 Label，根据当前的标签数量动态改变
        get {
            if tags.isEmpty {
                return ""
            } else if tags.count == 1 {
                return tags.first!.displayName
            } else {
                // 大于 1
                return "\(tags.count) 个标签"
            }
        }
    }
    
    // 文章分类和标签搜索值
    @State private var categorySearch = ""
    @State private var tagSearch = ""
    
    // 文章原标题（防止修改文章标题时，因为 post 状态改变而导致 navigation title 改变）
    private let originalTitle: String
    
    // 文章摘要描述
    private var postExcerpt: String {
        let excerpt = post.excerpt
        if excerpt.isEmpty {
            return "点击设置"
        } else {
            return "\(excerpt.prefix(min(5, excerpt.count)))..."
        }
    }
    
    
    // 文章是否加密
    // true 为加密，需要设置提供新密码，
    // false 为删除旧密码，
    // nil 为保持当前不变
    @State private var isEncrypted: Bool? = nil
    // 文章新密码，当 isEncrypted 为 true 时需要
    @State private var newPassword: String? = nil
    
    
    // MARK: - Dialog
    // 错误弹窗
    @State private var showErrorAlert = false
    @State private var errorAlertMsg = ""
    
    // 显示将文章移入回收站弹窗
    @State private var showRecycleAlert = false
    
    // 显示将文章移出回收站弹窗（恢复文章）
    @State private var showRestoreAlert = false
    
    // 显示删除文章弹窗（彻底删除文章，只能删除处于 DELETE 状态的文章，即当前文章必须已经在回收站中）
    @State private var showDeleteAlert = false
    // 显示删除文章二次确认弹窗
    @State private var showDeleteConfirmAlert = false
    // MARK: - Dialog End
    
    
    // 加载状态
    @State private var isLoading = false
    
    // 当前文章是否加密描述
    private var postEncryptedDescription: String {
        
        if let np = newPassword, !np.isEmpty {
            // 设置了新密码
            if post.encrypted {
                // 当前文章已经是加密状态
                return "保存后修改密码"
            } else {
                // 当前文章是未加密状态
                return "保存后设置密码"
            }
        }
        
        
        if isEncrypted == true {
            return "已加密"
        } else if isEncrypted == false {
            // isEncrypted 默认是 nil，如果被设置为了 false，
            // 证明当前文章已经是加密状态（因为只有当前文章已经是加密状态时，才可以修改 isEncrypted），然后用户选择了清除密码。
            return "保存后清除密码"
        } else {
            // isEncrypted 为 nil，保持当前文章现状
            return post.encrypted ? "已加密" : "未加密"
        }
    }
    
    /// init
    /// - Parameters:
    ///   - post: 文章实体（非 nil 为编辑现有文章，nil 为添加文章）
    ///   - viewModel: PostViewModel 实体
    ///   - onSaved: 保存回调
    init(post: Post?, viewModel: PostViewModel, onSaved: @escaping (_ post: Post, _ delete: Bool) -> Void) {
        var p = post
        if p == nil {
            // 当前是新增文章
            isAddPost = true
            p = Post(
                postId: -1,
                title: "",
                autoGenerateExcerpt: true,
                excerpt: "",
                slug: "",
                allowComment: true,
                pinned: false,
                status: .DRAFT,
                visible: .VISIBLE,
                encrypted: false,
                visit: -1,
                tags: [],
                createTime: -1,
                lastModifyTime: nil
            )
            originalTitle = "添加文章"
        } else {
            originalTitle = p!.title
        }
        
        self.post = p!
        self.vm = viewModel
        self.category = p!.category
        self.tags = p!.tags
        self.onSavedCallback = onSaved
    }
    
    var body: some View {
        List {
            if let cover = post.actualCover, let url = URL(string: cover) {
                Section {
                    ShareImageView(url: url)
                }
                .listRowInsets(EdgeInsets())
                .shadow(radius: .defaultShadowRadius)
            }
            
            Section("基本信息") {
                ListItem(label: "标题") {
                    TextField(
                        text: Binding(
                            get: {
                                post.title
                            },
                            set: { newValue in
                                post.title = newValue
                                if isAddPost && autoGenerateSlugByTitle {
                                    // 当前是添加文章，并且自动根据标题生成别名为 true。自动同步修改文章别名
                                    post.slug = newValue.toPinyin()
                                }
                            }
                        )
                    ) {
                        Text("文章标题")
                    }
                    .textInputAutocapitalization(.never)
                }
                
                ListItem(label: "别名") {
                    TextField(
                        text: Binding(
                            get: {
                                post.slug
                            },
                            set: { newValue in
                                post.slug = newValue
                                // 手动修改后，禁止自动根据标题生成别名
                                autoGenerateSlugByTitle = false
                            }
                        )
                    ) {
                        Text("文章别名")
                    }
                    .textInputAutocapitalization(.never)
                }
                .contextMenu {
                    Button("自动生成别名", systemImage: SFSymbol.quote.rawValue) {
                        post.slug = post.title.toPinyin()
                    }
                }
                
                ListItem(label: "摘要") {
                    NavigationLink {
                        ExcerptView(post: $post)
                    } label: {
                        HStack {
                            Spacer()
                            Text(postExcerpt)
                                .lineLimit(1)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
                
                // 分类选择
                ListItem(label: "分类") {
                    NavigationLink {
                        SearchablePicker(
                            items: vm.categories,
                            labelKeyPath: \.displayName,
                            selected: category == nil ? [] : [category!],
                            title: "选择分类"
                        ) { ret in
                            category = ret.first!
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text(category?.displayName ?? "")
                                .lineLimit(1)
                                .foregroundStyle(Color.secondary)
                        }
                        .contextMenu {
                            Button {
                                self.category = nil
                            } label: {
                                Label("清除分类", systemImage: SFSymbol.x.rawValue)
                            }
                        }
                    }
                }
                
                // 标签选择
                ListItem(label: "标签") {
                    NavigationLink {
                        SearchablePicker(
                            items: vm.tags,
                            labelKeyPath: \.displayName,
                            selected: tags,
                            allowMultiple: true,
                            title: "选择标签"
                        ) { ret in
                            tags = ret
                        }
                    } label: {
                        HStack {
                            Spacer()
                            Text(tagsItemLabel)
                                .lineLimit(1)
                                .foregroundStyle(Color.secondary)
                        }
                        .contextMenu {
                            Button {
                                self.tags = []
                            } label: {
                                Label("清除标签", systemImage: SFSymbol.x.rawValue)
                            }
                        }
                    }
                }
            }
            
            Section("文章状态") {
                Toggle(isOn: $post.allowComment) {
                    Text("允许评论")
                }
                
                Toggle(isOn: $post.pinned) {
                    Text("置顶")
                }
                
                // 文章状态（文章在回收站时不显示）
                if post.status != .DELETED {
                    Picker(selection: $post.status) {
                        Text("已发布")
                            .tag(PostStatus.PUBLISHED)
                        Text("草稿")
                            .tag(PostStatus.DRAFT)
                    } label: {
                        Text("状态")
                    }
                }
                
                // 文章可见性
                Picker(selection: $post.visible) {
                    Text("可见")
                        .tag(PostVisible.VISIBLE)
                    Text("隐藏")
                        .tag(PostVisible.HIDDEN)
                } label: {
                    Text("可见性")
                }
            }
            
            // 静态信息仅在编辑文章时可见
            if !isAddPost {
                Section("静态信息") {
                    ListItem(label: "访问量") {
                        Text(String(post.visit))
                    }
                    
                    if let modifyTime = post.lastModifyTime {
                        ListItem(label: "修改时间") {
                            Text(String(modifyTime.formatMillisToDateStr()))
                        }
                    }
                    ListItem(label: "创建时间") {
                        Text(String(post.createTime.formatMillisToDateStr()))
                    }
                }
            }
            
            Section("密码") {
                ListItem(label: "文章密码") {
                    NavigationLink {
                        PasswordView(post: post, isEncrypted: $isEncrypted, newPassword: $newPassword)
                    } label: {
                        HStack {
                            Spacer()
                            Text(postEncryptedDescription)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                }
            }
            
            // 仅当编辑文章时显示
            if !isAddPost {
                Section {
                    NavigationLink {
                        PreviewPost(vm: vm, post: $post)
                    } label: {
                        Text("查看文章")
                            .foregroundStyle(Color.blue)
                    }
                }
            }
            
            Section(isAddPost ? "编辑文章" : "返回时自动保存文章内容") {
                NavigationLink {
                    PostContentView(vm: vm, post: $post, isAddPost: $isAddPost)
                } label: {
                    Text("编辑文章")
                        .foregroundStyle(Color.blue)
                }
            }
            
            // 只有在编辑文章时才显示删除操作
            if !isAddPost {
                Section {
                    if post.status != .DELETED {
                        Button("加入回收站", role: .destructive) {
                            showRecycleAlert = true
                        }
                        
                        
                    } else {
                        Button("移出回收站") {
                            showRestoreAlert = true
                        }
                        .foregroundStyle(Color(cgColor: UIColor.systemGreen.cgColor))
                        
                        Button("彻底删除", role: .destructive) {
                            showDeleteAlert = true
                        }
                    }
                }
            }
            
        }
        // 错误弹窗
        .messageAlert(isPresented: $showErrorAlert, message: errorAlertMsg)
        // 回收文章弹窗
        .confirmAlert(isPresented: $showRecycleAlert, message: "要将当前文章放入回收站吗") {
            onRecyclePost()
        }
        // 恢复文章弹窗
        .alert("确定将文章移出回收站吗", isPresented: $showRestoreAlert) {
            Button("转为发布状态") {
                onRestorePost(status: .PUBLISHED)
            }
            
            Button("转为草稿状态") {
                onRestorePost(status: .DRAFT)
            }
            
            
            Button("取消", role: .cancel) {}
        }
        // 删除文章弹窗
        .confirmAlert(isPresented: $showDeleteAlert, message: "确定要永久删除当前文章吗") {
            showDeleteConfirmAlert = true
        }
        // 删除文章二次确认弹窗
        .confirmAlert(isPresented: $showDeleteConfirmAlert, message: "点击确定删除文章，此操作不可逆") {
            onDeletePost()
        }
        .task {
            // 尝试获取所有分类
            if vm.categories.isEmpty {
                if let err = await vm.getCategories() {
                    errorAlertMsg = err
                    showErrorAlert = true
                }
            }
            // 尝试获取所有标签
            if vm.tags.isEmpty {
                if let err = await vm.getTags() {
                    errorAlertMsg = err
                    showErrorAlert = true
                }
            }
        }
        .toolbar {
            Button(isAddPost ? "发布" : "保存") {
                onSave()
            }
        }
        .navigationTitle(originalTitle)
    }
    
    /// 保存事件
    private func onSave() {
        isLoading = true
        
        var isEncrypt: Bool? {
            if isEncrypted == false {
                // 清除密码
                return false
            }
            
            if newPassword == nil || newPassword!.isEmpty {
                // 没有设置新密码，保持当前状态不变
                return nil
            }
            
            if newPassword != nil && !newPassword!.isEmpty {
                // 设置了新密码
                return true
            }
            
            return false
        }
        
        
        if isAddPost {
            // 当前是新增文章
            Task {
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
                    password: isEncrypt == true ? newPassword : nil
                )
                
                if let error = ret.error {
                    // 新建文章发生错误
                    errorAlertMsg = error
                    showErrorAlert = true
                } else if let post = ret.post {
                    // 新建文章成功
                    withAnimation {
                        self.post = post
                        // 转为编辑模式
                        self.isAddPost = false
                        onSavedCallback(post, false)
                        dismiss()
                    }
                } else {
                    // 文章和错误信息都为 nil
                    errorAlertMsg = "未知错误，请稍后重试"
                    showErrorAlert = true
                }
                isLoading = false
            }
        } else {
            // 当前是编辑文章
        
            Task {
                if let err = await vm.updatePost(
                    postId: post.postId,
                    title: post.title,
                    autoGenerateExcerpt: post.autoGenerateExcerpt,
                    excerpt: post.excerpt,
                    slug: post.slug,
                    allowComment: post.allowComment,
                    status: post.status,
                    visible: post.visible,
                    categoryId: category?.id,
                    tagIds: tags.map { $0.id },
                    cover: post.cover,
                    pinned: post.pinned,
                    encrypted: isEncrypt,
                    password: newPassword
                ) {
                    // 发生错误
                    errorAlertMsg = err
                    showErrorAlert = true
                } else {
                    // 保存成功
                    onSavedCallback(post, false)
                    dismiss()
                }
                
                isLoading = false
            }
        }
    }
    
    /// 将文章放入回收站
    private func onRecyclePost() {
        isLoading = true
        Task {
            if let err = await vm.recyclePost(ids: [post.postId]) {
                // 发生错误
                errorAlertMsg = err
                showErrorAlert = true
            } else {
                // 成功放入回收站
                withAnimation {
                    post.status = .DELETED
                }
                // 告知上一页文章数据发生改变
                onSavedCallback(post, false)
            }
            
            isLoading = false
        }
    }
    
    /// 将文章恢复
    /// - Parameters:
    ///   - status: 恢复文章状态（只能设为 DRAFT 或者 PUBLISHED）
    private func onRestorePost(status: PostStatus) {
        guard status != .DELETED else { return }
        isLoading = true
        Task {
            if let err = await vm.restorePost(ids: [post.postId], status: status) {
                // 发生错误
                errorAlertMsg = err
                showErrorAlert = true
            } else {
                // 恢复成功
                withAnimation {
                    post.status = status
                }
                // 告知上一页文章数据发生改变
                onSavedCallback(post, false)
            }
            
            isLoading = false
        }
    }
    
    /// 彻底删除文章，只能在文章处于 DELETE 状态时调用，即文章已经在回收站时。
    private func onDeletePost() {
        guard post.status == .DELETED else { return }
        
        isLoading = true
        Task {
            if let err = await vm.deletePost(ids: [post.postId]) {
                // 发生错误
                errorAlertMsg = err
                showErrorAlert = true
            } else {
                // 删除成功
                onSavedCallback(post, true)
                dismiss()
            }
            isLoading = false
        }
    }
}


/// 预览文章内容
private struct PreviewPost: View {
    
    @ObservedObject var vm: PostViewModel
    
    @Binding var post: Post
    
    @State private var isLoading = false
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State private var postContent: PostContent? = nil
    
    
    var body: some View {
        ZStack(alignment: .center) {
            if isLoading {
                ProgressView()
            } else {
                MarkdownView(content: postContent?.content ?? "", isMarkdown: true)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task {
            isLoading = true
            let ret = await vm.getPostContent(id: post.postId)
            if let err = ret.error {
                alertMessage = err
                showAlert = true
            } else if let content = ret.content {
                postContent = content
            }
            
            withAnimation {
                isLoading = false
            }
        }
        .messageAlert(isPresented: $showAlert, message: alertMessage)
        .navigationTitle(post.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}




/// 摘要编辑页面
private struct ExcerptView: View {
    
    @Binding var post: Post
    
    var body: some View {
        List {
            Section("保存后自动根据文章内容生成摘要") {
                Toggle(
                    isOn: Binding(
                        get: {
                            post.autoGenerateExcerpt
                        },
                        set: { newValue in
                            withAnimation {
                                post.autoGenerateExcerpt = newValue
                            }
                        }
                    )
                ) {
                    Text("自动生成摘要")
                }
            }
            
            if !post.autoGenerateExcerpt {
                Section("摘要内容") {
                    ZStack {
                        TextEditor(text: $post.excerpt)
                            .frame(minHeight: 240)
                            .submitLabel(.done)
                            .disabled(post.autoGenerateExcerpt)
                    }
                    .listRowInsets(EdgeInsets())
                    .padding(.defaultSpacing)
                }
            }
        }
        .navigationTitle("摘要")
    }
}


/// 文章加密设置页面
private struct PasswordView: View {
    
    var post: Post
    
    // 文章是否加密
    // true 为加密，需要设置提供新密码，
    // false 为删除旧密码，
    // nil 为保持当前不变
    @Binding var isEncrypted: Bool?
    // 文章新密码，当 isEncrypted 为 true 时需要
    @Binding var newPassword: String?
    
    var body: some View {
        List {
            
            if post.encrypted {
                // 文章当前已经是加密状态（Toggle 仅在当前文章已经是加密的状态时才会显示，用于清除加密）
                Section(isEncrypted == false ? "保存后文章密码会被清除" : "文章加密状态") {
                    Toggle(
                        "文章加密",
                        isOn: Binding(
                            get: {
                                return isEncrypted == nil || isEncrypted!
                            }, set: { newValue in
                                withAnimation {
                                    isEncrypted = newValue
                                }
                            }
                        )
                    )
                }
            }
            
            
            if isEncrypted != false {
                // isEncrypted 被设为了 false，证明当前文章状态是已加密，然后又取消加密，所以隐藏密码框
                Section("文章密码") {
                    SecureField(
                        text: Binding(
                            get: {
                                return newPassword ?? ""
                            }, set: { newValue in
                                newPassword = newValue
                            }
                        ),
                        prompt: Text(post.encrypted ? "文章已设置密码，输入设置新密码" : "输入密码")
                    ) {}
                }
            }
        }
        .navigationTitle("文章密码")
    }
}



