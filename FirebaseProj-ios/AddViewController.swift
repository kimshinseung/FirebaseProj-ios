//
//  AddViewController.swift
//  FirebaseProj-ios
//
//  Created by 김신승 on 2023/06/14.
//

import UIKit
import FirebaseFirestore

class AddViewController: UIViewController {
    
    @IBOutlet weak var Name: UITextField!
    @IBOutlet weak var Price: UITextField!
    
    let db = Firestore.firestore()
    
    var time: Date? = Date()

    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    @IBAction func backbtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Enrollbtn(_ sender: UIButton) {
        let price = Price.text
        let name = Name.text
        let uploadtime = time?.toStringDateTime()
        
        let data : [String: Any] = [
            "uploadtime" : uploadtime as Any,
            "price" : Int(price!) as Any,
            "name" : name as Any
        ]
        
        db.collection("Data").addDocument(data: data){ error in
            if let error = error {
                        print("데이터 업로드 실패: \(error.localizedDescription)")
                    } else {
                        print("데이터 업로드 성공!")
                        self.dismiss(animated: true){
                            self.showToast(message: "게시글을 등록하였습니다!")
                        }
                    }
        }
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
