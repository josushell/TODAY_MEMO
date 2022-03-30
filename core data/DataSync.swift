//
//  DataSync.swift
//  memoApp
//
//  Created by JOSUEYEON on 2022/03/30.
//

import Foundation
import UIKit
import CoreData
import Alamofire

class DataSync
{
    lazy var context: NSManagedObjectContext = {
        let appDel = UIApplication.shared.delegate as! AppDelegate
        return appDel.persistentContainer.viewContext
    }()
    
    // MARK: 서버 데이터 받기
    func downloadBackupData()
    {
        let ud = UserDefaults.standard
        guard ud.value(forKey: "firstLogin") == nil else {
            return
        }
        
        let tk = TokenUtils()
        let url = "http://swiftapi.rubypaper.co.kr:2029/memo/search"
        
        AF.request(url, method: .post, encoding: JSONEncoding.default, headers: tk.AuthorizationHeader).responseJSON() { res in
            guard let jsonObj = try! res.result.get() as? NSDictionary else {return}
            guard let list = jsonObj["list"] as? NSArray else {return}
            
            for item in list {
                guard let record = item as? NSDictionary else {return}
                
                let obj = NSEntityDescription.insertNewObject(forEntityName: "Memo", into: self.context) as! MemoMO
                
                obj.title = record["title"] as? String
                obj.contents = record["contents"] as? String
                obj.regdate = self.StringToDate(record["create_date"] as! String)
                obj.sync = true
                
                if let imgPath = record["image_path"] as? String {
                    let url = URL(string: imgPath)!
                    obj.image = try!  Data(contentsOf: url)
                }
            }
            
            do
            {
                try self.context.save()
            }
            catch
            {
                self.context.rollback()
            }
            
            ud.setValue(true, forKey: "firstLogin")
        }
    }
    
    // MARK: 서버 데이터 업로드
    func uploadData(_ indicatorView: UIActivityIndicatorView? = nil)
    {
        let fetchRequest: NSFetchRequest<MemoMO> = MemoMO.fetchRequest()
        
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "regdate", ascending: false)]
        fetchRequest.predicate = NSPredicate(format: "sync == false")
        
        do
        {
            let resultset = try self.context.fetch(fetchRequest)
            
            for record in resultset
            {
                indicatorView?.startAnimating()
                self.uploadOneData(record) {
                    if record == resultset.last
                    {
                        indicatorView?.stopAnimating()
                    }
                }
            }
        }
        catch
        {
            self.context.rollback()
        }
    }
    
    func uploadOneData(_ record: MemoMO, completion: (()->Void)? = nil)
    {
        let tk = TokenUtils()
        
        guard let header = tk.AuthorizationHeader else {return}
        
        var param: Parameters = [
            "title" : record.title ?? "",
            "contents" : record.contents ?? "",
            "create_date" : self.DateToString(record.regdate ?? Date())
        ]
        
        if let imgData = record.image as Data? {
            param["image"] = imgData.base64EncodedString()
        }
        
        let url = "http://swiftapi.rubypaper.co.kr:2029/memo/save"
        AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: header).responseJSON() { res in
            guard let obj = try! res.result.get() as? NSDictionary else {return}
            
            let resultCode = obj["result_code"] as! Int
            if (resultCode == 0)
            {
                do
                {
                    record.sync = true
                    try self.context.save()
                }
                catch
                {
                    self.context.rollback()
                }
            }
        }
        completion?()
    }

}

// MARK: - utility methods
extension DataSync
{
    func StringToDate(_ value: String) -> Date
    {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.date(from: value)!
    }
    
    func DateToString(_ value: Date) -> String
    {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return df.string(from: value as Date)
    }
}
