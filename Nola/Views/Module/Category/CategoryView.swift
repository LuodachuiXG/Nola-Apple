//
//  CategoryView.swift
//  Nola
//
//  Created by loac on 17/06/2025.
//

import Foundation
import SwiftUI
import WaterfallGrid


/// 分类 View
struct CategoryView: View {
    
    @ObservedObject private var vm: CategoryViewModel = CategoryViewModel()
    
    @State private var isLoading = false
    
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    // 标记当前是否已经完成第一次刷新
    @State private var firstRefresh = false
    
    @State private var showDeleteAlert = false
    @State private var waitForDeleteCategory: Category? = nil
    
    private let columns: [GridItem] = [.init(.flexible()), .init(.flexible())]
    
    var body: some View {
        ZStack {
            if !firstRefresh {
                ProgressView()
            }
            
            ScrollView(showsIndicators: true) {
                WaterfallGrid(vm.categories, id: \.categoryId) { category in
                    NavigationLink {
                        CategoryDetailView(category: category, viewModel: vm) { category, delete in
                            if delete {
                                // 删除分类
                                deleteExistCategory(category: category)
                            } else {
                                // 保存分类
                                updateExistCategory(category: category)
                            }
                        }
                    } label: {
                        CategoryCard(category: category)
                            .contextMenu {
                                Button(role: .destructive) {
                                    waitForDeleteCategory = category
                                    showDeleteAlert = true
                                } label: {
                                    Label("删除分类", systemImage: SFSymbol.trash.rawValue)
                                }
                            }
                    }
                }
                .gridStyle(columns: 2, spacing: .defaultSpacing)
                .scrollOptions(direction: .vertical)
                .padding(.defaultSpacing)
            }
            .refreshable {
                await refreshCategories()
            }
        }
        .toolbar {
            NavigationLink {
                CategoryDetailView(category: nil, viewModel: vm) { newCategory, _ in
                    // 分类添加完成保存事件
                    updateExistCategory(category: newCategory)
                }
            } label: {
                Label("添加分类", systemImage: SFSymbol.plus.rawValue)
            }
        }
        .navigationTitle("分类")
        .navigationBarTitleDisplayMode(.inline)
        .messageAlert(isPresented: $showAlert, message: alertMessage)
        .confirmAlert(
            isPresented: $showDeleteAlert,
            message: "确定要删除分类 [\(waitForDeleteCategory?.displayName ?? "未知分类")] 吗"
        ) {
            if let category = waitForDeleteCategory {
                deleteCategory(category: category)
            }
        }
        .task {
            if !firstRefresh {
                // 没有完成首次刷新才刷
                await refreshCategories()
            }
        }
    }
    
    /// 刷新分类
    private func refreshCategories() async {
        if let err = await vm.getCategories() {
            alertMessage = err
            showAlert = true
        }
        
        firstRefresh = true
    }
    
    /// 更新现有的分类
    /// - Parameters:
    ///   - category: 新分类实体
    private func updateExistCategory(category: Category) {
        Task {
            if let error = await vm.updateExistCategory(category: category) {
                alertMessage = error
                showAlert = true
            }
        }
    }
    
    /// 删除分类（云端）
    /// - Parameters:
    ///   - category: 要删除的分类实体
    private func deleteCategory(category: Category) {
        Task {
            if let err = await vm.deleteCategory(category: category) {
                // 发生错误
                alertMessage = err
                showAlert = true
            } else {
                // 成功后删除本地分类
                deleteExistCategory(category: category)
            }
        }
    }
    
    /// 删除现有的分类（本地变量）
    /// - Parameters:
    ///   - category: 要删除的分类实体
    private func deleteExistCategory(category: Category) {
        vm.deleteExistCategory(category: category)
    }
}

#Preview {
    NavigationStack {
        CategoryView()
    }
}
