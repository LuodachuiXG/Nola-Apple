//
//  FileService.swift
//  Nola
//
//  Created by loac on 04/06/2025.
//

import Foundation


/// 文件相关接口
struct FileService {
    
    /// 获取所有存储策略
    static func getAllFileMode() async throws -> ApiResponse<[FileMode]> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/file/mode",
            method: .get
        )
    }
    
    /// 设置腾讯云对象存储
    /// - Parameters:
    ///   - oss: 腾讯云对象存储实体
    static func setTencentOSS(
        oss: TencenOSS
    ) async throws -> ApiResponse<Tag> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/file/mode/tencent_cos",
            method: .post,
            parameters: [
                "secretId": oss.scretId,
                "secretKey": oss.scretKey,
                "region": oss.region,
                "bucket": oss.bucket,
                "https": oss.https,
                "path": oss.path
            ]
        )
    }
    
    /// 获取腾讯云对象存储
    /// - Parameters:
    /// - Returns: 如果还未设置过腾讯云对象存储，则返回 nil
    static func getTencentOSS() async throws -> ApiResponse<TencenOSS?> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/file/mode/tencent_cos",
            method: .get
        )
    }
    
    /// 删除腾讯云对象存储策略。
    /// 删除前需要先删除当前策略下所有文件。
    static func deleteTencentOSS() async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/file/mode/tencent_cos",
            method: .delete
        )
    }
    
    
    /// 添加文件组
    /// - Parameters:
    ///   - displayName: 文件组名
    ///   - path: 文件组路径（在同一存储策略下唯一，当前文件组下的文件都将存储在该路径下）
    ///   - storageMode: 存储策略
    static func addFileGroup(
        displayName: String,
        path: String,
        storageMode: FileMode
    ) async throws -> ApiResponse<FileGroup> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/file/group",
            method: .post,
            parameters: [
                "displayName": displayName,
                "path": path,
                "storageMode": storageMode
            ]
        )
    }
    
    /// 删除文件组
    /// - Parameters:
    ///   - fileGroupId: 文件组 ID
    static func deleteFileGroup(
        fileGroupId: Int64
    ) async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/file/group/\(fileGroupId)",
            method: .delete
        )
    }
    
    /// 修改文件组
    /// - Parameters:
    ///   - fileGroupId: 文件组 ID
    ///   - displayName: 文件组名
    static func updateFileGroup(
        fileGroupId: Int64,
        displayName: String
    ) async throws -> ApiResponse<Bool> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/file/group",
            method: .put,
            parameters: [
                "fileGroupId": fileGroupId,
                "displayName": displayName
            ]
        )
    }
    
    /// 获取文件组
    /// - Parameters:
    ///   - storageMode: 存储策略（为 nil 时获取所有策略下的文件组）
    static func updateFileGroup(
        storageMode: FileMode?
    ) async throws -> ApiResponse<[FileGroup]> {
        var url = "/admin/file/group"
        
        if let mode = storageMode {
            url += "?fileStorageMode=\(mode)"
        }
        
        return try await NetworkManager.shared.request(
            endpoint: url,
            method: .get
        )
    }
    
    /// 上传文件
    /// - Parameters:
    ///   - displayName: 文件组名
    ///   - path: 文件组路径（在同一存储策略下唯一，当前文件组下的文件都将存储在该路径下）
    ///   - storageMode: 存储策略
    static func uploadFile(
        displayName: String,
        path: String,
        storageMode: FileMode
    ) async throws -> ApiResponse<NolaFile> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/file/group",
            method: .post,
            parameters: [
                "displayName": displayName,
                "path": path,
                "storageMode": storageMode
            ]
        )
    }
    
    /// 添加上传文件记录
    /// - Parameters:
    ///   - name: 文件名（含后缀）
    ///   - size: 文件大小（字节 Bytes）
    ///   - storageMode: 存储策略（为 nil 默认本地存储 LOCAL）
    ///   - fileGroupId: 文件组 ID（为 nil 默认不分组）
    static func addUploadFile(
        name: String,
        size: Int64,
        storageMode: FileMode?,
        fileGroupId: Int64?
    ) async throws -> ApiResponse<NolaFile> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/file/record",
            method: .post,
            parameters: [
                "name": name,
                "size": size,
                "storageMode": storageMode,
                "fileGroupId": fileGroupId
            ]
        )
    }
    
    /// 根据文件 ID 删除文件
    /// - Parameters:
    ///   - ids: 要删除的文件 ID 数组
    static func deleteFileByIds(
        ids: [Int64]
    ) async throws -> ApiResponse<[Int64]> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/file",
            method: .delete,
            array: ids
        )
    }
    
    /// 移动文件
    /// 将文件从一个文件组移动到另一个文件组
    /// - Parameters:
    ///   - fileIds: 待移动的文件 ID 数组
    ///   - newFileGroupId: 新的文件组 ID（为 nil 即移动到根目录）
    static func moveFile(
        fileIds: Int64,
        to newFileGroupId: Int64?
    ) async throws -> ApiResponse<[Int64]> {
        return try await NetworkManager.shared.request(
            endpoint: "/admin/file",
            method: .put,
            parameters: [
                "fileIds": fileIds,
                "newFileGroupId": newFileGroupId
            ]
        )
    }
    
    
}
