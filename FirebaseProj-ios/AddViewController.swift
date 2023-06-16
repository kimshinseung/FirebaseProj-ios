//
//  AddViewController.swift
//  FirebaseProj-ios
//
//  Created by 김신승 on 2023/06/14.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class AddViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var kakaoid: UITextField!
    @IBOutlet weak var content: UITextField!
    @IBOutlet weak var Name: UITextField!
    @IBOutlet weak var Price: UITextField!
    @IBOutlet weak var ImageView: UIImageView!
    let db = Firestore.firestore()
    let storageRef = Storage.storage().reference()
    var time: Date? = Date()

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func backbtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Enrollbtn(_ sender: UIButton) {
        //textField가 null이면 필수값 입력해야됨.
        guard let priceText = Price.text, !priceText.isEmpty else {
                showToast(message: "가격을 입력하세요")
                return
            }
            
            guard let nameText = Name.text, !nameText.isEmpty else {
                showToast(message: "이름을 입력하세요")
                return
            }
        
        let price = Price.text
        let name = Name.text
        let uploadtime = time?.toStringDateTime()
        let content = content.text
        let kakaoid = kakaoid.text
        let uid = Auth.auth().currentUser?.uid
        let visibled = true
        
        var data : [String: Any] = [
            "uploadtime" : uploadtime as Any,
            "price" : Int(price!) as Any,
            "name" : name as Any,
            "content" : content as Any,
            "uid" : uid as Any,
            "kakaoid" : kakaoid as Any,
            "seevalue" : Int(0) as Any,
            "visibled" : visibled
        ]
        if let image = ImageView.image {
                // 업로드할 이미지의 고유한 파일 이름 생성
                let imageName = "\(UUID().uuidString).jpg"
                
                // 업로드할 이미지를 JPEG 데이터로 변환
                if let imageData = image.jpegData(compressionQuality: 0.5) {
                    // Firebase Storage에 이미지 업로드
                    let uploadTask = storageRef.child(imageName).putData(imageData, metadata: nil) { (metadata, error) in
                        guard error == nil else {
                            print("Error uploading image: \(error!.localizedDescription)")
                            return
                        }
                        
                        // 이미지 업로드 성공 후 다운로드 URL 가져오기
                        self.storageRef.child(imageName).downloadURL { (url, error) in
                            guard let downloadURL = url else {
                                print("Error getting download URL: \(error!.localizedDescription)")
                                return
                            }

                            print("Image uploaded successfully. Download URL: \(downloadURL)")
                            // 다운로드 URL을 파이어스토어 데이터에 추가
                            data["imageURL"] = downloadURL.absoluteString as Any
                            
                            // 파이어스토어에 데이터 저장
                            self.saveDataToFirestore(data)
                        }
                    }
                    uploadTask.observe(.progress) { (snapshot) in
                        // 이미지 업로드 진행 상태 처리
                        guard let progress = snapshot.progress else {
                            return
                        }
                        //이미지 업로드 퍼센티지
                        let percentComplete = 100 * Int(progress.completedUnitCount) / Int(progress.totalUnitCount)
                        self.showToast(message: "이미지 업로드: \(percentComplete)%")
                        //print("Upload progress: \(percentComplete)%")
                    }
                    
                    uploadTask.observe(.success) { (snapshot) in
                        // 이미지 업로드 완료 처리
                        self.showToast(message: "게시글 업로드 성공!")
                    }
                }
        }else{
            saveDataToFirestore(data)
        }
    }
    //파이어베이스에 데이터 올리는 함수
    func saveDataToFirestore(_ data: [String: Any]) {
        db.collection("Data").addDocument(data: data) { error in
            if let error = error {
                print("데이터 업로드 실패: \(error.localizedDescription)")
            } else {
                print("데이터 업로드 성공!")
                self.dismiss(animated: true) {
                    self.showToast(message: "게시글을 등록하였습니다!")
                }
            }
        }
    }
    
    @IBAction func imageUpload(_ sender: UIButton) {
            // 컨트로러를 생성한다
                   let imagePickerController = UIImagePickerController()
                   imagePickerController.delegate = self // 이 딜리게이터를 설정하면 사진을 찍은후 호출된다

                   if UIImagePickerController.isSourceTypeAvailable(.camera) {
                       imagePickerController.sourceType = .photoLibrary
                   }else{
                       imagePickerController.sourceType = .photoLibrary
                   }

                   // UIImagePickerController이 활성화 된다, 11장을 보라
                   present(imagePickerController, animated: true, completion: nil)
    }
    
    
    
    func showToast(message : String, font: UIFont = UIFont.systemFont(ofSize: 14.0)) {
        let toastLabel = UILabel(frame: CGRect(x: self.view.frame.size.width/2 - 75, y: self.view.frame.size.height-100, width: 150, height: 35))
        toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        toastLabel.textColor = UIColor.white
        toastLabel.font = font
        toastLabel.textAlignment = .center;
        toastLabel.text = message
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 10;
        toastLabel.clipsToBounds  =  true
        self.view.addSubview(toastLabel)
        UIView.animate(withDuration: 4.0, delay: 0.1, options: .curveEaseOut, animations: {
            toastLabel.alpha = 0.0
        }, completion: {(isCompleted) in
            toastLabel.removeFromSuperview()
        })
    }
    
}

extension AddViewController{
    // 사진을 찍은 경우 호출되는 함수
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

       let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        // 여기서 이미지에 대한 추가적인 작업을 한다
        ImageView.image = image
        picker.dismiss(animated: true, completion: nil)
    }

    // 사진 캡쳐를 취소하는 경우 호출 함수
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // imagePickerController을 죽인다
        picker.dismiss(animated: true, completion: nil)
    }
}
