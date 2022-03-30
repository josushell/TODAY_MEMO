//
//  MemoListViewController.swift
//  memoApp
//
//  Created by JOSUEYEON on 2022/03/02.
//

import UIKit

class MemoListViewController: UITableViewController {

    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    lazy var dao = MemoDAO()
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchBar.enablesReturnKeyAutomatically = false
        
        if let realVC = self.revealViewController()
        {
            let leftbtn = UIBarButtonItem(image: UIImage(named: "sidemenu"), style: .plain, target: realVC, action: #selector(realVC.revealToggle(_:)))
            self.view.addGestureRecognizer(realVC.panGestureRecognizer())
            self.navigationItem.leftBarButtonItem = leftbtn
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        let ud = UserDefaults.standard
        if ud.bool(forKey: UserInfoKey.tutorial) == false
        {
            let vc = self.instanceTutorialVC(name: "MasterVC")
            vc?.modalPresentationStyle = .fullScreen
            self.present(vc!, animated: true, completion: nil)
            return
        }
        
        self.appDelegate.memolist = dao.fetch()
        
        self.tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return self.appDelegate.memolist.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = self.appDelegate.memolist[indexPath.row]
        
        let cellId = (row.img == nil ? "memoCell" : "memoCellWithImg")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! MemoCell
        
        cell.title?.text = row.title
        cell.content?.text = row.content
        cell.img?.image = row.img
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        cell.date?.text = formatter.string(from: row.date!)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "Detail") as? DetailViewController else
        {
            return
        }
        vc.memoData = self.appDelegate.memolist[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let data = self.appDelegate.memolist[indexPath.row]
        
        if dao.delete(data.objectID!) == true
        {
            self.appDelegate.memolist.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

// MARK: - segue에 따른 prepare 구현
extension MemoListViewController
{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailSegue"
        {
            let dst = segue.destination as? DetailViewController
            let path = self.tableView.indexPath(for: sender as! UITableViewCell)

            dst?.memoData = self.appDelegate.memolist[path!.row]
        }
    }
}

// MARK: - search bar protocol 구현
extension MemoListViewController: UISearchBarDelegate
{
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        let keyword = searchBar.text
        
        self.appDelegate.memolist = self.dao.fetch(keyword: keyword)
        self.tableView.reloadData()
    }
}
