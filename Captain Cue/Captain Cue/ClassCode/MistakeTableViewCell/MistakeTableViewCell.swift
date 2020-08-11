//
//  MistakeTableViewCell.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/11/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import UIKit
import M13Checkbox

class MistakeTableViewCell: UITableViewCell {

    @IBOutlet weak var ckbMistake: M13Checkbox!
    @IBOutlet weak var lbMistake: UILabel!
    
    func configView(index: Int, isSelected: Bool) {
        lbMistake.text = MistakeType.allCases[index].rawValue
        if isSelected {
            ckbMistake.setCheckState(.checked, animated: false)
        } else {
            ckbMistake.setCheckState(.unchecked, animated: false)
        }
        
        ckbMistake.tintColor = .systemBlue
    }
    
    func configDisabledView(index: Int) {
        lbMistake.text = MistakeType.allCases[index].rawValue
        ckbMistake.setCheckState(.mixed, animated: false)
        ckbMistake.tintColor = .lightGray
    }
    
    func cellWasTapped() {
        switch ckbMistake.checkState {
        case .unchecked:
            ckbMistake.setCheckState(.checked, animated: true)
        case .checked:
            ckbMistake.setCheckState(.unchecked, animated: true)
        default:
            break
        }
    }
    
//    @IBAction func btnMistakeWasTapped(_ sender: Any) {
//        switch ckbMistake.checkState {
//        case .unchecked:
//            ckbMistake.setCheckState(.checked, animated: true)
//        case .checked:
//            ckbMistake.setCheckState(.unchecked, animated: true)
//        default:
//            break
//        }
//
//    }
}
