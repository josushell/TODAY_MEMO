//
//  ProfileVC.swift
//  memoApp
//
//  Created by JOSUEYEON on 2022/03/10.
//

import UIKit
import Alamofire
import LocalAuthentication // 인증

class ProfileVC: UIViewController {

    let profileImg = UIImageView()
    let tv = UITableView()
    let uinfo = UserInfoManager() // 데이터 관리 객체
    
    // 중복 방지
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    var isCalling = false
    
    override func viewWillAppear(_ animated: Bool) {
        self.tokenValidate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.bringSubviewToFront(indicatorView)
        
        self.navigationItem.title = "프로필"
        
        let backBtn = UIBarButtonItem(title: "닫기", style: .plain, target: self, action: #selector(close(_:)))
        self.navigationItem.leftBarButtonItem = backBtn
        
        // back ground image
        let bg = UIImageView(image: UIImage(named: "profile-bg"))
        bg.frame.size = CGSize(width: bg.frame.size.width, height: bg.frame.size.height)
        bg.center = CGPoint(x: self.view.frame.width/2, y: 40)
        
        bg.layer.masksToBounds = true
        bg.layer.borderWidth = 0
        bg.layer.cornerRadius = bg.frame.width/2
        self.view.addSubview(bg)
        
        // profile image
        self.profileImg.image = self.uinfo.profile
        self.profileImg.frame.size = CGSize(width: 100, height: 100)
        self.profileImg.center = CGPoint(x: self.view.frame.width/2, y: 270)
        
        self.profileImg.layer.cornerRadius = self.profileImg.frame.width/2
        self.profileImg.layer.borderWidth = 0
        self.profileImg.layer.masksToBounds = true
        
        // table view
        self.tv.frame = CGRect(x: 0, y: self.profileImg.frame.origin.y + self.profileImg.frame.size.height + 20, width: self.view.frame.width, height: 100)
        self.tv.dataSource = self
        self.tv.delegate = self
        
        self.view.addSubview(self.tv)
        self.view.addSubview(self.profileImg)
        // Do any additional setup after loading the view.
        
        self.navigationController?.navigationBar.isHidden = true
        
        // button 초기 설정
        drawBtn()
        
        // profile 이미지에 제스쳐 추가
        let tap = UITapGestureRecognizer(target: self, action: #selector(profile(_:)))
        self.profileImg.addGestureRecognizer(tap)
        self.profileImg.isUserInteractionEnabled = true // 뷰가 사용자와 상호작용 가능한지 체크
        
        
    }
    
    @objc func close(_ sender: Any)
    {
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }

}

// MARK: - table view protocol 구현
extension ProfileVC: UITableViewDelegate, UITableViewDataSource
{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.uinfo.isLogin == false
        {
            self.doLogin(self.tv)
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: "cell")
        
        cell.textLabel?.font = UIFont.systemFont(ofSize: 14)
        cell.detailTextLabel?.font = UIFont.systemFont(ofSize: 13)
        cell.accessoryType = .disclosureIndicator
        
        let default_msg = "login please"
        switch indexPath.row {
            case 0 :
                cell.textLabel?.text = "이름"
                cell.detailTextLabel?.text = self.uinfo.name ?? default_msg
            case 1 :
                cell.textLabel?.text = "계정"
                cell.detailTextLabel?.text = self.uinfo.account ?? default_msg
            default :
                ()
        }
        
        return cell
    }
}

// MARK: - 로그인 기능 구현
extension ProfileVC
{
    // 로그인
    @objc func doLogin(_ sender: Any)
    {
        if isCalling == true
        {
            self.alert("응답을 기다리는 중입니다.\n 잠시만 기다려주세요")
            return
        }
        else
        {
            isCalling = true
            
            let alert = UIAlertController(title: "LOGIN", message: nil, preferredStyle: .alert)
            
            alert.addTextField(){ (tf) in
                tf.placeholder = "Enter Account"
            }
            alert.addTextField(){ (tf) in
                tf.placeholder = "Enter Password"
                tf.isSecureTextEntry = true
            }
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {(_) in self.isCalling = false}))
            alert.addAction(UIAlertAction(title: "Login", style: .default){ (_) in
                self.indicatorView.startAnimating()
                
                let account = alert.textFields?[0].text ?? ""
                let pw = alert.textFields?[1].text ?? ""
                
                // Synchronize version
                /*
                // 로그인 성공
                if self.uinfo.login(id: account, pw: pw)
                {
                    self.tv.reloadData()
                    self.profileImg.image = self.uinfo.profile
                    self.drawBtn()
                }
                // 로그인 실패
                else
                {
                    let msg = "로그인에 실패하였습니다."
                    let fail = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
                    fail.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(fail, animated: true, completion: nil)
                }
                 */
                
                // Asynchronize version call back method
                self.uinfo.login(id: account, pw: pw, success: {
                    self.indicatorView.stopAnimating()
                    self.isCalling = false
                    
                    self.tv.reloadData()
                    self.profileImg.image = self.uinfo.profile
                    self.drawBtn()

                    let sync = DataSync()
                    DispatchQueue.global(qos: .background).async {
                        sync.downloadBackupData()
                    }
                    
                    DispatchQueue.global(qos: .background).async {
                        sync.uploadData()
                    }
                    
                }, fail: { msg in
                    self.indicatorView.stopAnimating()
                    self.isCalling = false
                    self.alert(msg)
                })
            })
            self.present(alert, animated: true, completion: nil)
        }

    }
    
    // 로그아웃
    @objc func doLogOut(_ sender: Any)
    {
        let msg = "로그아웃 하시겠습니까?"
        
        let alert = UIAlertController(title: nil, message: msg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "취소", style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: "확인", style: .destructive){ (_) in
            // Synchronize version
            /*
            if (self.uinfo.logout())
            {
                self.tv.reloadData()
                self.profileImg.image = self.uinfo.profile
                self.drawBtn()
            }
             */
            self.indicatorView.startAnimating()
            
            self.uinfo.logout(completion: {
                self.indicatorView.stopAnimating()
                self.tv.reloadData()
                self.profileImg.image = self.uinfo.profile
                self.drawBtn()
            })
        })
        self.present(alert, animated: true, completion: nil)
    }
    
    // 로그인, 로그아웃 버튼 구현
    func drawBtn()
    {
        let v = UIView()
        v.frame.size.width = self.view.frame.width
        v.frame.size.height = 40
        v.frame.origin.x = 0
        v.frame.origin.y = self.tv.frame.origin.y + self.tv.frame.height
        v.backgroundColor = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)
        self.view.addSubview(v)
        
        let btn = UIButton(type: .system)
        btn.frame.size.width = 100
        btn.frame.size.height = 30
        btn.center.x = v.frame.width / 2
        btn.center.y = v.frame.height / 2
        
        if self.uinfo.isLogin == true
        {
            btn.setTitle("Log Out", for: .normal)
            btn.addTarget(self, action: #selector(doLogOut(_:)), for: .touchUpInside)
        }
        else
        {
            btn.setTitle("Log In", for: .normal)
            btn.addTarget(self, action: #selector(doLogin(_:)), for: .touchUpInside)
        }
        v.addSubview(btn)
    }
}

// MARK: - 이미지 피커 컨트롤러 구현
extension ProfileVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    // 이미지 피커 컨트롤러 실행
    func imgPicker(_ source: UIImagePickerController.SourceType)
    {
        let picker = UIImagePickerController()
        picker.sourceType = source
        picker.delegate = self
        picker.allowsEditing = true
        self.present(picker, animated: true, completion: nil)
    }
    
    // 소스 타입 결정
    @objc func profile(_ sender: Any)
    {
        guard self.uinfo.account != nil else
        {
            self.doLogin(self)
            return;
        }
        
        let alert = UIAlertController(title: nil, message: "사진을 가져올 곳을 선택하세요", preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera)
        {
            alert.addAction(UIAlertAction(title: "카메라", style: .default){ (_) in
                self.imgPicker(.camera)
            })
        }
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum)
        {
            alert.addAction(UIAlertAction(title: "저장한 앨범", style: .default){ (_) in
                self.imgPicker(.savedPhotosAlbum)
            })
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        {
            alert.addAction(UIAlertAction(title: "사진 라이브러리", style: .default){ (_) in
                self.imgPicker(.photoLibrary)
            })
        }
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    // 사진 선택이 완료되면 호출됨
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.indicatorView.startAnimating()
        
        if let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage
        {
            self.uinfo.newProfile(img, success: {
                self.indicatorView.stopAnimating()
                self.uinfo.profile = img
                self.profileImg.image = img
            }, fail: { msg in
                self.indicatorView.stopAnimating()
                self.alert(msg)
            })
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    
}

//MARK: - unwind segue 구현
extension ProfileVC
{
    @IBAction func backProfile(_ segue: UIStoryboardSegue)
    {
        
    }
}

//MARK: - touch ID, 토큰 유효성 검사 및 갱신 관리
extension ProfileVC
{
    // 토큰 유효성 검사
    func tokenValidate()
    {
        // 응답 캐시 다 지워줌
        URLCache.shared.removeAllCachedResponses()
        
        let tk = TokenUtils()
        guard let header = tk.AuthorizationHeader else {
            return
        }
        
        self.indicatorView.startAnimating()
        
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/tokenValidate"
        let validate = AF.request(url, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: header)
        
        validate.responseJSON() { res in
            self.indicatorView.stopAnimating()
            
            let resBody = try! res.result.get()
            guard let jsonObj = resBody as? NSDictionary else {
                self.alert("잘못된 응답입니다.")
                return
            }
            
            let resultCode = jsonObj["result_code"] as! Int
            if (resultCode != 0) {
                self.touchID()
            }
        }
    }
    
    // touch ID 인증
    func touchID()
    {
        // 인증 컨택스트: 인증 정보 종합 관리 객체
        let context = LAContext()
        
        var err: NSError?
        let msg = "인증이 필요합니다."
        let policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics // 정책
        
        // 인증 가능 여부 확인
        if context.canEvaluatePolicy(policy, error: &err)
        {
            // touch ID 인증창 실행
            context.evaluatePolicy(policy, localizedReason: msg) { (success, e) in
                if success
                {
                    self.refresh()
                }
                else
                {
                    switch (e?._code)
                    {
                        case LAError.systemCancel.rawValue:
                            self.alert("시스템에 의해 인증이 취소되었습니다.")
                        case LAError.userCancel.rawValue:
                            self.alert("사용자에 의해 인증이 취소되었습니다.") {
                                self.failLogout(true)
                            }
                            // 사용자가 직접 암호 입력을 선택했을 경우 (암호 입력 창으로 넘어가야 함)
                        case LAError.userFallback.rawValue:
                            OperationQueue.main.addOperation(){
                                self.failLogout(true)
                            }
                        default:
                            OperationQueue.main.addOperation(){
                                self.failLogout(true)
                            }
                    }
                }
            }
        }
        // 인증창 실행조차 못하는 경우 (touch ID 미지원 등)
        else
        {
            OperationQueue.main.addOperation(){
                self.failLogout(true)
            
        }
    }
    }
    
    // access token 갱신
    func refresh()
    {
        self.indicatorView.startAnimating()
        let service = "com.sueyeon.memoApp"
        
        let tk = TokenUtils()
        let refreshToken = tk.load(service, account: "refreshToken")
        let param: Parameters = ["refresh_token" : refreshToken!]
        
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/refresh"
        AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: tk.AuthorizationHeader).responseJSON() { res in
            self.indicatorView.stopAnimating()
            
            guard let jsonObj = try! res.result.get() as? NSDictionary else {
                self.alert("잘못된 응답입니다.")
                return
            }
            
            let resultCode = jsonObj["result_code"] as! Int
            
            // 성공
            if (resultCode == 0)
            {
                let accessToken = jsonObj["access_token"] as! String
                tk.save(service, account: "accessToken", value: accessToken)
            }
            else
            {
                self.alert("인증이 만료되었습니다. 다시 로그인해야 합니다.")
                OperationQueue.main.addOperation(){
                    self.failLogout(true)
                }
            }
            
            
        }

    }
    
    // 인증이 실패했을 때의 로그아웃처리
    func failLogout(_ isLogin: Bool = false)
    {
        let userInfo = UserInfoManager()
        userInfo.deviceLogout()
        
        self.tv.reloadData()
        self.profileImg.image = userInfo.profile
        self.drawBtn()
        
        if isLogin
        {
            self.doLogin(self)
        }
    }
}
