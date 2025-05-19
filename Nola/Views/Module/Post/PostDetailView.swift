//
//  PostDetailView.swift
//  Nola
//
//  Created by loac on 20/05/2025.
//

import Foundation
import SwiftUI

/// 文章详情 View
struct PostDetailView: View {
    
    var post: Post
    
    @State var allowComment = false
    
    var body: some View {
        List {
            Section("基本信息") {
                Toggle(isOn: $allowComment) {
                    Text("允许评论")
                }
                
                OptionItem(label: "创建时间") {
                    Text(String(post.createTime.formatMillisToDateStr()))
                }
            }
        }
        .navigationTitle(post.title)
    }
}


/// List 选项
private struct OptionItem<Content: View>: View {
    
    var label: String
    var content: Content
    
    init(label: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.content = content()
    }
    
    var body: some View {
        HStack {
            Text(label)
            Spacer()
            content
        }
    }
}
