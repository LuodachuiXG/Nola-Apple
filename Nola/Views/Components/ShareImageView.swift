//
//  ShareImageView.swift
//  Nola
//
//  Created by loac on 20/06/2025.
//


import Foundation
import SwiftUI
import SDWebImageSwiftUI

/// 可以长按分享的图片组件
struct ShareImageView: View {
    
    let url: URL
    
    // 图片 Data，在加载完成后会赋值到此
    @State private var coverImage: UIImage? = nil
    
    var body: some View {
        AnimatedImage(url: url) {
            VStack(alignment: .center) {
                ProgressView()
            }
            .frame(maxWidth: .infinity)
        }
        
        .resizable()
        // 从网络读取成功
        .onSuccess { image, data, cacheType in
            if coverImage == nil, let data = data, let img = UIImage(data: data) {
                coverImage = img
            }
        }
        // 从本地缓存读取成功
        .onViewUpdate(perform: { imageView, ctx in
            if coverImage == nil, let uiImage = imageView.image {
                coverImage = uiImage
            }
        })
        .aspectRatio(contentMode: .fit)
        .scaledToFit()
        .contextMenu {
            if let img = coverImage {
                ShareLink(
                    item: Image(uiImage: img),
                    preview: SharePreview("图片分享", image: Image(uiImage: img))
                ) {
                    Label("分享/保存图片", systemImage: SFSymbol.save.rawValue)
                }
            }
        }
    }
}
