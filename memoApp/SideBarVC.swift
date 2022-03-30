//
//  SideBarVC.swift
//  memoApp
//
//  Created by JOSUEYEON on 2022/03/09.
//

import UIKit

class SideBarVC: UITableViewController
{
    let titles = ["새글 작성하기", "친구 새글", "달력으로 보기", "공지사항", "통계", "계정 관리"]
    
    let icons = [
        UIImage(named: "icon01"),
        UIImage(named: "icon02"),
        UIImage(named: "icon03"),
        UIImage(named: "icon04"),
        UIImage(named: "icon05"),
        UIImage(named: "icon06")
    ]
    
    let name = UILabel()
    let email = UILabel()
    let profileImg = UIImageView()
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.titles.count
    }
    

    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        if (indexPath.row == 0)
        {
            let uv = self.storyboard?.instantiateViewController(withIdentifier: "MemoForm")
            let target = self.revealViewController().frontViewController as! UINavigationController
            target.pushViewController(uv!, animated: true)
            target.revealViewController().revealToggle(self)
        }
        else if (indexPath.row == 5)
        {
            let uv = self.storyboard?.instantiateViewController(withIdentifier: "_Profile")
            uv?.modalPresentationStyle = .fullScreen
            self.present(uv!, animated: true){
                self.revealViewController().revealToggle(self)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = "menucell"
        
        let cell = tableView.dequeueReusableCell(withIdentifier: id) ?? UITableViewCell(style: .default, reuseIdentifier: id)
        
        cell.textLabel?.text = self.titles[indexPath.row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.imageView?.image = self.icons[indexPath.row]
        
        return cell
    }
    
    
    override func viewDidLoad() {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: 70))
        headerView.backgroundColor = .brown
        
        self.name.frame = CGRect(x: 70, y: 15, width: 100, height: 30)
        self.name.text = "조수연"
        self.name.textColor = .white
        self.name.font = UIFont.boldSystemFont(ofSize: 15)
        self.name.backgroundColor = .clear
        self.view.addSubview(self.name)
        
        self.email.frame = CGRect(x: 70, y: 40, width: 100, height: 30)
        self.email.text = "yoy07030@khu.ac.kr"
        self.email.textColor = .white
        self.email.font = UIFont.boldSystemFont(ofSize: 14)
        self.email.backgroundColor = .clear
        self.email.sizeToFit()
        self.view.addSubview(self.email)
        
        self.profileImg.frame = CGRect(x: 10, y: 10, width: 50, height: 50)
        self.profileImg.image = UIImage(named: "account")
        
        self.profileImg.layer.cornerRadius = (self.profileImg.frame.width) / 2
        self.profileImg.layer.masksToBounds = true
        self.profileImg.layer.borderWidth = 0
    
        self.view.addSubview(self.profileImg)
        
        
        self.tableView.tableHeaderView = headerView

    }
}
