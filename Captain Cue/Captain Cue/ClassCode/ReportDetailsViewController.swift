//
//  ReportDetailsViewController.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/6/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import UIKit
import RealmSwift

class ReportDetailsViewController: UIViewController {

    @IBOutlet weak var tbvReportContent: UITableView!
    
    var reportDatas: [ReportModel]!
    var shotResult: [ShotModel]?
    
    var holdCount: Int = 0
    
    var longestHold: Int = 0
    var longestMiss: Int = 0
    var technicallyCount: Int = 0
    
    var missSingleColorCount: Int = 0
    var missMixColorCount: Int = 0
    
    var leftMissCount: Int = 0
    var rightMissCount: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDatas()
    }
    
    func setupViews() {
        
        tbvReportContent.dataSource = self
        tbvReportContent.delegate = self
        
        tbvReportContent.register(UITableViewCell.self, forCellReuseIdentifier: Constants.ReportDetailsVC.tbvCellID)
    }
    
    func setupDatas() {
        holdCount = 0
        
        longestHold = 0
        longestMiss = 0
        technicallyCount = 0
        
        missSingleColorCount = 0
        missMixColorCount = 0
        
        leftMissCount = 0
        rightMissCount = 0
        
        var idList: [String] = []
        for item in reportDatas {
            idList.append(item.id)
        }
        
        shotResult = DataServiceManager.shared.getShotData(from: idList).sorted(by: {$0.time < $1.time})//ShotModel.getAllData(from: idList).sorted(byKeyPath: Constants.ShotModel.Properties.time.rawValue, ascending: true)
        
        guard let shotResult = shotResult else { return }
        
        var tempLongestHold = 0
        var tempLongestMiss = 0
        
        for item in shotResult {
            
            if item.result != ResultType.hold.rawValue {
                tempLongestHold = 0
                
                if item.ballNumber <= 8 && item.ballNumber > 0 {
                    missSingleColorCount += 1
                } else if item.ballNumber <= 15 {
                    missMixColorCount += 1
                }
            }
            
            switch item.result {
                
            case ResultType.left.rawValue:
                tempLongestMiss += 1
                longestMiss = max(longestMiss, tempLongestMiss)
                leftMissCount += 1
                
            case ResultType.leftHold.rawValue:
                tempLongestMiss += 1
                longestMiss = max(longestMiss, tempLongestMiss)
                leftMissCount += 1
                
            case ResultType.hold.rawValue:
                holdCount += 1
                tempLongestHold += 1
                longestHold = max(longestHold, tempLongestHold)
                tempLongestMiss = 0
                technicallyCount = item.technicallyShot == TechnicallyShotType.technicallyShot.rawValue ? technicallyCount + 1 : technicallyCount
                
            case ResultType.righHold.rawValue:
                tempLongestMiss += 1
                longestMiss = max(longestMiss, tempLongestMiss)
                rightMissCount += 1
                
            case ResultType.right.rawValue:
                tempLongestMiss += 1
                longestMiss = max(longestMiss, tempLongestMiss)
                rightMissCount += 1
                
            default:
                break
            }
        }
        tbvReportContent.reloadData()
        
    }
    
    @IBAction func btnAddNewWasTapped(_ sender: Any) {
        let presentHandler = PresentHandler()
        if let reportDatas = reportDatas {
            presentHandler.pushShotDetailsVC(fromVC: self, withData: reportDatas)
        }
        
    }
    
}
extension ReportDetailsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Constants.ReportDetailsVC.tbvNumberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.ReportManagerVC.tbvCellID, for: indexPath)
        var text = ""
        switch indexPath.item {
        case 0:
            text = "Tỷ lệ trúng: \(holdCount)/\(shotResult?.count ?? 0)"
            if holdCount > 0 {
                text += " = \(((Float(holdCount)/Float(shotResult?.count ?? 1))*100).clean)%"
            }
        case 1:
            text = "Chuỗi trúng: \(longestHold)"
        case 2:
            text = "Chuỗi trượt: \(longestMiss)"
        case 3:
            text = "Trúng đúng kỹ thuật: \(technicallyCount)"
        case 4:
            text = "Trượt (Khoang/Màu): \(missMixColorCount)/\(missSingleColorCount)"
        case 5:
            text = "Tỷ lệ trượt (Trái/Phải): \(leftMissCount)/\(rightMissCount)"
        case 6:
            text = "Kết quả: "
            guard let shotResult = shotResult else { break }
            for item in shotResult {
                if item.result == ResultType.hold.rawValue {
                    text += "o "
                } else {
                    text += "x "
                }
            }
            
        default:
            break
        }
        cell.textLabel?.text = text
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.ReportManagerVC.tbvCellHeight
    }
    
}

extension ReportDetailsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let presentHandler = PresentHandler()
//        if let data = reportData?[indexPath.item] {
//            presentHandler.pushReportDetailsVC(fromVC: self, withData: data)
//        }
//
//    }
}
