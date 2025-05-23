//
//  CoreDataManager.swift
//  Nola
//
//  Created by loac on 28/04/2025.
//

import Foundation
import CoreData

final class CoreDataManager: ObservableObject {
    static let shared = CoreDataManager(inMemory: false)
    
    private var inMemory: Bool = false
    
    lazy var persistentContainer: NSPersistentContainer = {
        
        let container = NSPersistentContainer(name: "Model")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
            container.persistentStoreDescriptions.first!.type = NSInMemoryStoreType
        }
        
        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Failed to load persistent stores: \(error.localizedDescription)")
            }
        }
        
        // 视图上下文自动合并后台更改
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()
    
    // 预览用实例
    static var preview: CoreDataManager = {
        let manager = CoreDataManager(inMemory: true)
        
        // 添加预览数据
        let context = manager.persistentContainer.viewContext
        
        for i in 0..<2 {
            let userRecord = UserRecord(context: context)
            userRecord.id = UUID()
            userRecord.url = "https://\(i).loac.cc"
            userRecord.username = "loac\(i)"
            userRecord.avatar = "https://loac.cc/logo"
            userRecord.lastLoginTime = Date()
            userRecord.displayName = "Loac"
        }
        
        do {
            try context.save()
        } catch {
            fatalError(error.localizedDescription)
        }
        
        return manager
    }()
    
    
    private init(inMemory: Bool) {
        self.inMemory = inMemory
    }
}


extension NSManagedObjectContext {
    
    func saveIfHasChange() {
        // 检查是否有修改
        guard self.hasChanges else { return }
        
        do {
            try self.save()
        } catch {
            print("Failed to save the context: ", error.localizedDescription)
        }
        
        func delete<Item: NSManagedObject>(item: Item) {
            self.delete(item)
            saveIfHasChange()
        }
    }
    
}
