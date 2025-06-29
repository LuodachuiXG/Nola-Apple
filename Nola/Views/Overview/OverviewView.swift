//
//  OverviewView.swift
//  Nola
//
//  Created by loac on 18/03/2025.
//

import SwiftUI
import DotLottie
import WaterfallGrid

/// 概览页面
struct OverviewView: View {
    
    @ObservedObject var contentVM: ContentViewModel
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // 分类和标签的 ViewModel
    @ObservedObject private var categoryVM = CategoryViewModel()
    @ObservedObject private var tagVM = TagViewModel()
    
    private let gridCols = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    // 文章最多的 6 个分类
    var categories: [Category] {
        guard let cs = contentVM.blogOverview?.categories else {
            return []
        }
        
        // 取文章数量最多的 6 个分类
        return Array(
            cs.sorted { a, b in
                return a.postCount > b.postCount
            }[0..<min(6, cs.count)]
        )
    }
    
    // 文章最多的 6 个标签
    var tags: [Tag] {
        guard let ts = contentVM.blogOverview?.tags else {
            return []
        }
        
        // 取文章数量最多的 6 个标签
        return Array(
            ts.sorted { a, b in
                return a.postCount > b.postCount
            }[0..<min(6, ts.count)]
        )
    }
    
    var body: some View {
        NavigationStack {
            ScrollView([.vertical]) {
                VStack(alignment: .leading, spacing: .defaultSpacing) {
                    
                    if let overview = contentVM.blogOverview {
                        // 浏览最多的文章卡片
                        if let post = overview.mostViewedPost {
                            OverviewTitle(title: "浏览最多")
                            MostViewedPostCard(post: post)
                        }
                        
                        OverviewTitle(title: "统计数据")
                        LazyVGrid(columns: gridCols) {
                            // 博客已创建时间
                            if let creatTime = overview.createDate {
                                StatisticalDataCard(
                                    title: "博客已建立",
                                    content: "\(creatTime.millisDaysSince()) 天"
                                ).aspectRatio(1, contentMode: .fill)
                            }
                            
                            // 上次登录时间
                            StatisticalDataCard(
                                title: "上次登录",
                                content: overview.lastLoginDate == nil ? "无" : overview.lastLoginDate!.timeAgoSince()
                            ).aspectRatio(1, contentMode: .fill)
                        }
                        
                        // 文章最多的 6 个分类
                        if !categories.isEmpty {
                            OverviewTitle(title: "文章最多的 \(min(6, categories.count)) 个分类")
                            
                            WaterfallGrid(categories, id: \.categoryId) { category in
                                NavigationLink {
                                    CategoryDetailView(category: category, viewModel: categoryVM) { category, delete in
                                        // 修改了分类，刷新
                                        if delete {
                                            // 删除了分类
                                            contentVM.deleteExistOverviewCategory(category)
                                        } else {
                                            // 更新分类
                                            contentVM.updateExistOverviewCategory(category)
                                        }
                                    }
                                } label: {
                                    CategoryCard(category: category)
                                }
                            }
                            .gridStyle(columns: 2, spacing: .defaultSpacing)
                            .scrollOptions(direction: .vertical)
                        }
                        
                        // 文章最多的 6 个标签
                        if !tags.isEmpty {
                            OverviewTitle(title: "文章最多的 \(min(6, categories.count)) 个标签")
                            LazyVGrid(columns: gridCols, alignment: .leading, spacing: .defaultSpacing) {
                                ForEach(
                                    tags,
                                    id: \.tagId
                                ) { tag in
                                    NavigationLink {
                                        TagDetailView(tag: tag, viewModel: tagVM) { tag, delete in
                                            // 修改了标签，刷新
                                            if delete {
                                                // 删除了标签
                                                contentVM.deleteExistOverviewTag(tag)
                                            } else {
                                                // 更新标签
                                                contentVM.updateExistOverviewTag(tag)
                                            }
                                        }
                                    } label: {
                                        TagCard(tag: tag)
                                    }
                                }
                            }
                        }
                        
                        // 最近一条操作记录
                        if let lastOperation = overview.lastOperation {
                            OverviewTitle(title: "最近操作")
                            
                            Card(alignment: .leading, padding: .defaultSpacing) {
                                Text(lastOperation)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .lineLimit(3)
                                    .fontWeight(.semibold)
                            }
                        }
                        
                        Spacer()
                    } else {
                        // 未登录或者还未获取到博客概览数据
                        Text("欢迎使用 Nola")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("登录账号继续")
                            .font(.title3)
                        
                        DotLottieAnimation(
                            fileName: "hello",
                            config: AnimationConfig(autoplay: true, loop: true)
                        )
                        .view()
                        .frame(height: 300)
                        .padding(.top, .defaultSpacing * 10)
                    }
                }.padding()
            }
            .messageAlert(isPresented: $showAlert, message: LocalizedStringKey(alertMessage))
            .refreshable {
                await refreshOverview()
            }
            .navigationTitle(contentVM.blogOverview == nil ? "" : "概览")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    /// 刷新概览数据
    private func refreshOverview() async {
        if let err = await contentVM.refreshOverview() {
            alertMessage = err
            showAlert = true
        }
    }
}

/// 概览标题
private struct OverviewTitle: View {
    var title: String
    
    var body: some View {
        Text(title)
            .font(.title2)
            .fontWeight(.semibold)
            .padding(.top, .defaultSpacing)
    }
    
}

#Preview {
    OverviewView(contentVM: ContentViewModel())
}
