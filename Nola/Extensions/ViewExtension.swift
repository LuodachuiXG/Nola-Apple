//
//  ViewExtension.swift
//  Nola
//
//  Created by loac on 2025/7/11.
//

import Foundation
import UIKit
import SwiftUI

extension View {
    func snapshot() -> UIImage {
        let controller = UIHostingController(rootView: self.ignoresSafeArea(.all))
        let view = controller.view
        
        let targetSize = controller.sizeThatFits(in: UIScreen().bounds.size)
        view?.bounds = CGRect(origin: .zero, size: targetSize)
        view?.backgroundColor = .clear
        
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        return renderer.image { _ in
            view?.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
        }
    }
}
