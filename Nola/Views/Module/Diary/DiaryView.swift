//
//  DiaryView.swift
//  Nola
//
//  Created by loac on 2025/7/14.
//

import Foundation
import SwiftUI

/// 日记 View
struct DiaryView: View {
    
    @Binding var path: NavigationPath
    
    @StateObject private var vm = DiaryViewModel()
    
    @State private var alertMessage = ""
    @State private var showAlert = false
    
    // 要删除的日记 ID
    @State private var deleteDiaryId: Int? = nil
    // 是否显示删除日记弹窗
    @State private var showDeleteDiaryAlert = false
    
    @State private var isLoading = false
    
    // 标记当前是否已经完成第一次刷新
    @State private var firstRefresh = false
    
    // 下拉刷新提示文字
    private var pullUpRefreshText: String {
        if let pager = vm.pager {
            if !vm.hasNextPage {
                "没有更多日记了"
            } else {
                "加载中 (\(pager.page) / \(pager.totalPages) 页)"
            }
        } else {
            "加载中"
        }
    }
    
    
    // MARK: - 日记选项
    @State private var sortFilter: DiarySort? = nil
    // 当前是否在筛选状态
    private var isFilter: Bool {
        sortFilter != nil
    }
    // MARK: - 日记选项
    
    var body: some View {
        ZStack {
            if !firstRefresh {
                ProgressView()
            }
            
            ScrollView(showsIndicators: true) {
                LazyVStack(alignment:.leading, spacing: .defaultSpacing) {
                    if isFilter {
                        // 当前日记在筛选状态，显示筛选指示器
                        DiaryFilterIndicator(
                            sort: $sortFilter.animation()
                        ) {
                            // 刷新日记
                            Task {
                                await refreshDiary()
                            }
                        }
                    }
                    
                    ForEach(vm.diaries, id: \.diaryId) { diary in
                        NavigationLink(value: diary) {
                            DiaryCard(diary: diary)
                                .tint(.primary)
                                .contextMenu {
                                    // 删除日记
                                    Button(role: .destructive) {
                                        deleteDiaryId = diary.diaryId
                                        showDeleteDiaryAlert = true
                                    } label: {
                                        Label("删除日记", systemImage: SFSymbol.trash.rawValue)
                                    }
                                }
                        }
                    }
                    
                    // 完成首次加载前不显示
                    if firstRefresh {
                        HStack {
                            Spacer()
                            if vm.hasNextPage {
                                // 还有下一页时才显示加载图标
                                ProgressView()
                            }
                            Text(pullUpRefreshText)
                                .foregroundStyle(.secondary)
                                .font(.callout)
                                .padding(.vertical, 20)
                                .onAppear {
                                    if !isLoading {
                                        // 加载下一页文章
                                        loadNextPage()
                                    }
                                }
                            Spacer()
                        }
                    }
                }
                .padding(.defaultSpacing)
            }
            .refreshable {
                await refreshDiary()
            }
        }
        .toolbar {
            // 添加日记按钮
            NavigationLink {
                DiaryDetailView(diary: nil, vm: vm) { newDiary in
                    // 日记新增事件
                    vm.addExistDiary(diary: newDiary)
                }
            } label: {
                Label("添加日记", systemImage: SFSymbol.plus.rawValue)
            }
            
            
            Menu {
                // 日记排序
                Menu {
                    Picker("日记排序",  selection: $sortFilter.animation()) {
                        ForEach(DiarySort.allCases, id: \.self) { sort in
                            Text(sort.desc).tag(sort)
                        }
                    }
                    .onChange(of: sortFilter, { _, newValue in
                        // 不处理清空 (newValue == nil) 的情况，因为在其他地方已经处理，防止重复刷新
                        if newValue != nil {
                            // 日记排序筛选，刷新日记
                            Task {
                                await refreshDiary()
                            }
                        }
                    })
                } label: {
                    Text("日记排序")
                }
                
                if isFilter {
                    // 当前处于筛选模式
                    Button {
                        clearFilter()
                    } label: {
                        Label("清除筛选", systemImage: SFSymbol.x.rawValue)
                    }
                }
            } label: {
                Label("日记选项", systemImage: SFSymbol.filter.rawValue)
            }
        }
        .messageAlert(isPresented: $showAlert, message: alertMessage)
        .confirmAlert(isPresented: $showDeleteDiaryAlert, message: "确定要删除日记吗") {
            // 删除日记
            if let id = deleteDiaryId {
                deleteDiary(id: id)
            }
        }
        .navigationTitle("日记")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: Diary.self, destination: { diary in
            // 日记编辑页面
            DiaryDetailView(diary: diary, vm: vm) { newDiary in
                // 日记保存事件
                vm.updateExistDiary(diary: newDiary)
            }
        })
        .task {
            if !firstRefresh && !isLoading {
                await refreshDiary()
            }
        }
    }
    
    
    /// 刷新日志
    private func refreshDiary() async {
        isLoading = true
        if let err = await vm.getDiaries(
            sort: sortFilter
        ) {
            alertMessage = err
            showAlert = true
        }
        firstRefresh = true
        isLoading = false
    }
    
    /// 加载下一页
    private func loadNextPage() {
        isLoading = true
        Task {
            if let err = await vm.getDiaries(
                sort: sortFilter,
                loadMore: true
            ) {
                alertMessage = err
                showAlert = true
            }
            isLoading = false
        }
    }
    
    /// 清除筛选
    private func clearFilter() {
        withAnimation {
            sortFilter = nil
        }
        
        // 刷新日记
        Task {
            await refreshDiary()
        }
    }
    
    /// 删除日记
    private func deleteDiary(id: Int) {
        Task {
            if let err = await vm.deleteDiary(id: id) {
                alertMessage = err
                showAlert = true
            }
        }
    }
}

/// 日记过滤指示器
private struct DiaryFilterIndicator: View {
    // 日记排序
    @Binding var sort: DiarySort?
    
    // 筛选清除事件
    var onClear: () -> Void = {}
    
    var body: some View {
        VStack(alignment: .leading, spacing: .defaultSpacing) {
            if let sort = sort {
                FilterIndicatorContainer(
                    title: "日记排序",
                    content: sort.desc,
                    color: Color(UIColor.systemBlue)
                ) {
                    self.sort = nil
                    onClear()
                }
            }
        }
    }
}



#Preview {
    @Previewable @State var path = NavigationPath()
    NavigationStack(path: $path) {
        DiaryView(path: $path)
    }
}
