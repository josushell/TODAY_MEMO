//
//  AddViewController.swift
//  memoApp
//
//  Created by JOSUEYEON on 2022/03/02.
//

import UIKit

class AddViewController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var imgView: UIImageView!
    var subject: String!
    var sourceType: Int = 1
    
    lazy var dao = MemoDAO()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.delegate = self

        // Do any additional setup after loading the view.
    }

    @IBAction func btnSave(_ sender: Any) {
        guard self.textView.text.isEmpty == false else
        {
            let alert = UIAlertController(title: nil, message: "내용을 입력해주세요.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
            return
        }
        let data = Memo()
        
        data.title = self.subject
        data.content = self.textView.text
        data.img = self.imgView.image
        data.date = Date()
        
//        let appDelegate = UIApplication.shared.delegate as? AppDelegate
//        appDelegate?.memolist.append(data)
        
        self.dao.insert(data)
        
       _ = self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnCamera(_ sender: Any) {
        chooseSourceType()
    }
    
    func loadImg()
    {
        let picker = UIImagePickerController()
        
        picker.delegate = self
        picker.allowsEditing = true
        
        switch self.sourceType
        {
        case 0:
            picker.sourceType = .camera
        case 1:
            picker.sourceType = .photoLibrary
        default:
            picker.sourceType = .savedPhotosAlbum
        }
        NSLog("값: \(self.sourceType)")
        self.present(picker, animated: true, completion: nil)
    }
    
    func chooseSourceType()
    {
        let alert = UIAlertController(title: nil, message: "이미지를 가져올 곳을 선택하세요", preferredStyle: .actionSheet)
        let action_cam = UIAlertAction(title: "카메라", style: .default) { (_) in
            self.sourceType = 0
            self.loadImg()
        }
        let action_lib = UIAlertAction(title: "사진 라이브러리", style: .default) { (_) in
            self.sourceType = 1
            self.loadImg()
        }
        let action_saved = UIAlertAction(title: "저장앨범", style: .default) { (_) in
            self.sourceType = 2
            self.loadImg()
        }
        alert.addAction(action_cam)
        alert.addAction(action_lib)
        alert.addAction(action_saved)
        
        self.present(alert, animated: true, completion: nil)
    }
}

// MARK: - imagepickerdelegate 구현
extension AddViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate
{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.imgView.image = info[.editedImage] as?
        UIImage
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

// MARK: - textview delegate 구현
extension AddViewController: UITextViewDelegate
{
    func textViewDidChange(_ textView: UITextView) {
        let contents = textView.text as NSString
        let length = (contents.length > 15) ? 15 : contents.length
        self.subject = contents.substring(with: NSRange(location: 0, length: length))
        
        self.navigationController?.title = self.subject
    }
}
