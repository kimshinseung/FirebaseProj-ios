//
//  DetailViewController.swift
//  FirebaseProj-ios
//
//  Created by 김신승 on 2023/06/15.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth

class DetailViewController: UIViewController {
    
    @IBOutlet weak var completebtn: UIButton!
    @IBOutlet weak var seevalue: UILabel!
    @IBOutlet weak var Price: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var content: UILabel!
    
    @IBOutlet weak var kakaoid: UILabel!
    @IBOutlet weak var uploadtime: UILabel!
    
    @IBAction func Backbtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var Detailtitle: UILabel!
    
    var id: String = ""
    struct Item {
        let name: String
        let price: Int
        let uploadtime: String
        let imageURL: String
        let content: String
        let kakaoid: String
        let count: Int
    }
    let storage = Storage.storage()
    let db = Firestore.firestore()

    @IBAction func completeclick(_ sender: Any) {
        //거래완료 버튼 visbled필드 변경
        let fieldName = "visibled"
        self.db.collection("Data").document(self.id).updateData([fieldName: false]){ error in
            if let error = error {
                    print("필드 업데이트 실패: \(error.localizedDescription)")
                    return
                }

                print("필드 업데이트 성공")
                self.dismiss(animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //거래완료 버튼 숨기기
        completebtn.isHidden = true
        
        
        db.collection("Data").document(id).getDocument{ (document, error) in
            if let error = error {
                print("데이터 가져오기 실패: \(error.localizedDescription)")
                return
            }
            guard let document = document, document.exists else {
                print("문서가 없습니다.")
                return
            }
            //uid가 같으면 거래완료 버튼 활성화
            if(document.data()?["uid"] as! String==Auth.auth().currentUser?.uid ?? ""){
                self.completebtn.isHidden = false
            }
            
            if(document.data()?["imageURL"] as? String == nil){
                if let data = document.data(),
                let price = data["price"] as? Int,
                let name = data["name"] as? String,
                let content = data["content"] as? String,
                let uploadtime = data["uploadtime"] as? String,
                let kakao = data["kakaoid"] as? String,
                let count = data["seevalue"] as? Int,
                let imageURL = "nil" as? String {
                    let user = Item(name: name, price: price, uploadtime: uploadtime, imageURL: imageURL, content: content, kakaoid: kakao, count: count)
                    self.Price.text = String(user.price) + "원"
                    self.Detailtitle.text = user.name
                    self.content.text = user.content
                    self.uploadtime.text = user.uploadtime+", "+self.timeAgoSinceUploaded(uploadTime: user.uploadtime)
                    self.kakaoid.text = user.kakaoid
                    self.seevalue.text = String(user.count)
                }
            }else{
                if let data = document.data(),
                let price = data["price"] as? Int,
                let name = data["name"] as? String,
                let content = data["content"] as? String,
                let uploadtime = data["uploadtime"] as? String,
                let kakao = data["kakaoid"] as? String,
                   let count = data["seevalue"] as? Int,
                let imageurl = data["imageURL"] as? String {
                    let user = Item(name: name, price: price, uploadtime: uploadtime, imageURL: imageurl, content: content, kakaoid: kakao,count:count)
                    self.Price.text = String(user.price) + "원"
                    self.Detailtitle.text = user.name
                    self.content.text = user.content
                    self.uploadtime.text = user.uploadtime
                    self.kakaoid.text = user.kakaoid
                    self.seevalue.text = String(user.count)
                    // URL로부터 이미지를 비동기적으로 다운로드하고 표시합니다.
                    if let url = URL(string: user.imageURL) {
                        DispatchQueue.global().async {
                            if let data = try? Data(contentsOf: url) {
                                // 다운로드한 데이터로부터 이미지를 생성합니다.
                                if let image = UIImage(data: data) {
                                    DispatchQueue.main.async {
                                        // 이미지를 이미지 뷰에 설정합니다.
                                        self.ImageView.image = image
                                    }
                                }
                            }
                        }
                    }
                
                }
            }
            //조회수 보이기
            let fieldName = "seevalue"
            self.db.collection("Data").document(self.id).updateData([fieldName: FieldValue.increment(Int64(1))]){ error in
                if let error = error {
                        print("필드 업데이트 실패: \(error.localizedDescription)")
                        return
                    }

                    print("필드 업데이트 성공")
            }
            
        
        }
        
        
    }//viewdidload


}
extension DetailViewController{
    func timeAgoSinceUploaded(uploadTime: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss" // uploadtime의 형식에 맞게 설정
        
        guard let uploadDate = dateFormatter.date(from: uploadTime) else {
            return "" // 날짜 변환 실패 시 빈 문자열 반환
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.minute], from: uploadDate, to: currentDate)
        if let minutes = components.minute {
            if minutes < 1 {
                return "방금 전"
            } else if minutes < 60 {
                return "\(minutes)분 전"
            } else {
                let hours = minutes / 60
                if hours < 24 {
                    return "\(hours)시간 전"
                } else {
                    let days = hours / 24
                    return "\(days)일 전"
                }
            }
        }
        
        return "" // 처리못한경우 nil값 반환
    }
}
