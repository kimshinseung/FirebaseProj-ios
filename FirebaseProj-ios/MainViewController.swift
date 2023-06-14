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
    }
    
    var data: [Item] = [] //파이어베이스에서 가져오는 데이터 저장
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fsCalender.dataSource = self                // 칼렌다의 데이터소스로 등록
        fsCalender.delegate = self
        
        TableView.dataSource = self
        TableView.delegate = self
        //TableView.isEditing = true
        
        if(selectdate.text == ""){
            selectdate.text = Date().toStringDate()
        }
        
    }
    //뷰가 나올때마다 데이터를 가져온다.
    override func viewWillAppear(_ animated: Bool) {
        getData()
    }
    
    func GoBoard(des: String){
        let vcName = self.storyboard?.instantiateViewController(withIdentifier: des)
                vcName?.modalPresentationStyle = .fullScreen //전체화면으로 보이게 설정
                vcName?.modalTransitionStyle = .crossDissolve //전환 애니메이션 설정
                self.present(vcName!, animated: true, completion: nil)
    }
    // 파이어스토어에서 데이터 가져오기
       func getData() {
           let db = Firestore.firestore()
           //업로드시간순으로 내림차순 정렬
           db.collection("Data").order(by: "uploadtime", descending: true).getDocuments { (snapshot, error) in
               if let error = error {
                   print("데이터 가져오기 실패: \(error.localizedDescription)")
                   return
               }
               
               guard let documents = snapshot?.documents else {
                   print("문서가 없습니다.")
                   return
               }
               
               self.data = documents.compactMap { document in
                               guard let name = document.data()["name"] as? String,
                                     let price = document.data()["price"] as? Int,
                                    let uploadtime = document.data()["uploadtime"] as? String else {
                                   return nil
                               }
                               return Item(name: name, price: price, uploadtime: uploadtime)
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
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        // 스와이프로 월이 변경되면 호출된다
        selectedDate = calendar.currentPage
        //planGroup.queryData(date: calendar.currentPage)
    }
    
    // 이함수를 fsCalendar.reloadData()에 의하여 모든 날짜에 대하여 호출된다.
    func calendar(_ calendar: FSCalendar, subtitleFor date: Date) -> String? {
//        let plans = planGroup.getPlans(date: date)
//        if plans.count > 0 {
//            return "[\(plans.count)]"    // date에 해당한 plans의 갯수를 뱃지로 출력한다
//        }
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
       
        (cell.contentView.subviews[0] as! UILabel).text = item.uploadtime
        (cell.contentView.subviews[1] as! UILabel).text = item.name
        (cell.contentView.subviews[2] as! UILabel).text = String(item.price)
        
        return cell
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
