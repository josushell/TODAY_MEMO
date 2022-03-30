//
//  Memo.swift
//  memoApp
//
//  Created by JOSUEYEON on 2022/03/02.
//

import UIKit
import CoreData

class Memo
{
    var index: Int?
    var title: String?
    var content: String?
    var date: Date?
    var img: UIImage?
    
    // MemoMO 객체 참조를 위한 속성
    var objectID: NSManagedObjectID?
    
}
