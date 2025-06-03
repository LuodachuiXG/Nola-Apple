//
//  PostView.swift
//  Nola
//
//  Created by loac on 18/05/2025.
//

import Foundation
import SwiftUI
import UIKit

/// 文章 View
struct PostView: View {
    
    @State private var title = "Hello"
    
    @StateObject private var vm = PostViewModel()
    
    @State private var showErrorAlert = false
    @State private var errorMessage = ""
    
    // 标记是否已经刷新过了，防止从子页面回来重复刷新
    @State var firstRefresh = false
    
    var body: some View {
        ZStack {
            if !firstRefresh {
                ProgressView()
            }
            
            ScrollView {
                LazyVStack(alignment: .leading, spacing: .defaultSpacing) {
                    ForEach(vm.posts, id: \.postId) { post in
                        NavigationLink {
                            PostDetailView(post: post, viewModel: vm)
                        } label: {
                            PostCard(post: post)
                                .tint(.primary)
                        }
                    }
                }
                .padding(.defaultSpacing)
            }
            .refreshable {
                await refreshPost()
            }
        }
        .navigationTitle("文章")
        .toolbarTitleDisplayMode(.inline)
        .messageAlert(isPresented: $showErrorAlert, message: LocalizedStringKey(errorMessage))
        .task {
            if !firstRefresh {
                await refreshPost()
            }
        }
        
    }
    
    /// 刷新文章
    private func refreshPost() async {
        if let err = await vm.getPosts() {
            errorMessage = err
            showErrorAlert = true
        }
        firstRefresh = true
    }
}

#Preview {
    NavigationStack {
        PostView()
    }
}
