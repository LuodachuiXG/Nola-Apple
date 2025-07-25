//
//  CommentCard.swift
//  Nola
//
//  Created by loac on 17/06/2025.
//

import Foundation
import SwiftUI
import UIKit
import SDWebImageSwiftUI

/// 评论卡片
struct CommentCard: View {
    
    /// 评论实体
    var comment: Comment
    
    /// 文章标题点击事件
    var onPostClick: (_ postId: Int) -> Void
    
    /// 通过审核按钮点击事件（操作的评论, 操作的子评论, 是否通过审核），如果 child 不为 nil，则认为是对 child 的操作，
    /// 对 child 的操作时也传递 comment 是否为了快速定位父评论，减少时间复杂度。
    var onPassClick: (_ comment: Comment, _ child: Comment?, _ isPass: Bool) -> Void
    
    /// 站点地址点击事件
    var onSiteClick: (_ side: String) -> Void
    
    /// 删除评论事件（操作的评论, 操作的子评论（如果是对子评论操作）），如果 child 不为 nil，则认为是对 child 的操作。
    var onDelete: (_ comment: Comment, _ child: Comment?) -> Void
    
    /// 编辑评论事件（操作的评论, 操作的子评论（如果是对子评论操作）），如果 child 不为 nil，则认为是对 child 的操作。
    var onEdit: (_ comment: Comment, _ child: Comment?) -> Void
    
    /// 回复评论事件（操作的评论, 操作的子评论（如果是对子评论操作）），如果 child 不为 nil，则认为是对 child 的操作。
    var onReply: (_ comment: Comment, _ child: Comment?) -> Void
    
    /// 文章内容，动态添加回复人等信息
    private var content: AttributedString {
        var text = AttributedString()
        
        if let name = comment.replyDisplayName {
            // 当前评论是回复别的评论
            var replyText = AttributedString("回复 \(name): ")
            replyText.foregroundColor = .secondary
            text.append(replyText)
        }
        
        text.append(AttributedString(comment.content))
        return text
    }
    
    // 是否显示评论详细信息
    @State private var showDetail = false
    
    /// Init
    /// - Parameters:
    ///   - comment: 评论实体
    ///   - onPostClick: 文章点击事件
    ///   - onPassClick: 通过审核点击事件（操作的评论, 是否是子评论的操作, 是否通过审核）
    ///                  如果 child 不为 nil，则认为是对 child的操作，
    ///                  对 child 的操作时也传递 comment 是否为了快速定位父评论，减少时间复杂度。
    ///   - onSiteClick: 站点地址点击事件
    ///   - onDelete: 删除评论事件（操作的评论, 是否是子评论的操作, 是否通过审核），
    ///               如果 child 不为 nil，则认为是对child的操作。
    ///   - onEdit: 编辑评论事件（操作的评论, 是否是子评论的操作, 是否通过审核），
    ///             如果 child 不为 nil，则认为是对child的操作。
    init(
        comment: Comment,
        onPostClick: @escaping (_ postId: Int) -> Void = { _ in },
        onPassClick: @escaping (
            _ comment: Comment,
            _ child: Comment?,
            _ isPass: Bool
        ) -> Void = { _, _, _  in },
        onSiteClick: @escaping (_ site: String) -> Void = { _ in },
        onDelete: @escaping (_ comment: Comment, _ child: Comment?) -> Void = { _, _ in },
        onEdit: @escaping (_ comment: Comment, _ child: Comment?) -> Void = { _, _ in },
        onReply: @escaping (_ comment: Comment, _ child: Comment?) -> Void = { _, _ in }
    ) {
        self.comment = comment
        self.onPostClick = onPostClick
        self.onPassClick = onPassClick
        self.onSiteClick = onSiteClick
        self.onDelete = onDelete
        self.onEdit = onEdit
        self.onReply = onReply
    }
    
    var body: some View {
        Card {
            VStack(alignment: .leading, spacing: .defaultSpacing) {
                // 名称和 ID
                HStack(alignment: .center) {
                    
                    if !comment.isPass {
                        // 当前评论未通过审核
                        ZStack {
                            Text("待审核")
                                .foregroundStyle(.white)
                                .font(.caption)
                                .fontWeight(.semibold)
                        }
                        .padding(2)
                        .background(Color(UIColor.systemRed))
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                    }
                    
                    // 当前评论的父评论
                    if let parent = comment.parentCommentId {
                        Text("#\(parent)")
                            .foregroundStyle(.secondary)
                    }
                    
                    // 名称
                    Text(comment.displayName)
                        .font(.headline)
                    
                    Spacer()
                    
                    // 楼层号
                    Text("#\(comment.commentId)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                  
                }
                .lineLimit(1)
                
                // 邮箱地址
                if showDetail {
                    Text(comment.email)
                        .foregroundStyle(.secondary)
                        .font(.caption)
                        .textSelection(.enabled)
                }
                
                // 内容
                Text(content)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .lineLimit(showDetail ? Int.max : 3)
                    .textSelection(.enabled)
                
                // 评论更多详细信息
                if showDetail {
                    
                    // 文章标题
                    if let title = comment.postTitle {
                        HStack {
                            Image(symbol: .post)
                            Text(title)
                        }
                        .font(.footnote)
                        .foregroundStyle(Color(.systemBlue))
                        .lineLimit(1)
                        .onTapGesture {
                            onPostClick(comment.postId)
                        }
                    }
                    
                    // 站点地址
                    if let site = comment.site {
                        HStack {
                            Image(symbol: .globe)
                            
                            // 如果站点地址为 /，则代表是当前主站
                            Text(site == "/" ? "博客主站" : site)
                                .textSelection(.enabled)
                        }
                        .font(.footnote)
                        .foregroundStyle(site == "/" ? .secondary : Color(.systemBlue))
                        .lineLimit(1)
                        .onTapGesture {
                            // 如果当前站点地址是主站，则不跳转网页
                            if site != "/" {
                                onSiteClick(site)
                            }
                        }
                    }
                }
                
                // 创建时间
                HStack(alignment: .bottom) {
                    Text(comment.createTime.formatMillisToDateStr())
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    if let children = comment.children, !children.isEmpty {
                        Text("\(children.count) 个回复")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // 通过审核按钮
                if !comment.isPass {
                    Button {
                        onPassClick(comment, nil, true)
                    } label: {
                        HStack {
                            Image(symbol: .check)
                            Text("通过审核")
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 5)
                        .background(.secondary)
                        .font(.callout)
                        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
                    }

                }
                
                // 子评论
                if showDetail {
                    if let children = comment.children {
                        LazyVStack(spacing: .defaultSpacing) {
                            ForEach(children, id: \.commentId) { cmt in
                                CommentCard(
                                    comment: cmt
                                ) { postId in
                                    // 子评论文章点击事件
                                    self.onPostClick(postId)
                                } onPassClick: { _, _, isPass in
                                    // 子评论通过审核点击事件
                                    self.onPassClick(comment, cmt, isPass)
                                } onSiteClick: { site in
                                    // 子评论站点点击的事件
                                    self.onSiteClick(site)
                                } onDelete: { _, _ in
                                    // 子评论删除点击事件
                                    self.onDelete(comment, cmt)
                                } onEdit: { _, _ in
                                    // 子评论编辑事件
                                    self.onEdit(comment, cmt)
                                } onReply: { _, _ in
                                    // 子评论回复事件
                                    self.onReply(comment, cmt)
                                }
                                .shadow(radius: .defaultShadowRadius)
                            }
                        }
                    }
                }
                
            }
            .padding(.defaultSpacing)
        }
        .clipShape(RoundedRectangle(cornerRadius: .defaultCornerRadius))
        .tint(.primary)
        .onTapGesture {
            withAnimation {
                showDetail.toggle()
            }
        }
        .contextMenu {
            // 编辑评论
            Button {
                onEdit(comment, nil)
            } label: {
                Label("编辑评论", systemImage: SFSymbol.edit.rawValue)
            }
            
            // 撤销或通过审核
            Button(role: comment.isPass ? .destructive : .cancel) {
                onPassClick(comment, nil, !comment.isPass)
            } label: {
                Label(
                    comment.isPass ? "撤销审核" : "通过审核",
                    systemImage: comment.isPass ? SFSymbol.returnIcon.rawValue :
                        SFSymbol.check.rawValue
                )
            }
            
            // 删除评论
            Button(role: .destructive) {
                onDelete(comment, nil)
            } label: {
                Label("删除评论", systemImage: SFSymbol.trash.rawValue)
            }
            
            Divider()
            
            // 回复评论（仅通过审核的评论可以回复）
            if comment.isPass {
                Button {
                    onReply(comment, nil)
                } label: {
                    Label("回复评论", systemImage: SFSymbol.reply.rawValue)
                }
            }
        }
    }
}
