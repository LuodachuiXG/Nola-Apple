//
//  PostViewModel.swift
//  Nola
//
//  Created by loac on 19/05/2025.
//

import Foundation

@MainActor
final class PostViewModel: ObservableObject {
    
    @Published var posts: [Post] = []
    @Published var isLoading = false
    
    /// 获取文章
    func getPosts(
        failure: @escaping (String) -> Void = { _ in }
    ) {
        isLoading = true
        Task {
            do {
                let pager = try await PostService.getPosts(page: 1, size: 20).data
                if let ps = pager?.data {
                    posts = ps
                }
                isLoading = false
            } catch let err as ApiError {
                failure(err.message)
                print("APIERROR: \(err.message)")
                isLoading = false
            } catch {
                failure(error.localizedDescription)
                print("IOSERROR: \(error.localizedDescription)")
                isLoading = false
            }
        }
    }
}
