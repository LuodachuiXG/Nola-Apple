//
//  SearchablePicker.swift
//  Nola
//
//  Created by loac on 03/06/2025.
//

import Foundation
import SwiftUI

/// 支持搜索和多选的 Picker
struct SearchablePicker<Item: Identifiable & Hashable, Label: Hashable>: View {
    
    @Environment(\.dismiss) var dismiss
    
    // 标题
    private var title: String
    
    // 项目数组
    private var _items: [Item]
    
    // 关键词搜索
    @State private var searchValue = ""
    
    // 展示的 Item（可能被关键字搜索过滤）
    private var items: [Item] {
        get {
            if searchValue.isEmpty {
                return _items
            }
            return _items.filter {
                String(describing: $0[keyPath: labelKeyPath])
                    .lowercased()
                    .contains(searchValue.lowercased())
            }
        }
    }
    
    // 标签 KeyPath
    private var labelKeyPath: KeyPath<Item, Label>
    
    // 已选择的项
    @State private var selected: Set<Item> = []
    
    // 是否允许多选
    private var allowMultiple = false
    
    // 完成选择完成事件
    private var onConfirm: ([Item]) -> Void = { _ in }
    
    /// 初始化 SearchablePicker
    /// - Parameters:
    ///   - items: 选项数组
    ///   - labelKeyPath: 标签 KeyPath（用于设置选项的标题）
    ///   - selected: 已选项
    ///   - allowMultiple: 是否允许多选（默认 false，单选）
    ///   - title: 选项页面标题（默认 “选择”）
    ///   - onConfirm: 用户选择完成后回调选择项（如果是单选，回调的数组长度始终为 1，多选则可能为 0）
    init(
        items: [Item],
        labelKeyPath: KeyPath<Item, Label>,
        selected: [Item] = [],
        allowMultiple: Bool = false,
        title: String? = nil,
        onConfirm: @escaping ([Item]) -> Void
    ) {
        self._items = items
        self.labelKeyPath = labelKeyPath
        self.selected = Set(selected)
        self.allowMultiple = allowMultiple
        self.title = title ?? "选择"
        self.onConfirm = onConfirm
    }
    
    var body: some View {
        List {
            ForEach(items, id: \.id) { item in
                Button {
                    if allowMultiple {
                        // 允许多选，添加当前项到已选择列表或从已选择列表中删除
                        if selected.contains(item) {
                            selected.remove(item)
                        } else {
                            selected.insert(item)
                        }
                    } else {
                        // 不允许多选，直接返回结果
                        onConfirm([item])
                        dismiss()
                    }
                } label: {
                    HStack {
                        Text(String(describing: item[keyPath: labelKeyPath]))
                            .tag(item.id)
                            .lineLimit(1)
                            .foregroundStyle(.foreground)
                        Spacer()
                        
                        if selected.contains(item) {
                            Image(systemName: "checkmark")
                        }
                    }
                }

            }
        }
        .toolbar {
            if allowMultiple {
                // 允许多选，显示完成按钮
                Button("完成") {
                    onConfirm(Array(selected))
                    dismiss()
                }
            }
        }
        .searchable(text: $searchValue, prompt: "搜索")
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    let categories: [Category] = [
        Category(categoryId: 1, displayName: "Java", slug: "java", cover: nil, unifiedCover: false, postCount: 0),
        Category(categoryId: 2, displayName: "Kotlin", slug: "kotlin", cover: nil, unifiedCover: false, postCount: 0),
        Category(categoryId: 3, displayName: "Android", slug: "android", cover: nil, unifiedCover: false, postCount: 0),
        Category(categoryId: 4, displayName: "iOS", slug: "ios", cover: nil, unifiedCover: false, postCount: 0)
    ]
    
    NavigationStack {
        SearchablePicker(
            items: categories,
            labelKeyPath: \.displayName,
            allowMultiple: true,
            title: "分类"
        ) { selected in
            print(selected)
        }
    }
}
