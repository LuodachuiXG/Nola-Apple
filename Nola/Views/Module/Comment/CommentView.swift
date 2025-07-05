//
//  CommentView.swift
//  Nola
//
//  Created by loac on 17/06/2025.
//

import Foundation
import SwiftUI


/// 评论 View
struct CommentView: View {
    
    @Binding var path: NavigationPath
    
    @ObservedObject private var vm: CommentViewModel = CommentViewModel()
    
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    // 标记当前是否已经完成第一次刷新
    @State private var firstRefresh = false
    
    var body: some View {
        ZStack {
            if !firstRefresh {
                ProgressView()
            }
            
            ScrollView(showsIndicators: true) {
                LazyVStack(spacing: .defaultSpacing) {
                    ForEach(vm.comments, id: \.commentId) { comment in
                        CommentCard(comment: comment)
                    }
                }
            }
            .refreshable {
                await refreshComments()
            }
        }
        .toolbar {
            
        }
        .navigationDestination(for: Int.self, destination: { postId in
            PostView(path: $path, postIdFilter: postId)
        })
        .navigationTitle("评论")
        .navigationBarTitleDisplayMode(.inline)
        .messageAlert(isPresented: $showAlert, message: alertMessage)
        .task {
            if !firstRefresh {
                // 没有完成首次刷新才刷
                await refreshComments()
            }
        }
    }
    
    /// 刷新分类
    private func refreshComments() async {
        if let err = await vm.getComments() {
            alertMessage = err
            showAlert = true
        }
        
        firstRefresh = true
    }
    
    /// 更新现有的分类
    /// - Parameters:
    ///   - category: 新分类实体
    //    private func updateExistCategory(category: Category) {
    //        Task {
    //            if let error = await vm.updateExistCategory(category: category) {
    //                alertMessage = error
    //                showAlert = true
    //            }
    //        }
    //    }
    
    /// 删除分类（云端）
    /// - Parameters:
    ///   - category: 要删除的分类实体
    private func deleteCategory(category: Category) {
        //        Task {
        //            if let err = await vm.deleteCategory(category: category) {
        //                // 发生错误
        //                alertMessage = err
        //                showAlert = true
        //            } else {
        //                // 成功后删除本地分类
        //                deleteExistCategory(category: category)
        //            }
        //        }
        //    }
        
        /// 删除现有的分类（本地变量）
        /// - Parameters:
        ///   - category: 要删除的分类实体
        //    private func deleteExistCategory(category: Category) {
        //        vm.deleteExistCategory(category: category)
        //    }
    }
}

#Preview {
    NavigationStack {
        CommentView(path: .constant(NavigationPath()))
    }
}
