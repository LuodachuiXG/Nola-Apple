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
                title: "文章", icon: "book", destination: PostView(),
                count: contentVM.blogOverview?.count.post
            ),
            ModuleNavData(
                title: "标签", icon: "tag", destination: DetailView(title: "标签"),
                count: contentVM.blogOverview?.count.tag
            ),
            ModuleNavData(
                title: "分类", icon: "books.vertical",  destination: DetailView(title: "分类"),
                count: contentVM.blogOverview?.count.category
            ),
            ModuleNavData(
                title: "评论", icon: "message", destination: DetailView(title: "评论"),
                count: contentVM.blogOverview?.count.comment
            ),
            ModuleNavData(
                title: "日常", icon: "leaf", destination: DetailView(title: "日常"),
                count: contentVM.blogOverview?.count.diary
            ),
            ModuleNavData(
                title: "附件", icon: "tray.full", destination: DetailView(title: "附件"),
                count: contentVM.blogOverview?.count.file
            ),
            ModuleNavData(
                title: "链接", icon: "at", destination: DetailView(title: "链接"),
                count: contentVM.blogOverview?.count.link
            ),
            ModuleNavData(
                title: "菜单", icon: "line.3.horizontal", destination: DetailView(title: "菜单"),
                count: contentVM.blogOverview?.count.menu
            )
        ]
    }
}
