//
//  PostDetailView.swift
//  Nola
//
//  Created by loac on 20/05/2025.
//

import Foundation
import SwiftUI

/// 文章详情 View
struct PostDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    // 当前查看的文章
    @State var post: Post
    
    // 文章 ViewModel
    @ObservedObject private var vm: PostViewModel
    
    // 错误弹窗
    @State private var showErrorAlert = false
    @State private var errorAlertMsg = ""
    
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
    
    // 文章摘要
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
    
    init(post: Post, viewModel: PostViewModel) {
        self.post = post
        self.vm = viewModel
        self.category = post.category
        self.tags = post.tags
        originalTitle = post.title
    }
    
    var body: some View {
        List {
            Section("基本信息") {
                OptionItem(label: "标题") {
                    TextField(text: $post.title) {
                        Text("文章标题")
                    }
                    .textInputAutocapitalization(.never)
                }
                
                OptionItem(label: "别名") {
                    TextField(text: $post.slug) {
                        Text("文章别名")
                    }
                    .textInputAutocapitalization(.never)
                }
                .contextMenu {
                    Button("自动生成别名", systemImage: SFSymbol.quote.rawValue) {
                        post.slug = post.title.toPinyin()
                    }
                }
                
                OptionItem(label: "摘要") {
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
                OptionItem(label: "分类") {
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
                    }
                }
                
                // 标签选择
                OptionItem(label: "标签") {
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
                
                // 文章状态
                Picker(selection: $post.status) {
                    Text("已发布")
                        .tag(PostStatus.PUBLISHED)
                    Text("草稿")
                        .tag(PostStatus.DRAFT)
                } label: {
                    Text("状态")
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
            
            Section("静态信息") {
                OptionItem(label: "访问量") {
                    Text(String(post.visit))
                }
                
                if let modifyTime = post.lastModifyTime {
                    OptionItem(label: "修改时间") {
                        Text(String(modifyTime.formatMillisToDateStr()))
                    }
                }
                OptionItem(label: "创建时间") {
                    Text(String(post.createTime.formatMillisToDateStr()))
                }
            }
            
            Section("密码") {
                OptionItem(label: "文章密码") {
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
            
            Section {
                Button("编辑") {
                    
                }
            }
            
            Section {
                Button("加入回收站", role: .destructive) {
                    
                }
            }
            
        }
        .task {
            if vm.categories.isEmpty {
                if let err = await vm.getCategories() {
                    errorAlertMsg = err
                    showErrorAlert = true
                }
            }
            
            if vm.tags.isEmpty {
                if let err = await vm.getTags() {
                    errorAlertMsg = err
                    showErrorAlert = true
                }
            }
        }
        .toolbar {
            Button("保存") {
                dismiss()
            }
        }
        .navigationTitle(originalTitle)
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


/// List 选项
private struct OptionItem<Content: View>: View {
    
    var label: String
    var content: Content
    
    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            content
                .multilineTextAlignment(.trailing)
        }
    }
}
