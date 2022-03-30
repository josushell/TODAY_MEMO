//
//  UserInfoManager.swift
//  memoApp
//
//  Created by JOSUEYEON on 2022/03/15.
//

import UIKit
import Alamofire

// MARK: property list에 저장할 Key 이름 상수화
struct UserInfoKey
{
    static let loginId = "LOGINID"
    static let account = "ACCOUNT"
    static let name = "NAME"
    static let profile = "PROFILE"
    static let tutorial = "TUTORIAL"
}

// MARK: - 데이터를 관리하는 모듈
class UserInfoManager
{
    var loginId: Int
    {
        get
        {
            return UserDefaults.standard.integer(forKey: UserInfoKey.loginId)
        }
        set(data)
        {
            let ud = UserDefaults.standard
            ud.set(data, forKey: UserInfoKey.loginId)
            ud.synchronize()
        }
    }
    
    var account: String?
    {
        get
        {
            return UserDefaults.standard.string(forKey: UserInfoKey.account)
        }
        set(data)
        {
            let ud = UserDefaults.standard
            ud.set(data, forKey: UserInfoKey.account)
            ud.synchronize()
        }
    }
    
    var name:String?
    {
        get
        {
            return UserDefaults.standard.string(forKey: UserInfoKey.name)
        }
        set(data)
        {
            let ud = UserDefaults.standard
            ud.set(data, forKey: UserInfoKey.name)
            ud.synchronize()
        }
    }
    
    var profile: UIImage?
    {
        get
        {
            let ud = UserDefaults.standard
            if let _profile = ud.data(forKey: UserInfoKey.profile)
            {
                return UIImage(data: _profile)
            }
            else
            {
                return UIImage(named: "account.jpg")
            }
        }
        
        set(data)
        {
            if (data != nil)
            {
                let ud = UserDefaults.standard
                ud.set(data?.pngData, forKey: UserInfoKey.profile)
                ud.synchronize()
            }
            
        }
    }
    
    // MARK: - 로그인 기능 구현
    var isLogin: Bool
    {
        if (self.loginId == 0 || self.account == nil)
        {
            return false
        }
        return true
    }
    
    func login(id: String, pw: String, success: (()->Void)? = nil, fail: ((String)->Void)? = nil)
    {
        // UserDefaults 를 사용한 기능
        /*
        if (id == "yoy07030@khu.ac.kr" && pw == "1234")
        {
            let ud = UserDefaults.standard
            ud.set(100, forKey: UserInfoKey.loginId)
            ud.set(id, forKey: UserInfoKey.account)
            ud.set("조수연", forKey: UserInfoKey.name)
            
            ud.synchronize()
            return true
        }
        return false
         */
        
        // 서버 연동을 사용한 기능
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/login"
        let param: Parameters = ["account": id, "passwd": pw]
        
        let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default)
        
        call.responseJSON() { res in
            let result = try! res.result.get()
            
            guard let jsonObjc = result as? NSDictionary else {
                fail?("잘못된 응답입니다: \(result)")
                return
            }
            let resultCode = jsonObjc["result_code"] as? Int
            
            if resultCode == 0
            {
                let user = jsonObjc["user_info"] as! NSDictionary
                
                self.loginId = user["user_id"] as! Int
                self.account = user["account"] as? String
                self.name = user["name"] as? String
                
                if let path = user["profile_path"] as? String {
                    if let img = try? Data(contentsOf: URL(string: path)!) {
                        self.profile = UIImage(data: img)
                    }
                }
                
                // 서버가 주는 access Token, refrese Token 저장
                let accessToken = jsonObjc["access_Token"] as! String
                let refreshToken = jsonObjc["refresh_Token"] as! String
                
                let tk = TokenUtils()
                tk.save("com.sueyeon.memoApp", account: "accessToken", value: accessToken)
                tk.save("com.sueyeon.memoApp", account: "refreshToken", value: refreshToken)
                
                success?()
            }
            else
            {
                let msg = jsonObjc["error_msg"] as? String ?? "로그인 실패"
                fail?(msg)
            }
        }
        
    }
    
    // 인증헤더 포함해서 logout api를 호출함. 응답하면 userDefaults의 정보를 지우고, keychain의 토큰 정보를 지움
    func logout(completion: (()->Void)? = nil)
    {
        
        // 서버 연동을 사용한 기능
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/logout"
        
        let tokenUtils = TokenUtils()

        let call = AF.request(url, method: .post, encoding: JSONEncoding.default, headers: tokenUtils.AuthorizationHeader)
        
        call.responseJSON() { _ in
            self.deviceLogout()
            completion?()
        }
    }
    
    func deviceLogout() {
        // userDefaults에 저장된 개인 정보 삭제
        let ud = UserDefaults.standard
        
        // 앱 도메인(번들 아이디)에 저장된 데이터를 모두 삭제할려면 removePersistentDomain(forName:)
        ud.removeObject(forKey: UserInfoKey.loginId)
        ud.removeObject(forKey: UserInfoKey.name)
        ud.removeObject(forKey: UserInfoKey.account)
        ud.removeObject(forKey: UserInfoKey.profile)
        
        ud.synchronize()
        
        // keychain의 토큰 정보 삭제
        let tokenUtils = TokenUtils()
        tokenUtils.delete("com.sueyeon.memoApp", account: "refreshToken")
        tokenUtils.delete("com.sueyeon.memoApp", account: "accessToken")

    }
    
    // MARK: - image가 변경되면 서버의 데이터도 업데이트
    func newProfile(_ profile: UIImage?, success: (()->Void)? = nil, fail: ((String)->Void)? = nil)
    {
        let url = "http://swiftapi.rubypaper.co.kr:2029/userAccount/profile"
        
        let tk = TokenUtils()
        
        let profileImg = profile!.pngData()?.base64EncodedString()
        let param: Parameters = ["profile_image" : profileImg!]
        
        let call = AF.request(url, method: .post, parameters: param, encoding: JSONEncoding.default, headers: tk.AuthorizationHeader)
        
        call.responseJSON() { res in
            guard let jsonObj = try! res.result.get() as? NSDictionary else {
                fail?("올바른 응답값이 아닙니다.")
                return
            }
            
            let resultCode = jsonObj["result_code"] as! Int
            if resultCode == 0
            {
                self.profile = profile
                success?()
            }
            else
            {
                let msg = jsonObj["error_msg"] as? String ?? "이미지 프로필 변경이 실패하였습니다."
                fail?(msg)
            }
        }
    }
    
}
