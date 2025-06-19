//
//  TagViewModel.swift
//  Nola
//
//  Created by loac on 17/06/2025.
//

import Foundation
import SwiftUI


@MainActor
final class TagViewModel: ObservableObject {
    
    @Published var tags: [Tag] = []
    
    // 当前页码（0 获取所有）
    private var page = 0
    // 每页大小
    private var pageSize = 0
    
    private var pager: Pager<[Tag]>? = nil
    
    
    /// 新增标签
    /// - Parameters:
    ///   - tag: 标签实体
    /// - Returns: (标签实体, 错误信息)
    func addTag(tag: Tag) async -> (tag: Tag?, error: String?) {
        do {
            let ret = try await TagService.addTag(
                displayName: tag.displayName,
                slug: tag.slug,
                color: tag.color
            )
            if let tag = ret.data {
                return (tag, nil)
            }
        } catch let err as ApiError {
            return (nil, err.message)
        } catch {
            return (nil, error.localizedDescription)
        }
        
        return (nil, "未知错误")
    }
    
    /// 删除标签
    /// - Parameters:
    ///   - tag: 要删除的标签
    func deleteTag(tag: Tag) async -> String? {
        do {
            let _ = try await TagService.deleteTagsById(ids: [tag.tagId])
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        
        return nil
    }
    
    /// 更新现有的标签
    /// - Parameters:
    ///   - tag: 标签实体
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
    func updateExistTag(tag: Tag) async -> String? {
        // 先获取当前标签
        let (newTag, error) = await getTagById(tagId: tag.tagId)
        if let error = error {
            return error
        } else if let t = newTag {
            for i in 0..<tags.endIndex {
                if tags[i].tagId == t.tagId {
                    withAnimation {
                        tags[i] = t
                    }
                    return nil
                }
            }
            
            // for 循环结束了走到这里，证明 tags 中没有当前标签，所以可能是新增的标签，插入 tags 头部
            withAnimation {
                tags.insert(t, at: 0)
            }
        }
        return nil
    }
    
    /// 删除现有的标签
    /// - Parameters:
    ///   - tag: 要删除的标签实体
    func deleteExistTag(tag: Tag) {
        withAnimation {
            tags = tags.filter { $0.tagId != tag.tagId }
        }
    }
    
    
    /// 获取所有标签标签
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
    func getTags() async -> String? {
        do {
            if let pager = try await TagService.getTags(page: page, size: pageSize).data {
                self.pager = pager
                if let tags = pager.data {
                    withAnimation {
                        self.tags = tags
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
    
    /// 根据标签 ID 获取标签
    /// - Parameters:
    ///   - tagId: 标签 ID
    func getTagById(tagId: Int) async -> (tag: Tag?, error: String?) {
        do {
            let ret = try await TagService.getTagById(tagId: tagId)
            if let tag = ret.data {
                return (tag, nil)
            }
        } catch let err as ApiError {
            return (nil, err.message)
        } catch {
            return (nil, error.localizedDescription)
        }
        
        return (nil, "未知错误")
    }
    
    
    /// 修改标签
    /// - Parameters:
    ///   - tag: 更新的标签
    /// - Returns: 返回失败信息（如果失败），成功返回 nil
    func updateTag(tag: Tag) async -> String? {
        do {
            let _ = try await TagService.updateTag(
                tagId: tag.tagId,
                displayName: tag.displayName,
                slug: tag.slug,
                color: tag.color
            )
        } catch let err as ApiError {
            return err.message
        } catch {
            return error.localizedDescription
        }
        
        return nil
    }
    
}
