//
//  DiaryDetailView.swift
//  Nola
//
//  Created by loac on 2025/7/15.
//

import Foundation
import SwiftUI

struct DiaryDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    // 日记（nil 为新增日记）
    @State private var diary: Diary? = nil
    
    @ObservedObject private var vm: DiaryViewModel
    
    // 日记内容
    @State private var content = ""
    
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    // 正在保存日记
    @State private var isSaving = false
    
    // 保存事件
    private var onSave: (_ diary: Diary) -> Void = { _ in }
    
    /// Init
    /// - Parameters:
    ///   - diary: 日记实体（nil 为新增日记）
    ///   - vm: DiaryViewModel
    init(
        diary: Diary? = nil,
        vm: DiaryViewModel,
        onSave: @escaping (_ diary: Diary) -> Void = { _ in }
    ) {
        self._diary = State(initialValue: diary)
        self.content = diary?.content ?? ""
        self.vm = vm
        self.onSave = onSave
    }
    
    var body: some View {
        VStack {
            TextEditor(text: $content)
                .textInputAutocapitalization(.never)
                .padding(5)
                .frame(maxHeight: .infinity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .messageAlert(isPresented: $showAlert, message: alertMessage)
        .toolbar {
            NavigationLink {
                MarkdownView(content: content, isMarkdown: true)
                    .navigationTitle("日常预览")
            } label: {
                Label("预览日志", systemImage: SFSymbol.play.rawValue)
            }
            
            Button {
                saveDiary()
            } label: {
                Text(diary == nil ? "发布" : "保存")
            }
        }
        .loadingAlert(isPresented: $isSaving, message: "正在保存", closableAfter: .seconds(10))
        .navigationTitle(diary == nil ? "新增日记" : "编辑日记")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    
    /// 保存日记
    private func saveDiary() {
        Task {
            isSaving = true
            
            if var diary = diary {
                // 保存日记
                if let err = await vm.updateDiary(diaryId: diary.diaryId, content: content) {
                    // 发生错误
                    alertMessage = err
                    showAlert = true
                } else {
                    // 保存成功
                    diary.content = content
                    onSave(diary)
                    dismiss()
                }
            } else {
                // 新增日记
                let ret = await vm.addDiary(content: content)
                if let err = ret.error {
                    // 发生错误
                    alertMessage = err
                    showAlert = true
                } else if let newDiary = ret.diary {
                    // 新增成功
                    onSave(newDiary)
                    dismiss()
                }
            }
            
            withAnimation {
                isSaving = false
            }
        }
    }
}
