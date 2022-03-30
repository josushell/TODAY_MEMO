//
//  TutorialContentsVC.swift
//  memoApp
//
//  Created by JOSUEYEON on 2022/03/15.
//

import UIKit

class TutorialContentsVC: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bgImgView: UIImageView!
    
    var pageIdx: Int!
    var titleText: String!
    var imgFile: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.bgImgView.contentMode = .scaleAspectFill
        
        self.titleLabel.text = self.titleText
        self.titleLabel.sizeToFit()
        
        self.bgImgView.image = UIImage(named: self.imgFile)
    }
    

}
