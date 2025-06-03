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
}
