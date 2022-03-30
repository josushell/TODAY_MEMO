//
//  DetailViewController.swift
//  memoApp
//
//  Created by JOSUEYEON on 2022/03/02.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var detailTitle: UILabel!
    @IBOutlet var detailContent: UILabel!
    @IBOutlet var detailImg: UIImageView!
    
    var memoData: Memo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTitle.text = memoData?.title
        detailContent.text = memoData?.content
        detailImg.image = memoData?.img
        
        let formatter = DateFormatter()
        formatter.dateFormat = "dd일 HH:mm분에 작성됨"
        let datestring = formatter.string(from: (memoData?.date)!)
        
        self.navigationItem.title = datestring


        // Do any additional setup after loading the view.
    }
    

}
