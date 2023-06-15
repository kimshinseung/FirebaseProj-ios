//
//  MainViewController.swift
//  FirebaseProj-ios
//
//  Created by 김신승 on 2023/04/27.
//

import UIKit
import FirebaseAuth
import FSCalendar
import FirebaseFirestore
import FirebaseStorage

class MainViewController: UIViewController {

    @IBOutlet weak var fsCalender: FSCalendar!
    
    @IBOutlet weak var TableView: UITableView!
    
    @IBOutlet weak var selectdate: UILabel!
    
    @IBAction func Mypagebtn(_ sender: Any) {
        GoBoard(des: "MypageBoard")
    }
    @IBAction func Addbtn(_ sender: UIButton) {
        GoBoard(des: "AddBoard")
    }
    var selectedDate: Date? = Date()
    
    struct Item {
        let name: String
        let price: Int
        let uploadtime: String
        let documentID: String
        let imageURL: String
    }
    let storage = Storage.storage()
    
    var data: [Item] = [] //파이어베이스에서 가져오는 데이터 저장
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fsCalender.dataSource = self                // 칼렌다의 데이터소스로 등록
        fsCalender.delegate = self
        
        TableView.dataSource = self
        TableView.delegate = self
        //TableView.isEditing = true //바로 에디팅할수 있게 하는 코드
        TableView.estimatedRowHeight = 150
        TableView.rowHeight = 100
        
        if(selectdate.text == ""){
            selectdate.text = Date().toStringDate()
        }
        
    }
    //뷰가 나올때마다 데이터를 가져온다.
    override func viewWillAppear(_ animated: Bool) {
        getData(date: Date().toStringDate())
        selectdate.text = Date().toStringDate()
    }
    
    func GoBoard(des: String){
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: des)
        vcName?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
        vcName?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
        self.present(vcName!, animated: true, completion: nil)
    }
    // 파이어스토어에서 데이터 가져오기
    func getData(date: String) {
        let db = Firestore.firestore()
        // 종료 시간을 해당 날짜의 23:59:59으로 설정
        let endDate = date+"23:59:59"

        
        //업로드시간순으로 내림차순 정렬 및 해당 날짜의 게시물들만 보이기
        db.collection("Data").whereField("uploadtime", isGreaterThanOrEqualTo: date).whereField("uploadtime", isLessThanOrEqualTo: endDate).order(by: "uploadtime", descending: true).getDocuments { (snapshot, error) in
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
                             let uploadtime = document.data()["uploadtime"] as? String,
                             let imageURL = "nil" as? String else {
                           return nil
                       }
                       return Item(name: name, price: price, uploadtime: uploadtime,documentID: document.documentID,imageURL: imageURL)
                   }else{ //이미지가 있으면 그대로 진행
                       guard let name = document.data()["name"] as? String,
                             let price = document.data()["price"] as? Int,
                             let uploadtime = document.data()["uploadtime"] as? String,
                             let imageURL = document.data()["imageURL"] as? String else {
                           return nil
                       }
                       return Item(name: name, price: price, uploadtime: uploadtime,documentID: document.documentID,imageURL: imageURL)
                   }
               }
               self.TableView.reloadData()
           }
       }

}
extension MainViewController: FSCalendarDelegate, FSCalendarDataSource{
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // 날짜가 선택되면 호출된다
        selectedDate = date.setCurrentTime()
        selectdate.text = selectedDate?.toStringDate()
        getData(date:selectedDate?.toStringDate() ?? "")
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        // 스와이프로 월이 변경되면 호출된다
        selectedDate = calendar.currentPage
        //planGroup.queryData(date: calendar.currentPage)
    }
    
    // 이함수를 fsCalendar.reloadData()에 의하여 모든 날짜에 대하여 호출된다.
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {

        return nil
    }
}
extension MainViewController: UITableViewDataSource {

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
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
extension MainViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
//        if editingStyle == .delete{
//                    // 선택된 row의 플랜을 가져온다
//            let plan = self.planGroup.getPlans(date:selectedDate)[indexPath.row]
//                    let title = "Delete \(plan.content)"
//                    let message = "Are you sure you want to delete this item?"
//
//                    let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
//                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//                    let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action:UIAlertAction) -> Void in
//                        // 선택된 row의 플랜을 가져온다
//
//                        // 단순히 데이터베이스에 지우기만 하면된다. 그러면 꺼꾸로 데이터베이스에서 지워졌음을 알려준다
//                        self.planGroup.saveChange(plan: plan, action: .Delete)
//                    })
//
//                    alertController.addAction(cancelAction)
//                   alertController.addAction(deleteAction)
//                   present(alertController, animated: true, completion: nil) //여기서 waiting 하지 않는다
//
//
//                    // 단순히 데이터베이스에 지우기만 하면된다. 꺼꾸로 데이터베이스에서 지워졌음을 알려준다
//                    self.planGroup.saveChange(plan: plan, action: .Delete)
//                }
//            }
//            func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//
//                // 이것은 데이터베이스에 까지 영향을 미치지 않는다. 그래서 planGroup에서만 위치 변경
//                let from = planGroup.getPlans(date:selectedDate)[sourceIndexPath.row]
//                let to = planGroup.getPlans()[destinationIndexPath.row]
//                planGroup.changePlan(from: from, to: to)
//                tableView.moveRow(at: sourceIndexPath, to: destinationIndexPath)
    }
}
