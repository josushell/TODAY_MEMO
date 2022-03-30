//
//  CSButton.swift
//  memoApp
//
//  Created by JOSUEYEON on 2022/03/07.
//

import UIKit

// MARK: - button type을 위한 enum 구현
public enum CSButtonType: Int
{
    case basic
    case title
    case tag
}

// MARK: - UIButton 상속 커스텀 버튼 클래스 구현
class CSButton: UIButton {
    public var logType: CSButtonType = .basic
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setBackgroundImage(UIImage(named: "button-bg"), for: .normal)
        self.tintColor = .white
        
        self.addTarget(self, action: #selector(logging(_:)), for: .touchUpInside)
    }
    
    @objc func logging(_ sender: UIButton)
    {
        switch self.logType
        {
            case .basic:
                NSLog("button click")
            case .title:
                let btnTitle = sender.titleLabel?.text ?? "no title"
                NSLog("\(btnTitle): button click")
            case .tag:
                NSLog("\(sender.tag) click")
            
        }
    }

}
