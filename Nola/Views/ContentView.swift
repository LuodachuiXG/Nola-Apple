//
//  ContentView.swift
//  Nola
//
//  Created by loac on 18/03/2025.
//

import SwiftUI

struct ContentView: View {

    var body: some View {
        TabView {
            Tab("概览", systemImage: "waveform.path.ecg.rectangle") {
                Text("概览")
                    .font(.title)
            }
            
            Tab("模块", systemImage: "xmark.triangle.circle.square") {
                Text("功能")
                    .font(.title)
            }
            
            Tab("用户", systemImage: "person") {
                Text("用户")
                    .font(.title)
            }
        }
    }
}


#Preview {
    ContentView()
}
