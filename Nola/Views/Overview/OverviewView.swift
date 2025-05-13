//
//  OverviewView.swift
//  Nola
//
//  Created by loac on 18/03/2025.
//

import SwiftUI

/// 概览页面
struct OverviewView: View {
    
    @ObservedObject var contentVM: ContentViewModel
    
    private let gridCols = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView([.vertical]) {
                VStack(alignment: .leading, spacing: .defaultSpacing) {
                    // 浏览最多的文章卡片
                    if let post = contentVM.blogOverview?.mostViewedPost {
                        Text("浏览量最多")
                            .font(.title)
                            .fontWeight(.semibold)
                        MostViewedPostCard(post: post)
                    }
                    
                    LazyVGrid(columns: gridCols) {
                        // 博客已创建时间
                        if let creatTime = contentVM.blogOverview?.createDate {
                            BlogCreateTimeCard(createTime: creatTime)
                                .aspectRatio(1, contentMode: .fill)
                        }
                        
                        // 博客已创建时间
                        if let creatTime = contentVM.blogOverview?.createDate {
                            BlogCreateTimeCard(createTime: creatTime)
                                .aspectRatio(1, contentMode: .fill)
                        }
                    }
                                    
                    Spacer()
                }.padding()
            }
        }
    }
}

#Preview {
    OverviewView(contentVM: ContentViewModel())
}
