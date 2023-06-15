//
//  DetailViewController.swift
//  FirebaseProj-ios
//
//  Created by 김신승 on 2023/06/15.
//

import UIKit
import FirebaseFirestore
import FirebaseStorage

class DetailViewController: UIViewController {
    
    @IBOutlet weak var Price: UILabel!
    @IBOutlet weak var ImageView: UIImageView!
    @IBOutlet weak var content: UILabel!
    
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
    }
    let storage = Storage.storage()
    let db = Firestore.firestore()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        db.collection("Data").document(id).getDocument{ (document, error) in
            if let error = error {
                print("데이터 가져오기 실패: \(error.localizedDescription)")
                return
            }
            guard let document = document, document.exists else {
                print("문서가 없습니다.")
                return
            }
            if(document.data()?["imageURL"] as? String == nil){
                if let data = document.data(),
                let price = data["price"] as? Int,
                let name = data["name"] as? String,
                let content = data["content"] as? String,
                let uploadtime = data["uploadtime"] as? String,
                let imageURL = "nil" as? String {
                    let user = Item(name: name, price: price, uploadtime: uploadtime, imageURL: imageURL, content: content)
                    self.Price.text = String(user.price) + "원"
                    self.Detailtitle.text = user.name
                    self.content.text = user.content
                    self.uploadtime.text = user.uploadtime
                }
            }else{
                if let data = document.data(),
                let price = data["price"] as? Int,
                let name = data["name"] as? String,
                let content = data["content"] as? String,
                let uploadtime = data["uploadtime"] as? String,
                let imageurl = data["imageURL"] as? String {
                    let user = Item(name: name, price: price, uploadtime: uploadtime, imageURL: imageurl, content: content)
                    self.Price.text = String(user.price) + "원"
                    self.Detailtitle.text = user.name
                    self.content.text = user.content
                    self.uploadtime.text = user.uploadtime
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
            
            
            
            
            
        }

       
    }


}
