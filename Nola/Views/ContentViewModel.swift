//
//  ContentViewModel.swift
//  Nola
//
//  Created by loac on 14/04/2025.
//

import Foundation
import SwiftUI

@MainActor
class ContentViewModel: ObservableObject {

    @Published var blogOverview: BlogOverview?

    /// 刷新博客概览数据
    /// - Returns: 如果发生错误返回错误信息，成功返回 nil
    func refreshOverview() async -> String? {
        do {
            let res = try await OverviewService.getBlogOverview()
            if let data = res.data {
                withAnimation {
                    blogOverview = data
                }
            } else {
                return "未知错误"
            }
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        
        return nil
    }
    

    /// 清除博客概览数据
    func clearOverview() {
        blogOverview = nil
    }


    /// 判断之前登录的用户是否还在登录状态
    /// - Parameters:
    ///   - onValid: 登录有效回调
    ///   - onExpired: 登录过期回调
    func userLoginValidate(
        onValid: @escaping () -> Void = {},
        onExpired: @escaping () -> Void = {}
    ) {
        Task {
            do {
                let res = try await AdminService.validate()
                if res.data == true {
                    // 登录有效
                    onValid()
                    return
                }
                onExpired()
            } catch {
                // 登录过期
                onExpired()
            }
        }
    }
    
    /// 修改现存的概览分类
    /// - Parameters:
    ///   - category: 分类实体
    func updateExistOverviewCategory(_ category: Category) {
        if var ov = blogOverview {
            var categories = ov.categories
            
            for i in 0..<categories.endIndex {
                if categories[i].categoryId == category.categoryId {
                    categories[i] = category
                    break
                }
            }
            ov.categories = categories
            
            withAnimation {
                blogOverview = ov
            }
        }
    }
    
    /// 修改现存的概览标签
    /// - Parameters:
    ///   - tag: 标签实体
    func updateExistOverviewTag(_ tag: Tag) {
        if var ov = blogOverview {
            var tags = ov.tags
            
            for i in 0..<tags.endIndex {
                if tags[i].tagId == tag.tagId {
                    tags[i] = tag
                    break
                }
            }
            ov.tags = tags
            
            withAnimation {
                blogOverview = ov
            }
        }
    }
    
    /// 删除现存的概览分类
    /// - Parameters:
    ///   - category: 分类实体
    func deleteExistOverviewCategory(_ category: Category) {
        if var ov = blogOverview {
            ov.categories = ov.categories.filter { $0.categoryId != category.categoryId }
            withAnimation {
                blogOverview = ov
            }
        }
    }
    
    /// 删除现存的概览标签
    /// - Parameters:
    ///   - tag: 标签实体
    func deleteExistOverviewTag(_ tag: Tag) {
        if var ov = blogOverview {
            ov.tags = ov.tags.filter { $0.tagId != tag.tagId }
            withAnimation {
                blogOverview = ov
            }
        }
    }
}
