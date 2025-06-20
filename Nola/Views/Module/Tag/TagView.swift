//
//  TagView.swift
//  Nola
//
//  Created by loac on 17/06/2025.
//

import Foundation
import SwiftUI


/// 标签 View
struct TagView: View {
    
    @ObservedObject private var vm: TagViewModel = TagViewModel()
    
    @State private var isLoading = false
    
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    // 标记当前是否已经完成第一次刷新
    @State private var firstRefresh = false
    
    @State private var showDeleteAlert = false
    @State private var waitForDeleteTag: Tag? = nil
    
    private let columns: [GridItem] = [.init(.flexible()), .init(.flexible())]
    
    var body: some View {
        ZStack {
            if !firstRefresh {
                ProgressView()
            }
            
            ScrollView {
                LazyVGrid(columns: columns, spacing: .defaultSpacing) {
                    ForEach(vm.tags, id: \.id) { tag in
                        NavigationLink {
                            TagDetailView(tag: tag, viewModel: vm) { tag, delete in
                                if delete {
                                    // 删除标签
                                    deleteExistTag(tag: tag)
                                } else {
                                    // 保存标签
                                    updateExistTag(tag: tag)
                                }
                            }
                        } label: {
                            TagCard(tag: tag)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        waitForDeleteTag = tag
                                        showDeleteAlert = true
                                    } label: {
                                        Label("删除标签", systemImage: SFSymbol.trash.rawValue)
                                    }
                                }
                        }
                    }
                }
                .padding(.defaultSpacing)
            }
            
            .refreshable {
                await refreshTags()
            }
        }
        .toolbar {
            NavigationLink {
                TagDetailView(tag: nil, viewModel: vm) { newTag, _ in
                    // 标签添加完成保存事件
                    updateExistTag(tag: newTag)
                }
            } label: {
                Label("添加标签", systemImage: SFSymbol.plus.rawValue)
            }
        }
        .navigationTitle("标签")
        .navigationBarTitleDisplayMode(.inline)
        .messageAlert(isPresented: $showAlert, message: alertMessage)
        .confirmAlert(
            isPresented: $showDeleteAlert,
            message: "确定要删除标签 [\(waitForDeleteTag?.displayName ?? "未知标签")] 吗"
        ) {
            if let tag = waitForDeleteTag {
                deleteTag(tag: tag)
            }
        }
        .task {
            if !firstRefresh {
                // 没有完成首次刷新才刷
                await refreshTags()
            }
        }
    }
    
    /// 刷新标签
    private func refreshTags() async {
        if let err = await vm.getTags() {
            alertMessage = err
            showAlert = true
        }
        
        firstRefresh = true
    }
    
    /// 更新现有的标签
    /// - Parameters:
    ///   - tag: 新标签实体
    private func updateExistTag(tag: Tag) {
        Task {
            if let error = await vm.updateExistTag(tag: tag) {
                alertMessage = error
                showAlert = true
            }
        }
    }
    
    /// 删除标签（云端）
    /// - Parameters:
    ///   - tag: 要删除的标签实体
    private func deleteTag(tag: Tag) {
        Task {
            if let err = await vm.deleteTag(tag: tag) {
                // 发生错误
                alertMessage = err
                showAlert = true
            } else {
                // 成功后删除本地标签
                deleteExistTag(tag: tag)
            }
        }
    }
    
    /// 删除现有的标签（本地变量）
    /// - Parameters:
    ///   - tag: 要删除的标签实体
    private func deleteExistTag(tag: Tag) {
        vm.deleteExistTag(tag: tag)
    }
}

#Preview {
    NavigationStack {
        TagView()
    }
}
