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
    
    @Environment(\.dismiss) var dismiss
    
    @State var post: Post
    
    
    private let originalTitle: String
    
    // 文章摘要
    private var postExcerpt: String {
        let excerpt = post.excerpt
        if excerpt.isEmpty {
            return "点击设置"
        } else {
            return "\(excerpt.prefix(min(5, excerpt.count)))..."
        }
    }
    
    
    init(post: Post) {
        self.post = post
        originalTitle = post.title
    }
    
    var body: some View {
        List {
            Section("基本信息") {
                
                OptionItem(label: "标题") {
                    TextField(text: $post.title) {
                        Text("文章标题")
                    }
                    .textInputAutocapitalization(.never)
                }
                
                OptionItem(label: "别名") {
                    TextField(text: $post.slug) {
                        Text("文章别名")
                    }
                    .textInputAutocapitalization(.never)
                }
                
                OptionItem(label: "摘要") {
                    NavigationLink {
                        List {
                            TextEditor(text: $post.excerpt)
                                .frame(minHeight: 240)
                        }
                        .navigationTitle("摘要")
                    } label: {
                        HStack {
                            Spacer()
                            Text(postExcerpt)
                                .lineLimit(1)
                                .foregroundStyle(Color.secondary)
                        }
                    }
                    
                    
                }
                
                Picker(selection: .constant("Java")) {
                    Text("Java").tag("Java")
                    Text("Kotlin").tag("Kotlin")
                    Text("Swift").tag("Swift")
                } label: {
                    Text("分类")
                }
                .pickerStyle(.navigationLink)
                
                Picker(selection: .constant("Java")) {
                    Text("Java").tag("Java")
                    Text("Kotlin").tag("Kotlin")
                    Text("Swift").tag("Swift")
                } label: {
                    Text("标签")
                }
                .pickerStyle(.navigationLink)
                
                Toggle(isOn: $post.allowComment) {
                    Text("允许评论")
                }
                
                Toggle(isOn: $post.pinned) {
                    Text("置顶")
                }
            }
            
            Section("静态信息") {
                OptionItem(label: "访问量") {
                    Text(String(post.visit))
                }
                
                if let modifyTime = post.lastModifyTime {
                    OptionItem(label: "修改时间") {
                        Text(String(modifyTime.formatMillisToDateStr()))
                    }
                }
                OptionItem(label: "创建时间") {
                    Text(String(post.createTime.formatMillisToDateStr()))
                }
            }
        }
        .toolbar {
            Button("保存") {
                dismiss()
            }
        }
        .navigationTitle(originalTitle)
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
                .multilineTextAlignment(.trailing)
        }
    }
}
