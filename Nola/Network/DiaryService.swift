//
//  DiaryService.swift
//  Nola
//
//  Created by loac on 2025/7/14.
//

import Foundation

/// 日记相关接口
struct DiaryService {
    
    /// 添加日记
    /// - Parameters:
    ///   - content: 日记内容
    static func addDiary(
        content: String
    ) async throws -> ApiResponse<Diary> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/diary",
            method: .post,
            parameters: [
                "content": content
            ]
        )
    }
    
    /// 删除日记
    /// - Parameters:
    ///   - ids: 日记 ID 数组
    static func deleteDiaries(
        ids: [Int]
    ) async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/diary",
            method: .delete,
            array: ids
        )
    }
    
    /// 修改日记
    /// - Parameters:
    ///   - diaryId: 日记 ID
    ///   - content: 日记内容
    static func updateDiary(
        diaryId: Int,
        content: String
    ) async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/diary",
            method: .put,
            parameters: [
                "diaryId": diaryId,
                "content": content
            ]
        )
    }
    
    /// 获取日记
    /// - Parameters:
    ///   - page: 当前页（留 0 获取全部）
    ///   - size: 每页条数
    ///   - sort: 排序方式（默认创建时间降序，可选）
    static func getDiaries(
        page: Int = 0,
        size: Int = 0,
        sort: DiarySort? = nil
    ) async throws -> ApiResponse<Pager<[Diary]>> {
        var query = "?page=\(page)&size=\(size)"
        if let sort {
            query += "&sort=\(sort)"
        }
        
        return try await NetworkManager.shared.request(
            endpoint: "/admin/diary\(query)",
            method: .get
        )
    }
}
