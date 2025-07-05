//
//  ModuleView+Destination.swift
//  Nola
//
//  Created by loac on 12/05/2025.
//

import Foundation


extension ModuleView {
    
    // 模块目的地按钮数组
    var destButtons: [ModuleNavData] {
        [
            ModuleNavData(
                title: "文章",
                icon: SFSymbol.post.rawValue,
                destination: .post(postId: nil),
                count: contentVM.blogOverview?.count.post
            ),
            ModuleNavData(
                title: "标签",
                icon: SFSymbol.tag.rawValue,
                destination: .tag,
                count: contentVM.blogOverview?.count.tag
            ),
            ModuleNavData(
                title: "分类",
                icon: SFSymbol.category.rawValue,
                destination: .category,
                count: contentVM.blogOverview?.count.category
            ),
            ModuleNavData(
                title: "评论",
                icon: SFSymbol.comment.rawValue,
                destination: .comment,
                count: contentVM.blogOverview?.count.comment
            ),
            ModuleNavData(
                title: "日常",
                icon: SFSymbol.diary.rawValue,
                destination: .diary,
                count: contentVM.blogOverview?.count.diary
            ),
            ModuleNavData(
                title: "附件",
                icon: SFSymbol.file.rawValue,
                destination: .file,
                count: contentVM.blogOverview?.count.file
            ),
            ModuleNavData(
                title: "链接",
                icon: SFSymbol.link.rawValue,
                destination: .link,
                count: contentVM.blogOverview?.count.link
            ),
            ModuleNavData(
                title: "菜单",
                icon: SFSymbol.menu.rawValue,
                destination: .menu,
                count: contentVM.blogOverview?.count.menu
            )
        ]
    }
}
