//
//  Constant.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/6/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
    struct ReportManagerVC {
        static let alertNibName = "EditReportAlert"
        
        static let tbvCellID = "TableviewCell"
        static let tbvCellHeight: CGFloat = 50
        
        static let tbvHeaderNibName = "ReportHeaderView"
        static let tbvHeaderID = "ReportHeaderView"
        static let tbvHeaderHeight: CGFloat = 35
    }
    
    struct CreateNewShotVC {
        static let clsvCellID = "BallCollectionViewCell"
        static let clsvNibName = "BallCollectionViewCell"
        static let clsvNumberOfColumn: Int = 5
        static let clsvNumberOfItems: Int = 15
    }
    
    struct ShotDetailsVC {
        static let tbvDescCellID = "TableviewCell"
//        static let tbvDescCellNibName = "TableviewCell"
        static let tbvCellID = "ShotRecordTableViewCell"
        static let tbvCellNibName = "ShotRecordTableViewCell"
        static let tbvCellHeight: CGFloat = 50
    }
    
    struct ReportDetailsVC {
        static let tbvCellID = "TableviewCell"
        static let tbvCellHeight: CGFloat = 50
        static let tbvNumberOfRows: Int = 7
    }
    
    struct ReportModel {
        enum Properties: String {
            case id, title, time
        }
    }
    
    struct ShotModel {
        enum Properties: String {
            case id, ballNumber, result, technicallyShot, time, reportID
        }
    }
}
