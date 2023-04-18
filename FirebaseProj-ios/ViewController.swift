//
//  ViewController.swift
//  FirebaseProj-ios
//
//  Created by 김신승 on 2023/04/13.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {

    @IBOutlet weak var emailTextField:UITextField!
    
    @IBOutlet weak var pwTextField: UITextField!
    
    //로그인버튼, 파이어베이스에 정보가 있으면 성공, 없으면 실패
    @IBAction func loginButtonTouched(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: pwTextField.text!) { (user, error) in
                    if user != nil{
                        print("login success")
                    }
                    else{
                        print("login fail")
                    }
              }
    }
    //회원가입하는 버튼
    @IBAction func SinginButtonTouched(_ sender: UIButton) {
        let newVC = self.storyboard?.instantiateViewController(identifier: "SignInBoard")
                newVC?.modalTransitionStyle = .coverVertical
                newVC?.modalPresentationStyle = .automatic
                self.present(newVC!, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        if Auth.auth().currentUser != nil{
            let newVC = self.storyboard?.instantiateViewController(identifier: "MainBoard")
                    newVC?.modalTransitionStyle = .coverVertical
                    newVC?.modalPresentationStyle = .automatic
                    self.present(newVC!, animated: true, completion: nil)
            
            emailTextField.text = "이미 로그인 된 상태입니다."
            
        }
    }


}

