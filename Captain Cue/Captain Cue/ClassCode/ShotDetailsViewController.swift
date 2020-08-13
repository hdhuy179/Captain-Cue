//
//  ShotDetailsViewController.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/6/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import UIKit
import RealmSwift

class ShotDetailsViewController: UIViewController {
    
    @IBOutlet weak var btnAddNew: UIBarButtonItem!
    @IBOutlet weak var tbvReportContent: UITableView!
    
    var visualEffect: UIVisualEffectView?
    var alert: EditReportAlert?
    
    var reportDatas: [ReportModel]!
    var shotResult: [ShotModel]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupDatas()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func setupViews() {
        if reportDatas.count > 1 {
            btnAddNew.isEnabled = false
        } else {
            btnAddNew.isEnabled = reportDatas.first?.time.convertToString(withDateFormat: "dd/MM/yyyy") == Date().convertToString(withDateFormat: "dd/MM/yyyy")
        }
        
        tbvReportContent.dataSource = self
        tbvReportContent.delegate = self
        
        tbvReportContent.register(UINib(nibName: Constants.ShotDetailsVC.tbvCellNibName, bundle: nil), forCellReuseIdentifier: Constants.ShotDetailsVC.tbvCellID)
        tbvReportContent.register(UITableViewCell.self, forCellReuseIdentifier: Constants.ShotDetailsVC.tbvDescCellID)
        
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
        var idList: [String] = []
        for item in reportDatas {
            idList.append(item.id)
        }
        
//        shotResult = ShotModel.getAllData(from: idList).sorted(byKeyPath: Constants.ShotModel.Properties.time.rawValue, ascending: true)
        shotResult = DataServiceManager.shared.getShotData(from: idList).sorted(by: {$0.time < $1.time})
        if reportDatas.count > 1 {
            navigationItem.title = (reportDatas?.first?.time.convertToString(withDateFormat: "yyyy_MM_dd"))
        } else {
            navigationItem.title = (reportDatas?.first?.title ?? "")
        }

        tbvReportContent.reloadData()
    }

    @IBAction func btnAddNewWasTapped(_ sender: Any) {
        let presentHandler = PresentHandler()
        if let data = reportDatas.first, reportDatas.count == 1 {
            presentHandler.pushCreateNewShotVC(fromVC: self, withData: data)
        }
        
    }
}

extension ShotDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reportDatas.count == 1 {
            return (shotResult?.count ?? 0) + 1
        }
        return (shotResult?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if reportDatas.count > 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ShotDetailsVC.tbvCellID, for: indexPath) as? ShotRecordTableViewCell,
                let shotResult = shotResult else { fatalError()}
            cell.configView(data: shotResult[indexPath.item])
            return cell
        }
        
        if let data = reportDatas.first ,indexPath.item == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ShotDetailsVC.tbvDescCellID, for: indexPath)
            let desc = data.desc.isEmpty ? "\"Trống\"" : data.desc
            cell.textLabel?.text = "Mô tả: " + desc
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.numberOfLines = 6
            return cell
        }
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ShotDetailsVC.tbvCellID, for: indexPath) as? ShotRecordTableViewCell,
            let shotResult = shotResult else { fatalError()}
        cell.configView(data: shotResult[indexPath.item-1])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.ReportManagerVC.tbvCellHeight
    }
    
}

extension ShotDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if indexPath.item == 0 {
            return true
        }
        return false
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let reportData = reportDatas.first, reportDatas.count == 1 else { return }
        let nib = UINib(nibName: Constants.ReportManagerVC.alertNibName, bundle: nil)
        self.alert = nib.instantiate(withOwner: self, options: nil).first as? EditReportAlert
        if let alert = self.alert {
            
            alert.configView(_reportData: reportData)
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
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if indexPath.item == 0 || reportDatas.count > 1{
            return nil
        }
        let delete = UITableViewRowAction(style: .destructive, title: "Xoá") { (_, _) in
            self.showConfirmAlert(title: "Xoá", message: "Bạn có chắc muốn xoá không?") {
                if let data = self.shotResult?[indexPath.item-1] {
                    DataServiceManager.shared.deleteObject(data: data)
//                    ShotModel.delete(data: data)
                    
                    self.setupDatas()
                }

            }
        }
        return [delete]
    }
}
extension ShotDetailsViewController: EditReportAlertDelegate {
    func btnConfirmWasTapped(in alert: EditReportAlert, title: String, desc: String, for report: ReportModel) {
        if let newReport = report.copy() as? ReportModel {
            newReport.title = title
            newReport.desc = desc
            
            DataServiceManager.shared.updateObject(data: newReport)
//            ReportModel.update(data: newReport)
            setupDatas()
        }
        visualEffect?.removeFromSuperview()
        alert.removeFromSuperview()
    }
    
    
    func btnCancelWasTapped(in alert: EditReportAlert) {
        visualEffect?.removeFromSuperview()
        alert.removeFromSuperview()
    }
}
