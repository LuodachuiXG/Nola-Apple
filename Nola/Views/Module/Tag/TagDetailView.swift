//
//  TagDetailView.swift
//  Nola
//
//  Created by loac on 18/06/2025.
//

import Foundation
import SwiftUI


/// 标签详情 View
struct TagDetailView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var tag: Tag
    
    @ObservedObject var vm: TagViewModel
    
    @State private var originalTitle = ""
    
    // 标签颜色
    @State private var tagColor: Color = Color.clear
    
    // 当前是否是添加标签模式
    @State private var isAddTag = false
    
    // 标记当前是否自动生成摘要（用于在新建标签时使用）
    @State private var autoGenerateSlug = true
    
    // 消息弹窗
    @State private var alertMsg = ""
    @State private var showAlert = false
    
    // 显示删除弹窗
    @State private var showDeleteAlert = false
    
    // 保存/添加完成事件，回调新的标签（新标签实体, 是否是删除操作）
    private var onSave: (_ tag: Tag, _ delete: Bool) -> Void = { _, _ in }
    
    
    /// 初始化函数
    /// - Parameters:
    ///   - tag: 标签实体，nil 为新建标签，非 nil 为编辑标签
    init(tag: Tag?, viewModel: TagViewModel, onSave: @escaping (_ tag: Tag, _ delete: Bool) -> Void) {
        self.onSave = onSave
        if let tag = tag {
            originalTitle = tag.displayName
            if let color = tag.color {
                self.tagColor = Color(hex: color)
            }
            self.tag = tag
        } else {
            isAddTag = true
            originalTitle = "添加标签"
            self.tag = Tag(tagId: -1, displayName: "", slug: "", postCount: 0)
        }
        self.vm = viewModel
    }
    
    var body: some View {
        List {
            Section("基本信息") {
                ListItem(label: "标签名") {
                    TextField("标签名", text: $tag.displayName)
                        .onChange(of: tag.displayName) { oldValue, newValue in
                            if (isAddTag && autoGenerateSlug) {
                                tag.slug = newValue.toPinyin()
                            }
                        }
                }
                ListItem(label: "标签别名") {
                    TextField(
                        "标签别名",
                        text: Binding(
                            get: {
                                tag.slug
                            },
                            set: { newValue in
                                tag.slug = newValue
                                // 手动编辑别名后将自动生成别名设为 false
                                autoGenerateSlug = false
                            }
                        )
                    )
                }
                .contextMenu {
                    Button("自动生成别名", systemImage: SFSymbol.quote.rawValue) {
                        tag.slug = tag.displayName.toPinyin()
                    }
                    
                }
                ListItem(label: "标签颜色") {
                    ColorPicker("标签颜色", selection: $tagColor, supportsOpacity: false)
                        .labelsHidden()
                }
            }
            
            
            if !isAddTag {
                // 添加标签时不显示静态信息
                Section("静态信息") {
                    ListItem(label: "文章数量") {
                        Text(String(tag.postCount))
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showDeleteAlert = true
                    } label: {
                        Text("删除标签")
                    }
                    
                }
            }
        }
        .messageAlert(isPresented: $showAlert, message: alertMsg)
        .confirmAlert(isPresented: $showDeleteAlert, message: "确定要删除当前标签吗") {
            deleteTag()
        }
        .navigationTitle(originalTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button(isAddTag ? "添加" : "保存") {
                saveTag()
            }
        }
    }
    
    /// 保存 / 新建标签
    private func saveTag() {
        Task {
            tag.color = tagColor == .clear ? nil : tagColor.toHex()
            if isAddTag {
                // 当前是添加标签
                let ret = await vm.addTag(tag: tag)
                if let err = ret.error {
                    // 发生错误
                    alertMsg = err
                    showAlert = true
                } else if let tag = ret.tag {
                    // 添加完成
                    dismiss()
                    onSave(tag, false)
                }
            } else {
                // 当前是编辑标签
                if let err = await vm.updateTag(tag: tag) {
                    // 失败
                    alertMsg = err
                    showAlert = true
                } else {
                    // 保存成功
                    dismiss()
                    onSave(tag, false)
                }
            }
        }
    }
    
    /// 删除标签
    private func deleteTag() {
        Task {
            if let err = await vm.deleteTag(tag: tag) {
                alertMsg = err
                showAlert = true
            } else {
                // 删除成功
                dismiss()
                onSave(tag, true)
            }
        }
    }
}
