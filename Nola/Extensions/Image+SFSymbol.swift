//
//  Image+SFSymbol.swift
//  Nola
//
//  Created by loac on 19/05/2025.
//

import Foundation
import SwiftUI

/// Image 图片组件 Extension
extension Image {
    
    /// 通过 SFSymbol 枚举类创建 Image
    init(symbol: SFSymbol) {
        self.init(systemName: symbol.rawValue)
    }
}
