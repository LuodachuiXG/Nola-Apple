//
//  PostView.swift
//  Nola
//
//  Created by loac on 18/05/2025.
//

import Foundation
import SwiftUI

/// 文章 View
struct PostView: View {
    
    @State private var title = "文章"
    
    @Binding var path: NavigationPath
    // 文章 ID 筛选（ID 筛选无法直接展示给用户，这里仅用于页面跳转，代码内部使用），
    // 如果不为 nil，需要在获取到文章后直接进入文章详情页面，然后将此值赋 nil。
    @State var postIdFilter: Int? = nil
    
    @StateObject private var vm = PostViewModel()
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    // 标记是否已经刷新过了，防止从子页面回来重复刷新
    @State private var firstRefresh = false
    
    @State private var isLoading = false
    
    // MARK: - 文章筛选
    // 文章状态筛选
    @State private var statusFilter: PostStatus? = nil
    // 文章可见性筛选
    @State private var visibleFilter: PostVisible? = nil
    // 文章排序
    @State private var sortFilter: PostSort? = nil
    // 关键词搜索
    @State private var keywordFilter: String? = nil
    // 关键词输入临时变量
    @State private var keywordFilterEnter = ""
    // 是否显示关键词搜索弹窗
    @State private var showKeywordFilterAlert = false
    // 当前是否在筛选状态
    private var isFilter: Bool {
        postIdFilter != nil || statusFilter != nil || visibleFilter != nil ||
        sortFilter != nil || keywordFilter != nil
    }
    // MARK: - 文章筛选
    
    // 下拉刷新提示文字
    private var pullUpRefreshText: String {
        if let pager = vm.pager {
            if !vm.hasNextPage {
                "没有更多文章了"
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
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: .defaultSpacing) {
                    if isFilter {
                        // 当前文章在筛选状态，显示筛选指示器
                        PostFilterIndicator(
                            id: $postIdFilter.animation(),
                            status: $statusFilter.animation(),
                            visible: $visibleFilter.animation(),
                            sort: $sortFilter.animation(),
                            keyword: $keywordFilter.animation()
                        ) {
                            // 筛选清除事件，刷新文章
                            refreshPostByChangeFilter()
                        }
                    }
                    ForEach(vm.posts, id: \.postId) { post in
                        NavigationLink(value: post) {
                            PostCard(post: post)
                                .tint(.primary)
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
                                        // 加载下一页文章
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
                await refreshPost()
            }
        }
        .toolbar {
            // 添加文章按钮
            NavigationLink {
                // 新增文章
                postDetailView(post: nil)
            } label: {
                Label("添加文章", systemImage: SFSymbol.plus.rawValue)
            }

            
            // 文章过滤菜单
            Menu {
                // 文章状态过滤
                Menu {
                    Picker("文章状态",  selection: $statusFilter.animation()) {
                        ForEach(PostStatus.allCases, id: \.self) { status in
                            Text(status.desc).tag(status)
                        }
                    }
                    .onChange(of: statusFilter, { _, newValue in
                        // 不处理清空 (newValue == nil) 的情况，因为在其他地方已经处理，防止重复刷新
                        if newValue != nil {
                            // 文章状态筛选，刷新文章
                            refreshPostByChangeFilter()
                        }
                    })
                } label: {
                    Text("文章状态")
                }
                
                // 文章可见性过滤
                Menu {
                    Picker("文章可见性",  selection: $visibleFilter.animation()) {
                        ForEach(PostVisible.allCases, id: \.self) { visible in
                            Text(visible.desc).tag(visible)
                        }
                    }
                    .onChange(of: visibleFilter, { _, newValue in
                        // 不处理清空 (newValue == nil) 的情况，因为在其他地方已经处理，防止重复刷新
                        if newValue != nil {
                            // 文章可见性筛选，刷新文章
                            refreshPostByChangeFilter()
                        }
                    })
                } label: {
                    Text("文章可见性")
                }
                
                // 文章排序
                Menu {
                    Picker("文章排序",  selection: $sortFilter.animation()) {
                        ForEach(PostSort.allCases, id: \.self) { sort in
                            Text(sort.desc).tag(sort)
                        }
                    }
                    .onChange(of: sortFilter, { _, newValue in
                        // 不处理清空 (newValue == nil) 的情况，因为在其他地方已经处理，防止重复刷新
                        if newValue != nil {
                            // 文章排序筛选，刷新文章
                            refreshPostByChangeFilter()
                        }
                    })
                } label: {
                    Text("文章排序")
                }
                
                
                // 文章关键词过滤
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
                
            } label: {
                Label("文章选项", systemImage: SFSymbol.filter.rawValue)
            }

        }
        // 关键词搜索弹窗
        .alert("关键字搜索", isPresented: $showKeywordFilterAlert) {
            TextField("标题、别名、摘要、内容", text: $keywordFilterEnter)
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
                // 刷新文章
                refreshPostByChangeFilter()
            }
            
            Button("取消" , role: .cancel) {
                // 清空关键词临时输入内容
                keywordFilterEnter = ""
            }
        }
        .navigationDestination(for: Post.self, destination: { post in
            // 文章详情页面
            postDetailView(post: post)
        })
        .navigationTitle("文章")
        .toolbarTitleDisplayMode(.inline)
        .messageAlert(isPresented: $showErrorAlert, message: LocalizedStringKey(errorMessage))
        .task {
            if !firstRefresh {
                await refreshPost()
            }
        }
        
    }
    
    /// 文章详情 View
    /// - Parameters:
    ///   - post: 文章实体（非 nil 为编辑现有文章，nil 为新增文章）
    private func postDetailView(post: Post?) -> some View {
        return PostDetailView(post: post, viewModel: vm) { newPost, isDelete in
            // 发生文章保存事件，刷新文章内容
            Task {
                if isDelete {
                    // 当前是永久删除操作
                    vm.deleteExistPost(post: newPost)
                } else {
                    // 普通修改操作
                    if let err = await vm.updateExistPost(post: newPost) {
                        self.errorMessage = err
                        self.showErrorAlert = true
                    }
                }
            }
        }
    }
    
    /// 刷新文章
    private func refreshPost() async {
        isLoading = true
        
        if let postId = postIdFilter {
            // 文章 ID 不为空，从别的地方跳转某个单独文章，只获取单个文章
            let ret = await vm.getPostById(id: postId, saveToViewModel: true)
            if let err = ret.error {
                errorMessage = err
                showErrorAlert = true
            }
        } else {
            // 文章 ID 为空，正常刷新所有文章
            if let err = await vm.getPosts(
                status: statusFilter,
                visible: visibleFilter,
                key: keywordFilter,
                sort: sortFilter
            ) {
                errorMessage = err
                showErrorAlert = true
            }
        }
        
        firstRefresh = true
        isLoading = false
    }
    
    /// 改变筛选项后刷新文章
    /// 在刷新文章前会先将页码重置到第 1 页
    private func refreshPostByChangeFilter() {
        Task {
            // 修改筛选后先重置页码
            vm.resetPage()
            // 刷新文章
            await refreshPost()
        }
    }
    
    /// 加载下一页
    private func loadNextPage() {
        isLoading = true
        Task {
            if let err = await vm.getPosts(
                loadMore: true,
                status: statusFilter,
                visible: visibleFilter,
                key: keywordFilter,
                sort: sortFilter
            ) {
                errorMessage = err
                showErrorAlert = true
            }
            isLoading = false
        }
    }
    
    
    /// 清除筛选
    private func clearFilter() {
        withAnimation {
            statusFilter = nil
            visibleFilter = nil
            sortFilter = nil
            keywordFilter = nil
            keywordFilterEnter = ""
        }
        
        // 刷新文章
        refreshPostByChangeFilter()
    }

}

/// 文章过滤指示器
private struct PostFilterIndicator: View {
    // 文章 ID
    @Binding var id: Int?
    // 文章状态
    @Binding var status: PostStatus?
    // 文章可见性
    @Binding var visible: PostVisible?
    // 文章排序
    @Binding var sort: PostSort?
    // 关键词
    @Binding var keyword: String?
    
    // 筛选清除事件
    var onClear: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: .defaultSpacing) {
            if let id = id {
                FilterIndicatorContainer(
                    title: "文章 ID",
                    content: String(id),
                    color: Color(UIColor.systemBlue)
                ) {
                    self.id = nil
                    onClear()
                }
            }
            
            if let status = status {
                FilterIndicatorContainer(title: "文章状态", content: status.desc, color: status.color) {
                    self.status = nil
                    onClear()
                }
            }
            
            if let visible = visible {
                FilterIndicatorContainer(title: "文章可见性", content: visible.desc, color: visible.color) {
                    self.visible = nil
                    onClear()
                }
            }
            
            if let sort = sort {
                FilterIndicatorContainer(title: "文章排序", content: sort.desc, color: Color(UIColor.systemBlue)) {
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

#Preview {
    NavigationStack {
        PostView(path: .constant(NavigationPath()))
    }
}
