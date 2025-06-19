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
                                .tint(.primary)
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
    
    /// 删除现有的标签
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
