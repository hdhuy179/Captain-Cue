//
//  ShotRecordTableViewCell.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/7/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import UIKit

class ShotRecordTableViewCell: UITableViewCell {

    @IBOutlet weak var imvBall: UIImageView!
    @IBOutlet weak var lbResult: UILabel!
    @IBOutlet weak var lbTime: UILabel!
    
    func configView(data: ShotModel) {
        let imageName = "Ball\(data.ballNumber)"
        imvBall.image = UIImage(named: imageName)
        lbResult.text = data.getStringResult()
        lbTime.text = data.time.convertToString(withDateFormat: "HH:mm:ss")
    }
    
}
