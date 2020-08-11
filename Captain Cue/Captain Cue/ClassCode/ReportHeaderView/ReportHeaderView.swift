//
//  ReportHeaderView.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/7/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import UIKit
import M13Checkbox

protocol ReportHeaderViewDelegate: class {
    func headerWasTapped(inSection secion: Int)
}

class ReportHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var lbDate: UILabel!
    
    weak var delegate: ReportHeaderViewDelegate?
    
    var section: Int!
    
    func configView(_date: Date, _section: Int) {
        lbDate.text = _date.convertToString(withDateFormat: "'Ngày' dd 'tháng' MM 'năm' yyyy")
        section = _section
        
        self.backgroundColor = .lightGray
    }
    
    @IBAction func btnHeaderWasTapped(_ sender: Any) {
        delegate?.headerWasTapped(inSection: section)
    }
}
