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
    
    
    /// 新增分类
    /// - Parameters:
    ///   - category: 分类实体
    /// - Returns: (分类实体, 错误信息)
//    func addCategory(category: Category) async -> (category: Category?, error: String?) {
//        do {
//            let ret = try await CategoryService.addCategory(
//                displayName: category.displayName,
//                slug: category.slug,
//                cover: category.cover,
//                unifiedCover: category.unifiedCover
//            )
//            if let category = ret.data {
//                return (category, nil)
//            }
//        } catch let err as ApiError {
//            return (nil, err.message)
//        } catch {
//            return (nil, error.localizedDescription)
//        }
//        
//        return (nil, "未知错误")
//    }
    
    /// 删除评论
    /// - Parameters:
    ///   - ids: 评论 ID 数组
    func deleteComment(ids: [Int]) async -> String? {
        do {
            let ret = try await CommentService.deleteComments(ids: ids)
            if ret.data == true {
                // 删除更新，更新评论列表
                deleteExistComment(ids: ids)
            }
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        
        return nil
    }
    
    /// 更新现有的评论
    /// - Parameters:
    ///   -  comment: 评论实体
    func updateExistComment(comment: Comment) {
        for i in 0..<comments.count {
            if comments[i].commentId == comment.commentId {
                withAnimation {
                    comments[i] = comment
                }
            }
        }
        
        // for 循环结束了走到这里，当前是新增，插入头部
        withAnimation {
            comments.insert(comment, at: 0)
        }
    }
    
    /// 删除现有的分类
    /// - Parameters:
    ///   - ids: 评论 ID 数组
    func deleteExistComment(ids: [Int]) {
        let set = Set(ids)
        withAnimation {
            comments = comments.filter { !set.contains($0.commentId) }
        }
    }
    
    
    /// 获取所有评论
    /// - Parameters:
    ///   - loadMore: 是否加载更多（默认 false 即加载第一页，true 增加页码追加下一页到尾部）
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
    func getComments(
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
                        isPass: nil,
                        key: nil
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
                    isPass: nil,
                    key: nil
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
    
    /// 根据分类 ID 获取分类
    /// - Parameters:
    ///   - categoryId: 分类 ID
//    func getCategoryById(categoryId: Int) async -> (category: Category?, error: String?) {
//        do {
//            let ret = try await CategoryService.getCategoryById(categoryId: categoryId)
//            if let category = ret.data {
//                return (category, nil)
//            }
//        } catch let err as ApiError {
//            return (nil, err.message)
//        } catch {
//            return (nil, error.localizedDescription)
//        }
//        
//        return (nil, "未知错误")
//    }
//    
    
    /// 评论通过审核
    /// - Parameters:
    ///   - ids: 评论 ID 数组
    ///   - isPass: 是否通过审核，默认 true 通过审核
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
    func passComment(
        ids: [Int],
        isPass: Bool = true
    ) async -> String? {
        do {
            let ret = try await CommentService.updateCommentPass(ids: ids, isPass: isPass)
            if ret.data == true {
                
                // 修改评论状态
                let set = Set(ids)
                for i in 0..<comments.count {
                    if (set.contains(comments[i].commentId)) {
                        var comment = comments[i]
                        comment.isPass = isPass
                        withAnimation {
                            comments[i] = comment
                        }
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
