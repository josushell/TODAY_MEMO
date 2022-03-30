//
//  utils.swift
//  memoApp
//
//  Created by JOSUEYEON on 2022/03/15.
//

import UIKit
import Security
import Alamofire

extension UIViewController
{
    // MARK: view controller를 읽어오는 함수 구현
    var tutorialSB: UIStoryboard
    {
        return UIStoryboard(name: "Tutorial", bundle: Bundle.main)
    }
    
    func instanceTutorialVC(name: String) -> UIViewController?
    {
        return self.tutorialSB.instantiateViewController(withIdentifier: name)
    }
    
    // MARK: - alert 코드 모듈화
    func alert(_ message: String, completion: (()->Void)? = nil)
    {
        // main thread에서 실행할 수 있도록 (URLSession 때문에 서브 스레드에서 실행될 수 있으므로 처리해줌)
        DispatchQueue.main.async {
            let al = UIAlertController(title: nil, message: message, preferredStyle: .alert)
            al.addAction(UIAlertAction(title: "OK", style: .cancel, handler: {(_) in completion?()}))
            
            self.present(al, animated: true)
        }
    }
}

//MARK: - Key Chain Access Token
class TokenUtils
{
    // 인증 헤더
    lazy var AuthorizationHeader: HTTPHeaders? = {
        let serviceID = "com.sueyeon.memoApp"
        if let accessToken = self.load(serviceID, account: "accessToken") {
            return ["Authorization" : "Bearer \(accessToken)"] as HTTPHeaders
        }
        else {
            return nil
        }
    }()
    // MARK: 저장
    func save(_ service: String, account: String, value: String)
    {
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: value.data(using: .utf8, allowLossyConversion: false)!
        ]
        
        SecItemDelete(keyChainQuery)
        
        let status: OSStatus = SecItemAdd(keyChainQuery, nil)
        assert(status == noErr, "토큰 값 저장에 실패했습니다.")
        NSLog("status = \(status)")
    }
    
    // MARK: 읽기
    func load(_ service: String, account: String) -> String?
    {
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnData: kCFBooleanTrue,
            kSecMatchLimit: kSecMatchLimitOne
        ]
        
        var dataRef: AnyObject?
        let status = SecItemCopyMatching(keyChainQuery, &dataRef)
        
        if (status == errSecSuccess) {
            let retrievedData = dataRef as! Data
            let value = String(data: retrievedData, encoding: .utf8)
            return value
        }
        else {
            print("Nothing returned. status code: \(status)")
            return nil
        }
    }
    
    // MARK: 삭제
    func delete(_ service: String, account: String)
    {
        let keyChainQuery: NSDictionary = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
        ]

        let status: OSStatus = SecItemDelete(keyChainQuery)
        assert(status == noErr, "토큰 값 삭제에 실패했습니다.")
        NSLog("status = \(status)")
    }
}
