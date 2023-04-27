//
//  MainViewController.swift
//  FirebaseProj-ios
//
//  Created by 김신승 on 2023/04/27.
//

import UIKit
import FirebaseAuth
class MainViewController: UIViewController {

    @IBAction func LogoutBtn(_ sender: Any) {
        do {
                    try Auth.auth().signOut()
                  } catch let signOutError as NSError {
                    print ("Error signing out: %@", signOutError)
                  }
                self.dismiss(animated: true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
