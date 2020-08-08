//
//  ReportModel.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/6/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import Foundation
import RealmSwift

@objcMembers class ReportModel: Object {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var desc: String = ""
    @objc dynamic var time: Date = Date()
    
    override static func primaryKey() -> String? {
        return Constants.ReportModel.Properties.id.rawValue
    }
    
    convenience init(_title: String, _desc: String = "", _time: Date) {
        self.init()
        title = _title
        desc = _desc
        time = _time
    }
}

extension ReportModel {
    
    static func getAllData(in realm: Realm = try! Realm()) -> Results<ReportModel> {
        return realm.objects(ReportModel.self)
    }
    
    static func addNew(in realm: Realm = try! Realm(), data: ReportModel) {
        realm.beginWrite()
        realm.add(data)
        try! realm.commitWrite()
    }
    
    static func update(in realm: Realm = try! Realm(), data: ReportModel) {
        realm.beginWrite()
        realm.add(data, update: .all)
        try! realm.commitWrite()
    }
    
    static func delete(in realm: Realm = try! Realm(), data: ReportModel) {
        realm.beginWrite()
        for item in ShotModel.getAllData(from: data.id) {
            print("Deleted shot: ", item.id)
            realm.delete(item)
        }
        print("Deleted report: ", data.id)
        realm.delete(data)
        try! realm.commitWrite()
    }
}
extension ReportModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let newObj =  ReportModel(_title: title, _desc: desc, _time: time)
        newObj.id = id
        return newObj
    }
    
}
