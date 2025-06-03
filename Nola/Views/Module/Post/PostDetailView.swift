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
    
    @State var post: Post
    
    @ObservedObject private var vm: PostViewModel
    
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
    
    // 文章原标题
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
