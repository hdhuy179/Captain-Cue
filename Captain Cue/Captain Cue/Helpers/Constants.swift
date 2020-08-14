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
    static let resultList: [String] = ["Trái", "Lắc trái", "Trúng", "Lắc phải", "Phải"]
    
    struct ReportManagerVC {
        static let alertNibName = "EditReportAlert"
        
        static let tbvCellID = "TableviewCell"
        static let tbvCellHeight: CGFloat = 50
        
        static let tbvHeaderNibName = "ReportHeaderView"
        static let tbvHeaderID = "ReportHeaderView"
        static let tbvHeaderHeight: CGFloat = 45
    }
    
    struct CreateNewShotVC {
        static let clsvCellID = "BallCollectionViewCell"
        static let clsvNibName = "BallCollectionViewCell"
        static let clsvNumberOfColumn: Int = 5
        static let clsvNumberOfRow: Int = 3
        static let clsvNumberOfItems: Int = 15
        
        static let tbvCellID = "MistakeTableViewCell"
        static let tbvNibName = "MistakeTableViewCell"
        static let tbvCellHeight: CGFloat = 44
    }
    
    struct ShotDetailsVC {
        static let tbvDescCellID = "TableviewCell"
        static let tbvCellID = "ShotRecordTableViewCell"
        static let tbvCellNibName = "ShotRecordTableViewCell"
        static let tbvCellHeight: CGFloat = 50
    }
    
    struct ReportDetailsVC {
        static let tbvCellID = "TableviewCell"
        static let tbvCellHeight: CGFloat = 70
        static let tbvNumberOfRows: Int = 7
    }
    
    struct ReportModel {
        static let firebaseCollectionName = "Report"
        enum Properties: String {
            case id, title, desc, time
        }
    }
    
    struct ShotModel {
        static let firebaseCollectionName = "Shot"
        enum Properties: String {
            case id, ballNumber, result, technicallyShot, time, reportID, mistakes
        }
    }
    
    struct OfflineStorageModel {
        enum Properties: String {
            case id, collectionName, menthodType, objectID
        }
    }
}
