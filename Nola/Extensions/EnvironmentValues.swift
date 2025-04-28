//
//  EnvironmentValues.swift
//  Nola
//
//  Created by loac on 25/04/2025.
//

import Foundation
import SwiftUI

/// 自定义环境值
extension EnvironmentValues {
    
    var storeManager: StoreManager {
        get { self[StoreManagerKey.self] }
        set { self[StoreManagerKey.self] = newValue }
    }
}
