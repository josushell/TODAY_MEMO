//
//  MemoDAO.swift
//  memoApp
//
//  Created by JOSUEYEON on 2022/03/26.
//

import Foundation
import CoreData

// MARK: Data Access Object : core data와 상호작용
class MemoDAO{
    // MARK: 객체 관리 컨택스트
    lazy var context: NSManagedObjectContext = {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        return appDel.persistentContainer.viewContext
    }()
    
    // MARK: - 데이터를 모두 가져오기
    func fetch(keyword text: String? = nil) -> [Memo]
    {
        var memolist = [Memo]()
        
        let fetchRequest: NSFetchRequest<MemoMO> = MemoMO.fetchRequest() // 요청 객체
        
        let regdateDesc = NSSortDescriptor(key: "regdate", ascending: false)
        fetchRequest.sortDescriptors = [regdateDesc]
        
        if let t = text, t.isEmpty == false
        {
            fetchRequest.predicate = NSPredicate(format: "contents CONTAINS[c] %@", t)
        }
        do
        {
            let resultset = try self.context.fetch(fetchRequest)
            
            for record in resultset
            {
                let data = Memo()
                
                data.title = record.title
                data.content = record.contents
                data.date = record.regdate! as Date
                data.objectID = record.objectID
                
                if let image = record.image as Data? {
                    data.img = UIImage(data: image)
                }
                memolist.append(data)
            }
        }
        catch let e as NSError
        {
            NSLog("An error has occurred: %s", e.localizedDescription)
        }
        return memolist
    }
    
    // MARK: - 데이터를 추가하기
    func insert(_ data: Memo)
    {
        let object = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: self.context) as! MemoMO
        
        object.title = data.title
        object.contents = data.content
        object.regdate = data.date!
        
        if let image = data.img {
            object.image = image.pngData()
        }
        
        do
        {
            try self.context.save()
            
            if TokenUtils().AuthorizationHeader != nil {
                DispatchQueue.global(qos: .background).async {
                    let sync = DataSync()
                    sync.uploadOneData(object)
                }
            }
        }
        catch let e as NSError
        {
            NSLog("An error has occurred: %s", e.localizedDescription)
        }
    }
    
    // MARK: - 데이터를 삭제하기
    func delete(_ objID: NSManagedObjectID) -> Bool
    {
        let object = self.context.object(with: objID)
        
        self.context.delete(object)
        
        do
        {
            try self.context.save()
            return true
        }
        catch let e as NSError
        {
            NSLog("An error has occurred: %s", e.localizedDescription)
            return false
        }
    }
}
