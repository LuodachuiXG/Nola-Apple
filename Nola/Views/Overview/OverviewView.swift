//
//  OverviewView.swift
//  Nola
//
//  Created by loac on 18/03/2025.
//

import SwiftUI

struct OverviewView: View {
    @State private var showSheet = false
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    NavigationLink("详情", value: "detail")
                }
                .navigationTitle("概览")
                .navigationDestination(for: String.self) { str in
                    Text(str).onTapGesture {
                        showSheet.toggle()
                    }
                    .sheet(isPresented: $showSheet) {
                        Text("你好").onTapGesture {
                            showSheet.toggle()
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    OverviewView()
}
