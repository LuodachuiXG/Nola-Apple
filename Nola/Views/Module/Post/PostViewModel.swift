//
//  PostViewModel.swift
//  Nola
//
//  Created by loac on 19/05/2025.
//

import Foundation
import SwiftUI

@MainActor
final class PostViewModel: ObservableObject {
    
    @Published var posts: [Post] = []
    @Published var categories: [Category] = []
    @Published var tags: [Tag] = []
    
    /// 获取文章
    /// - returns: 返回失败信息（如果失败），成功返回 nil
    func getPosts() async -> String? {
        do {
            let pager = try await PostService.getPosts(page: 1, size: 20).data
            if let ps = pager?.data {
                withAnimation {
                    posts = ps
                }
            }
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        
        return nil
    }
    
    
    /// 获取分类
    /// - returns: 返回失败信息（如果失败），成功返回 nil
    func getCategories() async -> String? {
        do {
            let pager = try await CategoryService.getCategories().data
            if let data = pager?.data {
                categories = data
            }
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        
        return nil
    }
    
    /// 获取标签
    /// - returns: 返回失败信息（如果失败），成功返回 nil
    func getTags() async -> String? {
        do {
            let pager = try await TagService.getTags().data
            if let data = pager?.data {
                tags = data
            }
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        
        return nil
    }
    
    
    /// 更新文章
    /// - Parameters:
    ///   - postId: 文章 ID
    ///   - title: 文章标题
    ///   - autoGenerateExcerpt: 是否自动生成摘要（默认 false）
    ///   - excerpt: 文章摘要
    ///   - slug: 文章别名
    ///   - allowComment: 是否允许评论
    ///   - status: 文章状态（不能设为 DELETE，DELETE 请调用专门的删除文章接口）
    ///   - visible: 文章可见性
    ///   - categoryId: 分类 ID
    ///   - tagIds: 标签 ID 数组
    ///   - cover: 文章封面
    ///   - pinned: 是否置顶（默认 false）
    ///   - encrypted: 文章是否加密（为 true 时需要提供 password，为 null 保持当前状态不变，为 false 删除密码）
    ///   - password: 文章密码
    /// - returns: 返回失败信息（如果失败），成功返回 nil
    func updatePost(
        postId: Int,
        title: String,
        autoGenerateExcerpt: Bool?,
        excerpt: String?,
        slug: String,
        allowComment: Bool,
        status: PostStatus,
        visible: PostVisible,
        categoryId: Int?,
        tagIds: [Int]?,
        cover: String?,
        pinned: Bool?,
        encrypted: Bool?,
        password: String?
    ) async -> String? {
        do {
            let _ = try await PostService.updatePost(
                postId: postId,
                title: title,
                autoGenerateExcerpt: autoGenerateExcerpt,
                excerpt: excerpt,
                slug: slug,
                allowComment: allowComment,
                status: status,
                visible: visible,
                categoryId: categoryId,
                tagIds: tagIds,
                cover: cover,
                pinned: pinned,
                encrypted: encrypted,
                password: password
            )
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        
        return nil
    }
    
    /// 回收文章
    /// - Parameters:
    ///   - ids: 文章 ID 数组
    /// - returns: 返回失败信息（如果失败），成功返回 nil
    func recyclePost(
        ids: [Int]
    ) async -> String? {
        do {
            let _ = try await PostService.recyclePost(ids: ids)
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        
        return nil
    }
    
    /// 恢复文章
    /// - Parameters:
    ///   - ids: 文章 ID 数组
    ///   - status: 文章状态（不能为 DELETE）
    func restorePost(
        ids: [Int],
        status: PostStatus
    ) async -> String? {
        do {
            let _ = try await PostService.restorePost(ids: ids, status: status)
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        
        return nil
    }
    
    
    /// 彻底删除文章
    /// 只能删除处于 DELETE 状态（回收站）的文章
    /// - Parameters:
    ///   - ids: 文章 ID 数组
    func deletePost(
        ids: [Int],
    ) async -> String? {
        do {
            let _ = try await PostService.deletePost(ids: ids)
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        return nil
    }
    
    
    /// 获取文章正文
    /// 此接口只能用于获取文章已经发布的正文。
    /// - Parameters:
    ///   - id: 文章 ID
    func getPostContent(
        id: Int,
    ) async -> (content: PostContent?, error: String?) {
        do {
            let ret = try await PostService.getPostContent(id: id)
            if let postContent = ret.data {
                return (postContent, nil)
            }
        } catch let err as ApiError {
            return (nil, err.message)
        } catch {
            return (nil, error.localizedDescription)
        }
        return (nil, nil)
    }
}
