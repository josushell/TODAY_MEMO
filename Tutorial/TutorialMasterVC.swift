//
//  TutorialMasterVC.swift
//  memoApp
//
//  Created by JOSUEYEON on 2022/03/15.
//

import UIKit

class TutorialMasterVC: UIViewController, UIPageViewControllerDataSource {

    var pageVC: UIPageViewController!
    
    var contentTitles = ["STEP 1", "STEP 2", "STEP 3", "STEP 4"]
    var contentImgs = ["page 0", "page 1", "page 2", "page 3",]
    
    @IBOutlet weak var btn: UIButton!
    
    override func viewDidLoad() {
        
        self.pageVC = self.instanceTutorialVC(name: "PageVC") as? UIPageViewController
        self.pageVC.dataSource = self
        
        let startContentVC = self.getContentVC(atIndex: 0)!
        self.pageVC.setViewControllers([startContentVC], direction: .forward, animated: true, completion: nil)
        
        self.pageVC.view.frame.origin = CGPoint(x: 0, y: 0)
        self.pageVC.view.frame.size.width = self.view.frame.width
        self.pageVC.view.frame.size.height = self.view.frame.height - 50
        
        self.addChild(self.pageVC)
        self.view.addSubview(self.pageVC.view)
        self.pageVC.didMove(toParent: self)

        self.view.bringSubviewToFront(btn)
        
    }
    
    @IBAction func close(_ sender: Any) {
        let ud = UserDefaults.standard
        ud.set(true, forKey: UserInfoKey.tutorial)
        ud.synchronize()
        
        // modal 이니까 연 곳에 가서 닫아달라 해야함
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    func getContentVC(atIndex idx: Int) -> UIViewController?
    {
        guard (self.contentTitles.count > idx && idx >= 0) else
        {
            return nil
        }
        
        guard let cvc = self.instanceTutorialVC(name: "ContentsVC") as? TutorialContentsVC else
        {
            return nil
        }
        
        cvc.titleText = self.contentTitles[idx]
        cvc.imgFile = self.contentImgs[idx]
        cvc.pageIdx = idx
        
        return cvc
    }
    
    // MARK: page controller protocol 구현
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard var index = (viewController as! TutorialContentsVC).pageIdx else
        {
            return nil
        }
        index = index + 1
        
        if index >= self.contentTitles.count - 1
        {
            index = 0
        }
        return self.getContentVC(atIndex: index)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard var index = (viewController as! TutorialContentsVC).pageIdx else
        {
            return nil
        }
        if index == 0
        {
            index = self.contentTitles.count - 1
        }
        else
        {
            index = index - 1
        }
        return self.getContentVC(atIndex: index)
    }
    
    // MARK: page indicator
    func presentationCount(for pageViewController: UIPageViewController) -> Int {
        self.contentTitles.count
    }
    
    func presentationIndex(for pageViewController: UIPageViewController) -> Int {
        return 0
    }
}
