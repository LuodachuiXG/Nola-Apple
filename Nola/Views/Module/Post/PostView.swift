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
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading, spacing: .defaultSpacing) {
                ForEach(vm.posts, id: \.postId) { post in
                    PostCard(post: post)
                }
            }
            .padding(.defaultSpacing)
        }
        .navigationTitle("文章")
        .messageAlert(isPresented: $showErrorAlert, message: LocalizedStringKey(errorMessage))
        .task {
            vm.getPosts { err in
                errorMessage = err
                showErrorAlert = true
            }
        }
    }
}

#Preview {
    PostView()
}
