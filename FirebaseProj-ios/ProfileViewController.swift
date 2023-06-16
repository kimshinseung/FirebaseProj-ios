//
//  ProfileViewController.swift
//  FirebaseProj-ios
//
//  Created by 김신승 on 2023/06/09.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
class ProfileViewController: UIViewController {

    @IBOutlet weak var emailtext: UILabel!
    
    @IBOutlet weak var TableView: UITableView!
    struct Item {
        let name: String
        let price: Int
        let uploadtime: String
        let documentID: String
        let imageURL: String
        let visibled: Bool
    }
    var selectedDate: Date? = Date()
    
    var data: [Item] = [] //파이어베이스에서 가져오는 데이터 저장
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailtext.text = Auth.auth().currentUser?.email
        TableView.dataSource = self
        TableView.delegate = self
        //TableView.isEditing = true //바로 에디팅할수 있게 하는 코드
        TableView.estimatedRowHeight = 150
        TableView.rowHeight = 100
        let uid = Auth.auth().currentUser?.uid ?? ""
        getData(uid: uid)
        
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
    
    // 파이어스토어에서 데이터 가져오기
    func getData(uid: String) {
        let db = Firestore.firestore()
        //내 uid게시물만 보이기
        db.collection("Data").order(by: "uploadtime",descending: false).whereField("uid", isEqualTo:uid).getDocuments { (snapshot, error) in
               if let error = error {
                   print("데이터 가져오기 실패: \(error.localizedDescription)")
                   return
               }
               
               guard let documents = snapshot?.documents else {
                   print("문서가 없습니다.")
                   return
               }
               
               self.data = documents.compactMap { document in
                   //이미지가 없으면 이미지에 nil를 넣어서 구분한다.
                   if(document.data()["imageURL"] as? String == nil){
                       guard let name = document.data()["name"] as? String,
                             let price = document.data()["price"] as? Int,
                             let visible = document.data()["visibled"] as? Bool,
                             let uploadtime = document.data()["uploadtime"] as? String,
                             let imageURL = "nil" as? String else {
                           return nil
                       }
                       return Item(name: name, price: price, uploadtime: uploadtime,documentID: document.documentID,imageURL: imageURL,visibled: visible)
                   }else{ //이미지가 있으면 그대로 진행
                       guard let name = document.data()["name"] as? String,
                             let price = document.data()["price"] as? Int,
                             let visible = document.data()["visibled"] as? Bool,
                             let uploadtime = document.data()["uploadtime"] as? String,
                             let imageURL = document.data()["imageURL"] as? String else {
                           return nil
                       }
                       return Item(name: name, price: price, uploadtime: uploadtime,documentID: document.documentID,imageURL: imageURL,visibled: visible)
                   }
               }
               self.TableView.reloadData()
           }
       }

}
    
extension ProfileViewController: UITableViewDataSource,UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

//        if let planGroup = planGroup{
//            return planGroup.getPlans(date:selectedDate).count
//        }
        return data.count    // planGroup가 생성되기전에 호출될 수도 있다
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PlanTableViewCell", for: indexPath)
        let item = data[indexPath.row]
        
        //이미지가 없는 경우
        if(item.imageURL == "nil"){
            (cell.contentView.subviews[2] as! UIImageView).image = nil
        }else{ //이미지가 있는 경우
            let imageview = (cell.contentView.subviews[2] as! UIImageView)
            
            // URL로부터 이미지를 비동기적으로 다운로드하고 표시합니다.
            if let url = URL(string: item.imageURL) {
                DispatchQueue.global().async {
                    if let data = try? Data(contentsOf: url) {
                        // 다운로드한 데이터로부터 이미지를 생성합니다.
                        if let image = UIImage(data: data) {
                            DispatchQueue.main.async {
                                // 이미지를 이미지 뷰에 설정합니다.
                                imageview.image = image
                            }
                        }
                    }
                }
            }
        }

        let uploadtime = timeAgoSinceUploaded(uploadTime: item.uploadtime)
            
        (cell.contentView.subviews[0] as! UILabel).text = uploadtime
        (cell.contentView.subviews[1] as! UILabel).text = item.name
        (cell.contentView.subviews[3] as! UILabel).text = String(item.price)+"원"
        //거래완료시 가격을 거래완료로 변경
        if(item.visibled == false){
            (cell.contentView.subviews[3] as! UILabel).text = "거래 완료"
        }
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let item = data[indexPath.row]
        //거래완료이면 셀 선택해도 못 들어감.
        if(item.visibled == false){
            showToast(message: "거래완료된 게시글입니다.")
        }else{
            // 선택된 셀의 문서 ID를 가져옵니다.
            let selectedId = data[indexPath.row].documentID
            print(selectedId)
            //셀의 문서id를 보내고 뷰 변경
            let vcName = self.storyboard?.instantiateViewController(withIdentifier: "DetailBoard") as? DetailViewController
            vcName?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
            vcName?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
            vcName?.id = selectedId
            self.present(vcName!, animated: true, completion: nil)
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
    
    
    func timeAgoSinceUploaded(uploadTime: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd HH:mm:ss" // uploadtime의 형식에 맞게 설정
        
        guard let uploadDate = dateFormatter.date(from: uploadTime) else {
            return "" // 날짜 변환 실패 시 빈 문자열 반환
        }
        
        let currentDate = Date()
        let calendar = Calendar.current
        
        let components = calendar.dateComponents([.minute], from: uploadDate, to: currentDate)
        if let minutes = components.minute {
            if minutes < 1 {
                return "방금 전"
            } else if minutes < 60 {
                return "\(minutes)분 전"
            } else {
                let hours = minutes / 60
                if hours < 24 {
                    return "\(hours)시간 전"
                } else {
                    let days = hours / 24
                    return "\(days)일 전"
                }
            }
        }
        
        return "" // 처리못한경우 nil값 반환
    }
}
