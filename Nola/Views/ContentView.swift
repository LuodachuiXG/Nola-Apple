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
                OverviewView()
            }
        
            
            Tab("模块", systemImage: "xmark.triangle.circle.square") {
                ModuleView()
            }
            
            Tab("用户", systemImage: "person") {
                UserView()
            }
        }
    }
}


#Preview {
    ContentView()
}
