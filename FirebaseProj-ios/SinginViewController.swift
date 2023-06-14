//
//  SinginViewController.swift
//  FirebaseProj-ios
//
//  Created by 김신승 on 2023/04/16.
//

import UIKit
import FirebaseAuth

class SinginViewController: UIViewController {
    
    @IBOutlet weak var EmailTextField: UITextField!
    
    @IBOutlet weak var PwTextField: UITextField!
    
    @IBOutlet weak var pweye: UIButton!
    //뒤로 나가는 코드
    @IBAction func ExitButton(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func pweyebtn(_ sender: Any) {
        PwTextField.isSecureTextEntry.toggle()//보안설정 반전
        pweye.isSelected.toggle() //버튼선택 상태 반전
        let eyeImage = pweye.isSelected ? "password shown eye icon" : "password hidden eye icon"
        pweye.setImage(UIImage(named: eyeImage), for: .normal)
        self.PwTextField.rightView = pweye
        self.PwTextField.rightViewMode = .always
    }
    
    @IBAction func SingInButton(_ sender: UIButton) {
        Auth.auth().createUser(withEmail: EmailTextField.text!, password: PwTextField.text!){(user,error) in
            if user != nil{
                self.showToast(message: "회원가입에 성공했습니다.")
                self.dismiss(animated: true, completion: nil)
            }
            else{
                self.showToast(message: "회원가입에 실패했습니다.")
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
