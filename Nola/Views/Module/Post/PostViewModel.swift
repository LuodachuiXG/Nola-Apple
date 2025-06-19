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
    
    @Published var pager: Pager<[Post]>? = nil
    
    // 当前页码
    private var page = 1
    // 每页大小
    private var pageSize = 20
    
    // 是否还有下一页
    var hasNextPage: Bool {
        if let pager = pager {
            page < pager.totalPages
        } else {
            false
        }
    }
    
    /// 重置当前页码到第一页
    /// 用于在应用新的筛选条件前将页码重置。
    func resetPage() {
        page = 1
    }
    
    
    /// 获取文章
    /// - Parameters:
    ///   - loadMore: 是否加载更多（默认 false 即加载第一页，true 增加页码追加下一页文章到 posts 尾部）
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
    func getPosts(
        loadMore: Bool = false,
        status: PostStatus? = nil,
        visible: PostVisible? = nil,
        key: String? = nil,
        sort: PostSort? = nil
    ) async -> String? {
        do {
            if loadMore {
                // 加载下一页
                if hasNextPage {
                    page += 1
                    if let p = try await PostService.getPosts(
                        page: page,
                        size: pageSize,
                        status: status,
                        visible: visible,
                        key: key,
                        sort: sort
                    ).data {
                        self.pager = p
                        if let ps = p.data {
                            withAnimation {
                                posts += ps
                            }
                        }
                    }
                }
            } else {
                // 加载第一页
                page = 1
                if let p = try await PostService.getPosts(
                    page: page,
                    size: pageSize,
                    status: status,
                    visible: visible,
                    key: key,
                    sort: sort
                ).data {
                    pager = p
                    if let ps = p.data {
                        withAnimation {
                            posts = ps
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
    
    /// 根据文章 ID 获取单个文章
    /// - Parameters:
    ///   - id: 文章 ID
    /// - Returns: (文章, 错误信息）
    func getPostById(
        id: Int,
    ) async -> (post: Post?, error: String?) {
        do {
            let ret = try await PostService.getPostById(id: id)
            if let post = ret.data {
                return (post, nil)
            }
        } catch let err as ApiError {
            return (nil, err.message)
        } catch {
            return (nil, error.localizedDescription)
        }
        return (nil, nil)
    }
    
    
    /// 根据一个 Post 更新现有的文章
    /// - Parameters:
    ///   - post: 要更新的文章
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
    func updateExistPost(post: Post) async -> String? {
        // 获取文章
        let (newPost, error) = await getPostById(id: post.postId)
        if let error = error {
            return error
        } else if let p = newPost {
            
            for i in 0..<posts.endIndex {
                if posts[i].postId == p.postId {
                    withAnimation {
                        posts[i] = p
                    }
                    return nil
                }
            }
            
            // for 循环结束了走到这里，证明 posts 中没有当前文章，所以可能是新增的文章，插入 posts 头部
            withAnimation {
                posts.insert(p, at: 0)
            }
        }
        return nil
    }
    
    
    /// 根据一个 Post 删除现有的 Post
    func deleteExistPost(post: Post) {
        withAnimation {
            posts = posts.filter { $0.postId != post.postId }
        }
    }
    
    
    /// 获取分类
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
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
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
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
    
    /// 添加文章
    /// - Parameters:
    ///   - title: 文章标题
    ///   - autoGenerateExcerpt: 是否自动生成摘要（默认 false）
    ///   - excerpt: 文章摘要
    ///   - slug: 文章别名
    ///   - allowComment: 是否允许评论
    ///   - status: 文章状态（不能设为 DELETE，DELETE 请调用专门的删除文章接口）
    ///   - visible: 文章可见性
    ///   - content: 文章内容
    ///   - categoryId: 分类 ID
    ///   - tagIds: 标签 ID 数组
    ///   - cover: 文章封面
    ///   - pinned: 是否置顶（默认 false）
    ///   - password: 文章密码
    /// - Returns: (文章, 错误信息）
    func addPost(
        title: String,
        autoGenerateExcerpt: Bool?,
        excerpt: String?,
        slug: String,
        allowComment: Bool,
        status: PostStatus,
        visible: PostVisible,
        content: String,
        categoryId: Int?,
        tagIds: [Int]?,
        cover: String?,
        pinned: Bool?,
        password: String?
    ) async -> (post: Post?, error: String?) {
        do {
            let ret = try await PostService.addPost(
                title: title,
                autoGenerateExcerpt: autoGenerateExcerpt,
                excerpt: excerpt,
                slug: slug,
                allowComment: allowComment,
                status: status,
                visible: visible,
                content: content,
                categoryId: categoryId,
                tagIds: tagIds,
                cover: cover,
                pinned: pinned,
                password: password
            )
            if let post = ret.data {
                return (post, nil)
            }
        } catch let err as ApiError {
            return (nil, err.message)
        } catch {
            return (nil, error.localizedDescription)
        }
        
        return (nil, nil)
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
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
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
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
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
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
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
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
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
    /// - Returns: (文章内容, 错误信息）
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
    
    /// 保存文章内容
    /// - Parameters:
    ///   - id: 文章 ID
    ///   - content: 文章内容（Markdown / PlainText）
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
    func updatePostContent(
        id: Int,
        content: String
    ) async -> String? {
        do {
            let _ = try await PostService.updatePostContent(id: id, content: content)
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        
        return nil
    }
}
