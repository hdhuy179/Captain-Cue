//
//  ShotModel.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/6/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import Foundation
import RealmSwift

enum ResultType: Int {
    case left = 0, leftHold, hold, righHold, right
}

enum TechnicallyShotType: Int {
    case none = 0, technicallyShot
}

@objcMembers class ShotModel: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var ballNumber: Int = -1
    @objc dynamic var result: Int = -1
    @objc dynamic var technicallyShot: Int = -1
    @objc dynamic var time: Date = Date()
    @objc dynamic var reportID: String = ""
    
    var mistakes: List<Int> = List<Int>()
    
    override static func primaryKey() -> String? {
        return Constants.ShotModel.Properties.id.rawValue
    }
    
    convenience init(_ballNumber: Int, _result: Int, _technicallyShot: Int, _mistakes: List<Int>, _time: Date, _reportID: String) {
        self.init()
        ballNumber = _ballNumber
        result = _result
        technicallyShot = _technicallyShot
        mistakes = _mistakes
        time = _time
        reportID = _reportID
    }
    
    func getStringResult() -> String {
        switch result {
        case 0:
            return "Trái"
        case 1:
            return "Lắc trái"
        case 2:
            return "Trúng"
        case 3:
            return "Lắc phải"
        case 4:
            return "Phải"
        default:
            break
        }
        return ""
    }
}

extension ShotModel {
    static func addNew(in realm: Realm = try! Realm(), data: ShotModel) {
        realm.beginWrite()
        realm.add(data)
        try! realm.commitWrite()
    }
    
    static func getAllData(in realm: Realm = try! Realm(), from reportID: String) -> Results<ShotModel> {
        let predicate = NSPredicate(format: "reportID = %@", argumentArray: [reportID])
        return realm.objects(ShotModel.self).filter(predicate)
    }
    
    static func getAllData(in realm: Realm = try! Realm(), from reportIDs: [String]) -> Results<ShotModel> {
        let predicate = NSPredicate(format: "\(Constants.ShotModel.Properties.reportID) IN %@", argumentArray: [reportIDs])
        return realm.objects(ShotModel.self).filter(predicate)
    }
    
    static func delete(in realm: Realm = try! Realm(), data: ShotModel) {
        realm.beginWrite()
        realm.delete(data)
        try! realm.commitWrite()
    }
}


