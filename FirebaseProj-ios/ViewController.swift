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
    
    @IBOutlet weak var passwordeye: UIButton!
    
    @IBAction func passwordeyebtn(_ sender: Any) {
        pwTextField.isSecureTextEntry.toggle()//보안설정 반전
        passwordeye.isSelected.toggle() //버튼선택 상태 반전
        let eyeImage = passwordeye.isSelected ? "password shown eye icon" : "password hidden eye icon"
        passwordeye.setImage(UIImage(named: eyeImage), for: .normal)
        self.pwTextField.rightView = passwordeye
        self.pwTextField.rightViewMode = .always
    }
    
    
    //로그인버튼, 파이어베이스에 정보가 있으면 성공, 없으면 실패
    @IBAction func loginButtonTouched(_ sender: UIButton) {
        Auth.auth().signIn(withEmail: emailTextField.text!, password: pwTextField.text!) { (user, error) in
                    if user != nil{
                        self.GoMain()                    }
                    else{
                        self.showToast(message:"로그인에 실패하셨습니다.")
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
        pwTextField.isSecureTextEntry.toggle()//보안설정 반전
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
