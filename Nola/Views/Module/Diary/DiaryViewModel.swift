//
//  DiaryViewModel.swift
//  Nola
//
//  Created by loac on 2025/7/15.
//

import Foundation
import SwiftUI


@MainActor
final class DiaryViewModel: ObservableObject {
    
    @Published var diaries: [Diary] = []
    
    // 当前页码（0 获取所有）
    private var page = 0
    // 每页大小
    private var pageSize = 20
    
    var pager: Pager<[Diary]>? = nil
    
    // 是否还有下一页
    var hasNextPage: Bool {
        if let pager = pager {
            page < pager.totalPages
        } else {
            false
        }
    }
    
    /// 添加日记
    /// - Parameters:
    ///   - content: 日记内容
    /// - Returns: (日记, 错误信息）
    func addDiary(
        content: String
    ) async -> (diary: Diary?, error: String?) {
        do {
            let ret = try await DiaryService.addDiary(
                content: content
            )
            if let diary = ret.data {
                return (diary, nil)
            }
        } catch let err as ApiError {
            return (nil, err.message)
        } catch {
            return (nil, error.localizedDescription)
        }
        
        return (nil, nil)
    }
    
    /// 添加日记到本地变量
    /// - Parameters:
    ///   - diary: 日记实体
    ///   - at: 插入位置，默认 0
    func addExistDiary(
        diary: Diary,
        at index: Int = 0
    ) {
        withAnimation {
            diaries.insert(diary, at: index)
        }
    }
    
    /// 删除日记
    /// - Parameters:
    ///   - id: 日记 ID
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
    func deleteDiary(
        id: Int
    ) async -> String? {
        do {
            let ret = try await DiaryService.deleteDiaries(ids: [id])
            if ret.data == true {
                // 删除完成，更新现有日记
                deleteExistDiary(id: id)
            }
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        
        return nil
    }
    
    /// 删除现有的日记
    /// - Parameters:
    ///   - id: 要删除的日记 ID
    func deleteExistDiary(id: Int) {
        withAnimation {
            diaries = diaries.filter { $0.diaryId != id }
        }
    }
    
    /// 更新日记
    /// - Parameters:
    ///   - diaryId:  日记 ID
    ///   - content: 日记内容
    func updateDiary(
        diaryId: Int,
        content: String
    ) async -> String? {
        do {
            let _ = try await DiaryService.updateDiary(
                diaryId: diaryId,
                content: content
            )
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        
        return nil
    }
    
    /// 更新现有的日记
    /// - Parameters:
    ///   - comment: 日记实体
    func updateExistDiary(diary: Diary) {
        // 直接找到对应日记并替换
        for i in 0..<diaries.count {
            if diaries[i].diaryId == diary.diaryId {
                withAnimation {
                    diaries[i] = diary
                }
                return
            }
        }
        
        // for 循环结束了走到这里，当前是新增，插入头部
        withAnimation {
            diaries.insert(diary, at: 0)
        }
    }
    
    
    /// 获取所有日记
    /// - Parameters:
    ///   - sort: 日记排序（默认 nil 默认排序）
    ///   - loadMore: 是否加载更多（默认 false 即加载第一页，true 增加页码追加下一页到尾部）
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
    func getDiaries(
        sort: DiarySort? = nil,
        loadMore: Bool = false
    ) async -> String? {
        do {
            if loadMore {
                // 加载下一页
                if hasNextPage {
                    page += 1
                    if let d = try await DiaryService.getDiaries(
                        page: page,
                        size: pageSize,
                        sort: sort
                    ).data {
                        self.pager = d
                        if let ds = d.data {
                            withAnimation {
                                diaries += ds
                            }
                        }
                    }
                }
            } else {
                // 加载第一页
                page = 1
                if let pager = try await DiaryService.getDiaries(
                    page: page,
                    size: pageSize,
                    sort: sort
                ).data {
                    self.pager = pager
                    if let ds = pager.data {
                        withAnimation {
                            self.diaries = ds
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
}
