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
                        self.GoMain()
                    }
                    else{
                        
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
    func GoMain(){
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: "MainBoard")
                vcName?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                vcName?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                self.present(vcName!, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if Auth.auth().currentUser != nil{
            DispatchQueue.main.async {
                self.GoMain()
            }
        }
    }
    
    
    
    
    
    
    
    func goToViewController(where: String) {
            let pushVC = self.storyboard?.instantiateViewController(withIdentifier: `where`)
            self.navigationController?.pushViewController(pushVC!, animated: true)
        }

}

