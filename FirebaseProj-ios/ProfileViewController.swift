//
//  ProfileViewController.swift
//  FirebaseProj-ios
//
//  Created by 김신승 on 2023/06/09.
//

import UIKit
import FirebaseAuth
class ProfileViewController: UIViewController {

    @IBOutlet weak var emailtext: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailtext.text = Auth.auth().currentUser?.email
        
    }
    
    @IBAction func backBtn(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func LogoutBtn(_ sender: Any) {
        do {
                    try Auth.auth().signOut()
                  } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                  }
        GoFirst()
    }
    func GoFirst(){
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: "FirstBoard")
                vcName?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                vcName?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                self.present(vcName!, animated: true, completion: nil)
    }
    
}
