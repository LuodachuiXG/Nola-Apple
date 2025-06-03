//
//  CategoryService.swift
//  Nola
//
//  Created by loac on 03/06/2025.
//

import Foundation

/// 分类相关接口
struct CategoryService {
    
    /// 分页获取分类
    /// - Parameters:
    ///   - page: 当前页（留 nil 或 0 获取全部）
    ///   - size: 每页条数
    static func getCategories(
        page: Int = 0,
        size: Int = 0
    ) async throws -> ApiResponse<Pager<[Category]>> {
        let query = "?page=\(page)&size=\(size)"
        return try await NetworkManager.shared.request(
            endpoint: "/admin/category\(query)",
            method: .get
        )
    }
    
    /// 根据分类 ID 获取分类
    /// - Parameters:
    ///   - categoryId: 分类 ID
    static func getCategoryById(
        categoryId: Int
    ) async throws -> ApiResponse<Category> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/category/\(categoryId)",
            method: .get
        )
    }
    
    /// 添加分类
    /// - Parameters:
    ///   - displayName: 分类名
    ///   - slug: 分类别名
    ///   - cover: 分类封面（可选）
    ///   - unifiedCover: 是否统一封面（可选，默认 false）
    /// - Returns: 添加成功返回分类实体类
    static func addCategory(
        displayName: String,
        slug: String,
        cover: String?,
        unifiedCover: String?
    ) async throws -> ApiResponse<Category> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/category",
            method: .post,
            parameters: [
                "displayName": displayName,
                "slug": slug,
                "cover": cover,
                "unifiedCover": unifiedCover
            ]
        )
    }
    
    /// 修改分类
    /// - Parameters:
    ///   - categoryId: 分类 ID
    ///   - displayName: 分类名
    ///   - slug: 分类别名
    ///   - cover: 分类封面（可选）
    ///   - unifiedCover: 是否统一封面（可选，默认 false）
    static func updateCategory(
        categoryId: Int,
        displayName: String,
        slug: String,
        cover: String?,
        unifiedCover: String?
    ) async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/category",
            method: .put,
            parameters: [
                "categoryId": categoryId,
                "displayName": displayName,
                "slug": slug,
                "cover": cover,
                "unifiedCover": unifiedCover
            ]
        )
    }
    
    /// 根据分类 ID 删除分类
    /// - Parameters:
    ///   - ids: 分类 ID 数组
    static func deleteCategoriesById(
        ids: [Int]
    ) async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/category",
            method: .delete,
            array: ids
        )
    }
    
    /// 根据分类别名删除分类
    /// - Parameters:
    ///   - slugs: 分类别名数组
    static func deleteCategoriesBySlug(
        slugs: [String]
    ) async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/category/slug",
            method: .delete,
            array: slugs
        )
    }
}
