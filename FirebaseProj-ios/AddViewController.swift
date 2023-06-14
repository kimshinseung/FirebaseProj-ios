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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    @IBAction func backbtn(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func Enrollbtn(_ sender: UIButton) {
        let price = Price.text
        let name = Name.text
        
        let data : [String: Any] = [
            "time" : Timestamp(),
            "price" : price,
            "name" : name
        ]
        
        db.collection("Data").addDocument(data: data){ error in
            if let error = error {
                        print("데이터 업로드 실패: \(error.localizedDescription)")
                    } else {
                        print("데이터 업로드 성공!")
                    }
        }
    }
    
}
