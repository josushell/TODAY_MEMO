//
//  JoinVC.swift
//  memoApp
//
//  Created by JOSUEYEON on 2022/03/28.
//

import UIKit
import Alamofire

// MARK: - 새 계정 추가
class JoinVC: UIViewController {

    @IBOutlet weak var profile: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    // table view text fiedls
    var fieldAccount: UITextField!
    var fieldPassword: UITextField!
    var fieldName: UITextField!
    
    // indicator
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    // 중복 방지
    var isCalling = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // image view와의 상호 작용 가능하게 함
        self.profile.isUserInteractionEnabled = true
        
        // image 처리
        self.profile.layer.cornerRadius = self.profile.frame.width/2
        self.profile.layer.masksToBounds = true
        
        // image 터치 시 반응
        self.profile.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedProfile(_:))))
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        // indicator 설정
        indicatorView.hidesWhenStopped = true
        self.view.bringSubviewToFront(self.indicatorView)
    }
    
    // MARK: 계정 생성 완료 btn action method
    @IBAction func submit(_ sender: Any) {
        if self.isCalling == true
        {
            self.alert("진행중입니다.")
            return
        }
        else
        {
            self.isCalling = true
            
            guard self.fieldAccount.text?.isEmpty == false,
                  self.fieldName.text?.isEmpty == false,
                  self.fieldPassword.text?.isEmpty == false else {
                return
            }
            
            indicatorView.startAnimating()
            
            let profileImg = self.profile.image!.pngData()?.base64EncodedString()
           
                let param: Parameters = [
                "account"       : self.fieldAccount.text!,
                "passwd"        : self.fieldPassword.text!,
                "name"          : self.fieldName.text!,
                "profile_image" : profileImg!
            ]
            
            // API 호출
            let url = "http://swiftapi.rubypaper.co.kr/2029:userAccount/join"
            let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)
            
            call.responseJSON() {response in
                self.indicatorView.stopAnimating()
                
                guard let jsonObj = try! response.result.get() as? [String: Any] else {
                    self.isCalling = false
                    self.alert("서버 호출 오류가 발생하였습니다.")
                    return
                }
                let resultCode = jsonObj["result_code"] as! Int
                if resultCode == 0 {
                    self.alert("가입이 완료되었습니다.") {
                        // unwind segue
                        self.performSegue(withIdentifier: "backProfileVC", sender: self)
                    }
                }
                else {
                    let errorMsg = jsonObj["error_mgs"] as! String
                    self.isCalling = false
                    self.alert("오류 발생: \(errorMsg)")
                }
            }
        }
    }
 
}

// MARK: - 정적 테이블 뷰 cell 구현을 위한 프로토콜 구현
extension JoinVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let tfFrame = CGRect(x: 20, y: 0, width: cell.bounds.width - 20, height: 37)
        
        switch indexPath.row
        {
        case 0:
            self.fieldAccount = UITextField(frame: tfFrame)
            self.fieldAccount.placeholder = "계정(이메일)"
            self.fieldAccount.borderStyle = .none
            self.fieldAccount.autocapitalizationType = .none
            self.fieldAccount.keyboardType = .emailAddress
            self.fieldAccount.font = UIFont.systemFont(ofSize: 14)
            cell.addSubview(self.fieldAccount)
        case 1:
            self.fieldPassword = UITextField(frame: tfFrame)
            self.fieldPassword.placeholder = "비밀번호"
            self.fieldPassword.borderStyle = .none
            self.fieldPassword.font = UIFont.systemFont(ofSize: 14)
            cell.addSubview(self.fieldPassword)
        case 2:
            self.fieldName = UITextField(frame: tfFrame)
            self.fieldName.placeholder = "이름"
            self.fieldName.borderStyle = .none
            self.fieldName.font = UIFont.systemFont(ofSize: 14)
            cell.addSubview(self.fieldName)
        default:
            ()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

// MARK: - image picker controller 구현
extension JoinVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func selectLib(src: UIImagePickerController.SourceType)
    {
        if UIImagePickerController.isSourceTypeAvailable(src) {
            let picker = UIImagePickerController()
            picker.delegate = self
            picker.allowsEditing = true
            
            self.present(picker, animated: true)
        }
        else
        {
            self.alert("사용할 수 없는 타입입니다.")
        }
    }
    @objc func tappedProfile(_ sender: Any)
    {
        let msg = "프로필 이미지를 읽어올 소스를 선택하세요"
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "저장된 앨범", style: .default){ (_) in
            self.selectLib(src: .savedPhotosAlbum)
        })
        
        alert.addAction(UIAlertAction(title: "포토 라이브러리", style: .default){ (_) in
            self.selectLib(src: .photoLibrary)
        })
        alert.addAction(UIAlertAction(title: "카메라", style: .default){ (_) in
            self.selectLib(src: .camera)
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // MARK: 선택 완료
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let rawVal = UIImagePickerController.InfoKey.originalImage.rawValue
        if let img = info[UIImagePickerController.InfoKey(rawValue: rawVal)] as? UIImage {
            self.profile.image = img
        }
        self.dismiss(animated: true)
    }
    // MARK: 선택 취소
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
}
