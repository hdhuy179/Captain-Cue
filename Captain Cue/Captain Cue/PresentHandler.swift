//
//  PresentHandler.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/6/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import Foundation
import UIKit

class PresentHandler {
    let main = UIStoryboard(name: "Main", bundle: nil)
    
    func pushReportDetailsVC(fromVC: UIViewController, withData data: [ReportModel]) {
        guard let vc = main.instantiateViewController(withIdentifier: "ReportDetailsViewController") as? ReportDetailsViewController else { return }
        vc.reportDatas = data
        fromVC.show(vc, sender: nil)
    }
    
    func pushCreateNewShotVC(fromVC: UIViewController, withData data: ReportModel) {
        guard let vc = main.instantiateViewController(withIdentifier: "CreateNewShotViewController") as? CreateNewShotViewController else { return }
        vc.reportData = data
        fromVC.show(vc, sender: nil)
    }
    
    func pushShotDetailsVC(fromVC: UIViewController, withData data: [ReportModel]) {
        guard let vc = main.instantiateViewController(withIdentifier: "ShotDetailsViewController") as? ShotDetailsViewController else { return }
        vc.reportDatas = data
        fromVC.show(vc, sender: nil)
    }
    
}
