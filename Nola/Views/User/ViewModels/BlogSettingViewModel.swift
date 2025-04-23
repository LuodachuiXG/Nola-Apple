//
//  BlogSettingViewModel.swift
//  Nola
//
//  Created by loac on 24/04/2025.
//

import Foundation

/// 博客设置 ViewModel
class BlogSettingViewModel: ObservableObject {
    
    /// 修改博客信息
    func updateBlogInfo(
        title: String,
        subtitle: String?,
        logo: String?,
        favicon: String?,
        success: @escaping () -> Void,
        failure: @escaping (String) -> Void = { _ in }
    ) {
        Task {
            do {
                _ = try await ConfigService.updateBlogInfo(
                    title: title,
                    subtitle: subtitle,
                    logo: logo,
                    favicon: favicon
                )
                success()
            } catch let error as ApiError {
                failure(error.message)
            } catch {
                failure(error.localizedDescription)
            }
        }
    }
    
    /// 获取博客信息
    func getBlogInfo(
        success: @escaping (BlogInfo) -> Void,
        failure: @escaping (String) -> Void
    ) {
        Task {
            do {
                let res = try await ConfigService.getBlogInfo()
                if let info = res.data {
                    success(info)
                } else {
                    failure("获取博客信息失败")
                }
            } catch let error as ApiError {
                failure(error.message)
            } catch {
                failure(error.localizedDescription)
            }
        }
    }
    
    /// 修改备案信息
    func updateIcp(
        icp: String?,
        `public`: String?,
        success: @escaping () -> Void,
        failure: @escaping (String) -> Void = { _ in }
    ) {
        Task {
            do {
                _ = try await ConfigService.updateIcp(icp: icp, public: `public`)
                success()
            } catch let error as ApiError {
                failure(error.message)
            } catch {
                failure(error.localizedDescription)
            }
        }
    }
    
    /// 获取备案信息
    func getIcp(
        success: @escaping (ICP) -> Void,
        failure: @escaping (String) -> Void
    ) {
        Task {
            do {
                let res = try await ConfigService.getIcp()
                if let icp = res.data {
                    success(icp)
                } else {
                    // 备案信息如果没有设置，默认返回的 data 为 null
                    success(ICP(icp: nil, public: nil))
                }
            } catch let error as ApiError {
                failure(error.message)
            } catch {
                failure(error.localizedDescription)
            }
        }
    }
}
