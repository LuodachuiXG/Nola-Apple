//
//  CommentViewModel.swift
//  Nola
//
//  Created by loac on 17/06/2025.
//

import Foundation
import SwiftUI


@MainActor
final class CommentViewModel: ObservableObject {
    
    @Published var comments: [Comment] = []
    
    // 当前页码（0 获取所有）
    private var page = 0
    // 每页大小
    private var pageSize = 20
    
    var pager: Pager<[Comment]>? = nil
    
    // 是否还有下一页
    var hasNextPage: Bool {
        if let pager = pager {
            page < pager.totalPages
        } else {
            false
        }
    }

    
    /// 添加评论（回复评论）
    /// - Parameters:
    ///   - category: 分类实体
    /// - Returns: (分类实体, 错误信息)
    func addComment(
        postId: Int,
        parentCommentId: Int?,
        replyCommentId: Int?,
        content: String,
        site: String?,
        displayName: String,
        email: String,
        isPass: Bool
    ) async -> (comment: Comment?, error: String?) {
        do {
            let ret = try await CommentService.addComment(
                postId: postId,
                parentCommentId: parentCommentId,
                replyCommentId: replyCommentId,
                content: content,
                site: (site == nil || site!.isEmpty) ? nil : site,
                displayName: displayName,
                email: email,
                isPass: isPass
            )
            if let comment = ret.data {
                return (comment, nil)
            }
        } catch let err as ApiError {
            return (nil, err.message)
        } catch {
            return (nil, error.localizedDescription)
        }
        
        return (nil, "未知错误")
    }
    
    /// 添加现有评论
    /// - Parameters:
    ///   - comment: 要添加的评论
    ///   - parent: 父评论（如果有），如果此项不为 nil，新评论将插入到当前父评论的子数组中。
    ///   - at: 添加的位置，默认 0
    func addExistComment(
        comment: Comment,
        parent: Comment? = nil,
        at index: Int = 0
    ) {
        
        if let parent = parent {
            // 父评论不为空，将评论插入父的子数组中
            // 先找到父评论
            for i in 0..<comments.count {
                if comments[i].commentId == parent.commentId {
                    // 找到父评论，将新的评论插入
                    var p = comments[i]
                    var children = p.children ?? [Comment]()
                    children.insert(comment, at: index)
                    p.children = children
                    withAnimation {
                        comments[i] = p
                    }
                    return
                }
            }
            return
        }
        
        // 直接将新评论插入评论数组
        withAnimation {
            comments.insert(comment, at: index)
        }
    }
    
    /// 更新评论
    /// - Parameters:
    ///   - commentId: 评论 ID
    ///   - content: 评论内容
    ///   - site: 站点地址
    ///   - displayName: 名称
    ///   - email: 邮箱
    ///   - isPass: 是否通过审核
    func updateComment(
        commentId: Int,
        content: String,
        site: String?,
        displayName: String,
        email: String,
        isPass: Bool
    ) async -> String? {
        do {
            let _ = try await CommentService.updateComment(
                commentId: commentId,
                content: content,
                site: (site == nil || site!.isEmpty) ? nil : site,
                displayName: displayName,
                email: email,
                isPass: isPass
            )
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        
        return nil
    }
    
    /// 更新现有的评论
    /// - Parameters:
    ///   - comment: 评论实体
    ///   - parent: 父评论实体（如果有），此选项是为了在更新本地评论时减少时间复杂度（在所有评论中嵌套循环找子，变为先找父再找子），
    ///             如果此项不为 nil，则认为上面的 comment 是某个父评论的子评论。
    func updateExistComment(comment: Comment, parent: Comment? = nil) {
        
        if let parent = parent {
            // 当前是更新某个父评论下的子评论，先找到父
            for i in 0..<comments.count {
                if comments[i].commentId == parent.commentId {
                    // 找到了父评论
                    var p = comments[i]
                    var children = p.children ?? [Comment]()
                    // 找到子评论并更新
                    for j in 0..<children.count {
                        if children[j].commentId == comment.commentId {
                            children[j] = comment
                            p.children = children
                            withAnimation {
                                comments[i] = p
                            }
                            return
                        }
                    }
                    
                    // for 循环结束了走到这里，没有找到子评论，证明当前是新增
                    children.append(comment)
                    p.children = children
                    withAnimation {
                        comments[i] = p
                    }
                    return
                }
            }
            return
        }
        
        
        
        
        // 当前是对顶层评论的操作，直接找到并替换
        for i in 0..<comments.count {
            if comments[i].commentId == comment.commentId {
                withAnimation {
                    comments[i] = comment
                }
                return
            }
        }
        
        // for 循环结束了走到这里，当前是新增，插入头部
        withAnimation {
            comments.insert(comment, at: 0)
        }
    }
    
    
    /// 获取所有评论
    /// - Parameters:
    ///   - isPass: 是否通过审核（默认 nil 获取所有）
    ///   - key: 关键词（内容、邮箱、名称）
    ///   - sort: 评论排序（默认 nil 默认排序）
    ///   - tree: 是否树形结构（默认 false 平铺）
    ///   - loadMore: 是否加载更多（默认 false 即加载第一页，true 增加页码追加下一页到尾部）
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
    func getComments(
        isPass: Bool? = nil,
        key: String? = nil,
        sort: CommentSort? = nil,
        tree: Bool = false,
        loadMore: Bool = false
    ) async -> String? {
        do {
            if loadMore {
                // 加载下一页
                if hasNextPage {
                    page += 1
                    if let c = try await CommentService.getComments(
                        page: page,
                        size: pageSize,
                        postId: nil,
                        commentId: nil,
                        parentCommentId: nil,
                        isPass: isPass,
                        key: key,
                        sort: sort,
                        tree: tree
                    ).data {
                        self.pager = c
                        if let cs = c.data {
                            withAnimation {
                                comments += cs
                            }
                        }
                    }
                }
            } else {
                // 加载第一页
                page = 1
                if let pager = try await CommentService.getComments(
                    page: page,
                    size: pageSize,
                    postId: nil,
                    commentId: nil,
                    parentCommentId: nil,
                    isPass: isPass,
                    key: key,
                    sort: sort,
                    tree: tree
                ).data {
                    self.pager = pager
                    if let comments = pager.data {
                        withAnimation {
                            self.comments = comments
                        }
                    }
                }
            }
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        
        return nil
    }

    /// 删除评论
    /// - Parameters:
    ///   - id: 要删除的评论
    ///   - parentId: 父评论（如果有），此选项是为了在云端修改完成后，本地修改状态时减少每次查找的时间复杂度，
    ///               如果此项不为 nil，则认为上面的 id 指的是某个评论的子评论。
    func deleteComment(id: Int, parentId: Int? = nil) async -> String? {
        do {
            let ret = try await CommentService.deleteComments(ids: [id])
            if ret.data == true {
                // 删除完成，更新评论列表
                deleteExistComment(id: id, parentId: parentId)
            }
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        
        return nil
    }
    
    /// 删除现有的评论
    /// - Parameters:
    ///   - id: 要删除的评论
    ///   - parentId: 父评论（如果有）
    func deleteExistComment(id: Int, parentId: Int? = nil) {
        if let parentId = parentId {
            // 当前是删除某个父评论下的子评论，先找到父评论
            for i in 0..<comments.count {
                if comments[i].commentId == parentId {
                    // 已经找到父评论，过滤掉被删除的子评论
                    withAnimation {
                        comments[i].children = comments[i].children?.filter { $0.commentId != id}
                    }
                    return
                }
            }
        } else {
            // 当前是删除顶层评论，不是子评论，直接过滤
            withAnimation {
                comments = comments.filter { $0.commentId != id }
            }
        }
        
    }
    
    /// 评论通过审核
    /// - Parameters:
    ///   - id: 要修改的评论
    ///   - parentId: 父评论（如果有），此选项是为了在云端修改完成后，本地修改状态时减少每次查找的时间复杂度，
    ///               如果此项不为 nil，则认为上面的 id 指的是某个评论的子评论。
    ///   - isPass: 是否通过审核，默认 true 通过审核
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
    func passComment(
        id: Int,
        parentId: Int? = nil,
        isPass: Bool = true
    ) async -> String? {
        do {
            let ret = try await CommentService.updateCommentPass(ids: [id], isPass: isPass)
            if ret.data == true {
                // 修改评论状态
                if let parentId = parentId {
                    
                    // 当前修改的是子评论，先找到父评论
                    for i in 0..<comments.count {
                        if comments[i].commentId == parentId, var children = comments[i].children {
                            var comment = comments[i]
                            // 找到本次修改的子评论
                            for j in 0..<children.count {
                                if children[j].commentId == id {
                                    // 修改子评论状态
                                    children[j].isPass = isPass
                                    comment.children = children
                                    
                                    withAnimation {
                                        comments[i] = comment
                                    }
                                    return nil
                                }
                            }
                        }
                    }
                    return nil
                }
                
                
                // 当前修改的是顶层父评论，正常处理先找到评论
                for i in 0..<comments.count {
                    if comments[i].commentId == id {
                        var comment = comments[i]
                        comment.isPass = isPass
                        withAnimation {
                            comments[i] = comment
                        }
                        break
                    }
                }
                return nil
            }
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        
        return nil
    }
    
}
