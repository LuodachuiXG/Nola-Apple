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
    private var pageSize = 0
    
    private var pager: Pager<[Comment]>? = nil
    
    
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
    
    /// 删除分类
    /// - Parameters:
    ///   - category: 要删除的分类
//    func deleteCategory(category: Category) async -> String? {
//        do {
//            let _ = try await CategoryService.deleteCategoriesById(ids: [category.categoryId])
//        } catch let err as ApiError {
//            return err.message
//        } catch {
//            return error.localizedDescription
//        }
//        
//        return nil
//    }
    
    /// 更新现有的分类
    /// - Parameters:
    ///   - category: 分类实体
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
//    func updateExistCategory(category: Category) async -> String? {
//        // 先获取当前分类
//        let (newCategory, error) = await getCategoryById(categoryId: category.categoryId)
//        if let error = error {
//            return error
//        } else if let c = newCategory {
//            for i in 0..<categories.endIndex {
//                if categories[i].categoryId == c.categoryId {
//                    withAnimation {
//                        categories[i] = c
//                    }
//                    return nil
//                }
//            }
//            
//            // for 循环结束了走到这里，证明 categories 中没有当前分类，所以可能是新增的分类，插入 categories 头部
//            withAnimation {
//                categories.insert(c, at: 0)
//            }
//        }
//        return nil
//    }
    
    /// 删除现有的分类
    /// - Parameters:
    ///   - category: 要删除的分类实体
//    func deleteExistCategory(category: Category) {
//        withAnimation {
//            categories = categories.filter { $0.categoryId != category.categoryId }
//        }
//    }
    
    
    /// 获取所有评论
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
    func getComments() async -> String? {
        do {
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
    
    /// 修改分类
    /// - Parameters:
    ///   - category: 更新的分类
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
//    func updateCategory(category: Category) async -> String? {
//        do {
//            let _ = try await CategoryService.updateCategory(
//                categoryId: category.categoryId,
//                displayName: category.displayName,
//                slug: category.slug,
//                cover: category.cover,
//                unifiedCover: category.unifiedCover
//            )
//        } catch let err as ApiError {
//            return err.message
//        } catch {
//            return error.localizedDescription
//        }
//        
//        return nil
//    }
    
}
