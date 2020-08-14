//
//  ViewController.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/6/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import UIKit
import RealmSwift
import M13ProgressSuite

class ReportManagerViewController: UIViewController {
    
    @IBOutlet weak var tbvReport: UITableView!
    var visualEffect: UIVisualEffectView?
    var alert: EditReportAlert?
    
    lazy var backupProgressView: M13ProgressViewRing? = nil
    
    //    var reportData: Results<ReportModel>?
    var reportData: [[ReportModel]] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        checkRestoreAbility()
        setupView()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupDatas()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func checkRestoreAbility() {
        DataServiceManager.shared.checkRestoreAbility(fromVC: self) { [weak self] err in
            if err == nil {
                self?.setupDatas()
            }
        }
    }
    
    func setupView() {
//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        tbvReport.dataSource = self
        tbvReport.delegate = self
        
        tbvReport.register(UITableViewCell.self, forCellReuseIdentifier: Constants.ReportManagerVC.tbvCellID)
        tbvReport.register(UINib(nibName: Constants.ReportManagerVC.tbvHeaderNibName, bundle: nil), forHeaderFooterViewReuseIdentifier: Constants.ReportManagerVC.tbvHeaderID)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let keyboardHeight: CGFloat
            
            if #available(iOS 11.0, *) {
                keyboardHeight = keyboardFrame.cgRectValue.height - view.safeAreaInsets.bottom
            } else {
                keyboardHeight = keyboardFrame.cgRectValue.height
            }
            //            let newY = self.view.frame.height
            alert?.transform = CGAffineTransform(translationX: 0, y: -keyboardHeight/2)
        }
    }
    @objc func keyboardWillHide(notification: NSNotification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            
            let keyboardHeight: CGFloat
            
            if #available(iOS 11.0, *) {
                keyboardHeight = keyboardFrame.cgRectValue.height - view.safeAreaInsets.bottom
            } else {
                keyboardHeight = keyboardFrame.cgRectValue.height
            }
            
            alert?.transform = CGAffineTransform(translationX: 0, y: keyboardHeight/2)
        }
    }
    
    func setupDatas() {
        reportData.removeAll()
//        let service = LocalDataService()
//        let searchResult = service.getAllDatas().sorted(byKeyPath: Constants.ReportModel.Properties.time.rawValue, ascending: false) as Results<ReportModel>
        
//        let searchResult = ReportModel.getAllData().sorted(byKeyPath: Constants.ReportModel.Properties.time.rawValue, ascending: false)
        let searchResult = DataServiceManager.shared.getAllData().sorted(by: { $0.time > $1.time}) as [ReportModel]
        
        if searchResult.isEmpty == false {
            var tempArr: [ReportModel] = []
            var currentDate = searchResult.first?.time.convertToString(withDateFormat: "dd/MM/yyyy")
            
            for item in searchResult {
                let itemDate = item.time.convertToString(withDateFormat: "dd/MM/yyyy")
                if itemDate == currentDate {
                    tempArr.append(item)
                } else {
                    currentDate = itemDate
                    reportData.append(tempArr)
                    tempArr = [item]
                }
            }
            reportData.append(tempArr)
        }
        
        tbvReport.reloadData()
    }
    
    @IBAction func btnAddNewWasTapped(_ sender: Any) {
        let component = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        let date = Calendar.current.date(from: component) ?? Date()
        let dateStr = Date().convertToString(withDateFormat: "yyyy_MM_dd")
        
        let no = (reportData.first?.filter({ $0.time > date }).count ?? 0) + 1
        
        var report = ReportModel(_title: "\(dateStr)_\(no)", _time: Date())
        if no < 10 {
            report = ReportModel(_title: "\(dateStr)_0\(no)", _time: Date())
        }

//        ReportModel.addNew(data: report)
        DataServiceManager.shared.addObject(data: report, completion: nil)
        let presentHandler = PresentHandler()
        presentHandler.pushReportDetailsVC(fromVC: self, withData: [report])
        tbvReport.reloadData()
        
//        let calendar = Calendar.current
//        if let component = calendar.date(byAdding: .day, value: 1, to: Date()) {
//            let date = component.convertToString(withDateFormat: "yyyy_MM_dd")
//            let no = (reportData.first?.filter({ $0.time.convertToString(withDateFormat: "yyyy_MM_dd").contains(date)}).count ?? 0 ) + 1
//            var report = ReportModel(_title: "\(date)_\(no)", _time: component)
//            if no < 10 {
//                report = ReportModel(_title: "\(date)_0\(no)", _time: component)
//            }
//
//            ReportModel.addNew(data: report)
//            let presentHandler = PresentHandler()
//            presentHandler.pushReportDetailsVC(fromVC: self, withData: report)
//            tbvReport.reloadData()
//        }
    }
    
    @IBAction func btnBackupWasTapped(_ sender: Any) {
        self.showConfirmAlert(title: "Back up", message: "Mọi dữ liệu trên server sẽ được thay thế bằng dữ liệu trên máy của bạn. Bạn có muốn tiếp tục không?") {
            
            let width: CGFloat = 50
            let height: CGFloat = 50
            let backupProgressView = M13ProgressViewRing(frame: CGRect(x: (UIScreen.main.bounds.width - width)/2, y: (UIScreen.main.bounds.height - height)/2, width: width, height: height))
            let fadedView = UIVisualEffectView(frame: UIScreen.main.bounds)
            fadedView.effect = UIBlurEffect(style: .dark)
            fadedView.alpha = 0.4
            self.navigationController?.view.addSubview(fadedView)
            self.navigationController?.view.addSubview(backupProgressView)
            
            DataServiceManager.shared.backupData { [weak self] progress, err in
                if let _ = err {
                    backupProgressView.removeFromSuperview()
                    fadedView.removeFromSuperview()
                    self?.showAlert(title: "Back up error", message: "Đã xảy ra lỗi trong quá trình backup dữ liệu.")
                    return
                    
                } else if let progress = progress {
                    backupProgressView.setProgress(progress, animated: true)
                    
                    if progress == 1 {
                        backupProgressView.perform(M13ProgressViewActionSuccess, animated: true)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
                            backupProgressView.removeFromSuperview()
                            fadedView.removeFromSuperview()
                            self?.showAlert(title: "Back up", message: "Mọi dữ liệu đã được back up lên server")
                            return
                        }
                    }
                }
            }
        }
//        self.showConfirmAlert(title: "Back up", message: "Mọi dữ liệu trên server sẽ được thay thế bằng dữ liệu trên máy của bạn. Bạn có muốn tiếp tục không?") {
//
//            let width: CGFloat = 50
//            let height: CGFloat = 50
//            let backupProgressView = M13ProgressViewRing(frame: CGRect(x: (UIScreen.main.bounds.width - width)/2, y: (UIScreen.main.bounds.height - height)/2, width: width, height: height))
//            let fadedView = UIVisualEffectView(frame: UIScreen.main.bounds)
//            fadedView.effect = UIBlurEffect(style: .dark)
//            fadedView.alpha = 0.4
//            self.navigationController?.view.addSubview(fadedView)
//            self.navigationController?.view.addSubview(backupProgressView)
//
//            let allReportData: [ReportModel] = DataServiceManager.shared.getAllData()//ReportModel.getAllData().map({ $0 })
//
//            var progressReport: CGFloat = 0
//            var progressShot: CGFloat = 0
//
//            ReportModel.backupCloudData(allReportData) { [weak self] progress, err  in
//                if let progress = progress {
//                    progressReport = progress
//
//                    backupProgressView.setProgress(progressReport/2.0 + progressShot/2.0, animated: true)
//                    if progressReport == 1 && progressShot == 1 {
//                        backupProgressView.perform(M13ProgressViewActionSuccess, animated: true)
//                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
//                            self?.showAlert(title: "Back up", message: "Mọi dữ liệu đã được back up lên server")
//                            backupProgressView.removeFromSuperview()
//                            fadedView.removeFromSuperview()
//
//                            return
//                        }
//
//                    }
//                }
//
//            }
//            let allShotData: [ShotModel] = DataServiceManager.shared.getAllData()//ShotModel.getAllData().map({$0})
//            ShotModel.backupCloudData(allShotData) { [weak self] progress, err in
//
//                if let progress = progress {
//                    progressShot = progress
//
//                    backupProgressView.setProgress(progressReport/2.0 + progressShot/2.0, animated: true)
//                    if progressReport == 1 && progressShot == 1 {
//                        backupProgressView.perform(M13ProgressViewActionSuccess, animated: true)
//                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
//                            self?.showAlert(title: "Back up", message: "Mọi dữ liệu đã được back up lên server")
//                            backupProgressView.removeFromSuperview()
//                            fadedView.removeFromSuperview()
//
//                            return
//                        }
//
//                    }
//                }
//
//            }
//        }
    }
    
}

extension ReportManagerViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return reportData.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reportData[section].count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: Constants.ReportManagerVC.tbvHeaderID) as? ReportHeaderView,
            let date = reportData[section].first?.time {
            header.configView(_date: date, _section: section)
            header.delegate = self
            return header
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ReportManagerVC.tbvCellID, for: indexPath)
        cell.textLabel?.text = reportData[indexPath.section][indexPath.item].title
        return cell
    }
    
}

extension ReportManagerViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.ReportManagerVC.tbvCellHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        if reportData.isEmpty || reportData.first?.isEmpty == true {
//            return 0
//        }
        if reportData.isEmpty {
            return 0
        }
        return Constants.ReportManagerVC.tbvHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let presentHandler = PresentHandler()
        let data = reportData[indexPath.section][indexPath.item]
        presentHandler.pushReportDetailsVC(fromVC: self, withData: [data])
        
        
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Xoá") { (_, _) in
            self.showConfirmAlert(title: "Xoá", message: "Bạn có chắc muốn xoá báo cáo này không?") {
                let data = self.reportData[indexPath.section][indexPath.item]
//                ReportModel.delete(data: data)
                DataServiceManager.shared.deleteObject(data: data)
                self.setupDatas()
                self.tbvReport.reloadData()
                
                
            }
        }
        let edit = UITableViewRowAction(style: .normal, title: "Sửa") { (_, _) in
            
            let repData = self.reportData[indexPath.section][indexPath.item]
            
            let nib = UINib(nibName: Constants.ReportManagerVC.alertNibName, bundle: nil)
            self.alert = nib.instantiate(withOwner: self, options: nil).first as? EditReportAlert
            if let alert = self.alert {
                
                alert.configView(_reportData: repData)
                alert.delegate = self
                
                let width: CGFloat = UIScreen.main.bounds.width*2/3
                let height: CGFloat = 300
                let x = (UIScreen.main.bounds.width - width)/2
                let y = (UIScreen.main.bounds.height - height)/2
                alert.frame = CGRect(x: x, y: y, width: width, height: height)
                
                self.visualEffect = UIVisualEffectView(frame: UIScreen.main.bounds)
                self.visualEffect?.effect = UIBlurEffect(style: .dark)
                self.visualEffect?.alpha = 0.4
                
                self.navigationController?.view.addSubview(self.visualEffect!)
                
                self.navigationController?.view.addSubview(alert)
            }
        }
        return [delete, edit]
    }
}

extension ReportManagerViewController: EditReportAlertDelegate {
    func btnConfirmWasTapped(in alert: EditReportAlert, title: String, desc: String, for report: ReportModel) {
        if let newReport = report.copy() as? ReportModel {
            newReport.title = title
            newReport.desc = desc
            
//            ReportModel.update(data: newReport)
            DataServiceManager.shared.updateObject(data: newReport)
            tbvReport.reloadData()
        }
        visualEffect?.removeFromSuperview()
        alert.removeFromSuperview() 
    }
    
    
    func btnCancelWasTapped(in alert: EditReportAlert) {
        visualEffect?.removeFromSuperview()
        alert.removeFromSuperview()
    }
}

extension ReportManagerViewController: ReportHeaderViewDelegate {
    func headerWasTapped(inSection secion: Int) {
        let presentHandler = PresentHandler()
        presentHandler.pushReportDetailsVC(fromVC: self, withData: reportData[secion])
    }
    
}
