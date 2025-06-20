//
//  CategoryDetailView.swift
//  Nola
//
//  Created by loac on 18/06/2025.
//

import Foundation
import SwiftUI


/// 分类详情 View
struct CategoryDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var category: Category
    
    @ObservedObject var vm: CategoryViewModel
    
    @State private var originalTitle = ""
    
    // 当前是否是添加分类模式
    @State private var isAddCategory = false
    
    // 标记当前是否自动生成摘要（用于在新建分类时使用）
    @State private var autoGenerateSlug = true
    
    // 消息弹窗
    @State private var alertMsg = ""
    @State private var showAlert = false
    
    // 显示删除弹窗
    @State private var showDeleteAlert = false
    
    // 保存/添加完成事件，回调新的标签（新分类实体, 是否是删除操作）
    private var onSave: (_ category: Category, _ delete: Bool) -> Void = { _, _ in }
    
    
    /// 初始化函数
    /// - Parameters:
    ///   - category: 分类实体，nil 为新建分类，非 nil 为编辑分类
    init(category: Category?, viewModel: CategoryViewModel, onSave: @escaping (_ category: Category, _ delete: Bool) -> Void) {
        self.onSave = onSave
        if let category = category {
            originalTitle = category.displayName
            self.category = category
        } else {
            isAddCategory = true
            originalTitle = "添加分类"
            self.category = Category(
                categoryId: -1, displayName: "", slug: "",
                cover: nil, unifiedCover: false, postCount: 0
            )
        }
        self.vm = viewModel
    }
    
    var body: some View {
        List {
            if let cover = category.cover, let url = URL(string: cover) {
                Section {
                    ShareImageView(url: url)
                }
                .listRowInsets(EdgeInsets())
                .shadow(radius: .defaultShadowRadius)
            }
            
            Section("基本信息") {
                ListItem(label: "分类名") {
                    TextField("分类名", text: $category.displayName)
                        .onChange(of: category.displayName) { oldValue, newValue in
                            if (isAddCategory && autoGenerateSlug) {
                                category.slug = newValue.toPinyin()
                            }
                        }
                }
                ListItem(label: "分类别名") {
                    TextField(
                        "分类别名",
                        text: Binding(
                            get: {
                                category.slug
                            },
                            set: { newValue in
                                category.slug = newValue
                                // 手动编辑别名后将自动生成别名设为 false
                                autoGenerateSlug = false
                            }
                        )
                    )
                }
                .contextMenu {
                    Button("自动生成别名", systemImage: SFSymbol.quote.rawValue) {
                        category.slug = category.displayName.toPinyin()
                    }
                    
                }
                ListItem(label: "统一封面") {
                    Toggle(isOn: $category.unifiedCover){}
                }
            }
            
            
            if !isAddCategory {
                // 添加分类时不显示静态信息
                Section("静态信息") {
                    ListItem(label: "文章数量") {
                        Text(String(category.postCount))
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Text("删除分类")
                    }
                    
                }
            }
        }
        .messageAlert(isPresented: $showAlert, message: alertMsg)
        .confirmAlert(isPresented: $showDeleteAlert, message: "确定要删除当前分类吗") {
            deleteCategory()
        }
        .navigationTitle(originalTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(isAddCategory ? "添加" : "保存") {
                saveCategory()
            }
        }
    }
    
    /// 保存 / 新建分类
    private func saveCategory() {
        Task {
            
            if category.cover != nil && category.cover!.isEmpty {
                category.cover = nil
            }
            
            if isAddCategory {
                // 当前是添加分类
                let ret = await vm.addCategory(category: category)
                if let err = ret.error {
                    // 发生错误
                    alertMsg = err
                    showAlert = true
                } else if let category = ret.category {
                    // 添加完成
                    dismiss()
                    onSave(category, false)
                }
            } else {
                // 当前是编辑分类
                if let err = await vm.updateCategory(category: category) {
                    // 失败
                    alertMsg = err
                    showAlert = true
                } else {
                    // 保存成功
                    dismiss()
                    onSave(category, false)
                }
            }
        }
    }
    
    /// 删除分类
    private func deleteCategory() {
        Task {
            if let err = await vm.deleteCategory(category: category) {
                alertMsg = err
                showAlert = true
            } else {
                // 删除成功
                dismiss()
                onSave(category, true)
            }
        }
    }
}
