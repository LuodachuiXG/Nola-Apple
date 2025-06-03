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
    
}
