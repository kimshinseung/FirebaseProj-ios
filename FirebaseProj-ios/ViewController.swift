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
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


}

