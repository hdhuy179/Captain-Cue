//
//  EditReportAlert.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/7/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import UIKit
import Material

protocol EditReportAlertDelegate: class {
    func btnConfirmWasTapped(in alert: EditReportAlert, title: String, desc: String, for report: ReportModel)
    func btnCancelWasTapped(in alert: EditReportAlert)
}

class EditReportAlert: UIView {

    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var txtReportTitle: UITextField!
    @IBOutlet weak var txtvReportDescription: UITextView!
    
    weak var delegate: EditReportAlertDelegate?
    var reportData: ReportModel!
    
    func configView(_reportData: ReportModel) {
        txtReportTitle.text = _reportData.title
        txtvReportDescription.text = _reportData.desc
        reportData = _reportData
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.cornerRadius = 10
        self.txtvReportDescription.layer.cornerRadius = 5
        txtvReportDescription.becomeFirstResponder()
    }
    @IBAction func btnConfirmWasTapped(_ sender: Any) {
        let title = txtReportTitle.text ?? ""
        let desc = txtvReportDescription.text ?? ""
        delegate?.btnConfirmWasTapped(in: self, title: title, desc: desc, for: reportData)
    }
    @IBAction func btnCancelWasTapped(_ sender: Any) {
        delegate?.btnCancelWasTapped(in: self)
    }
    
}
