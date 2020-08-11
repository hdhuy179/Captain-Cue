//
//  ReportModel.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/6/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper
import FirebaseFirestore

@objcMembers final class ReportModel: Object {
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
    
    static func restoreData(in realm: Realm = try! Realm(), data: [ReportModel]) {
        realm.beginWrite()
        realm.delete(realm.objects(ReportModel.self))
        
        for item in data {
            realm.add(item)
        }
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

extension ReportModel: Decodable {
    
}

extension ReportModel: Mappable {
    convenience init?(map: Map) {
        self.init()
        self.mapping(map: map)
    }
    
    func mapping(map: Map) {
        let const = Constants.ReportModel.Properties.self
        
        id <- map[const.id.rawValue]
        title <- map[const.title.rawValue]
        desc <- map[const.desc.rawValue]
        time <- map[const.time.rawValue]
    }
    
    static func getAllCouldData(completion: @escaping (([ReportModel]? ,Error?) -> ())) {
        
        let db = Firestore.firestore()
        
        var result: [ReportModel] = []
        
        db.collection("Report").getDocuments { (snapshot, err) in
            if err != nil {
                
            } else if snapshot != nil, !snapshot!.documents.isEmpty {
                
                snapshot!.documents.forEach({ (document) in
                    if let report = ReportModel(JSON: document.data()) {
                        result.append(report)
                    }
                    if result.count == snapshot?.documents.count {
                        completion(result, nil)
                    }
                })
                
            } else {
                completion(result, nil)
            }
        }
    }
    
    static func backupCloudData(_ data: [ReportModel], completion: @escaping ((Error?) -> ())) {
        
        let db = Firestore.firestore()
        let const = Constants.ReportModel.Properties.self
        
        var setCounter = 0
        var deleteCounter = 0
        
        getAllCouldData { (cloudDatas, err) in
            if cloudDatas?.isEmpty == true {
                data.forEach { (report) in
                    db.collection("Report").document(report.id).setData([const.id.rawValue: report.id,
                                                                         const.title.rawValue: report.title,
                                                                         const.desc.rawValue: report.desc,
                                                                         const.time.rawValue: report.time])
                    { err in
                        if err != nil {
                            completion(err)
                        } else {
                            setCounter += 1
                            if setCounter == data.count {
                                completion(nil)
                            }
                        }
                    }
                }
            } else if let cloudDatas = cloudDatas {
                for item in cloudDatas {
                    db.collection("Report").document(item.id).delete() { err in
                        deleteCounter += 1
                        if deleteCounter == cloudDatas.count {
                            data.forEach { (report) in
                                db.collection("Report").document(report.id).setData([const.id.rawValue: report.id,
                                                                                     const.title.rawValue: report.title,
                                                                                     const.desc.rawValue: report.desc,
                                                                                     const.time.rawValue: report.time])
                                { err in
                                    if err != nil {
                                        completion(err)
                                    } else {
                                        setCounter += 1
                                        if setCounter == data.count {
                                            completion(nil)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        }
        
//        data.forEach { (report) in
//            db.collection("Report").document(report.id).setData([const.id.rawValue: report.id,
//                                                                 const.title.rawValue: report.title,
//                                                                 const.desc.rawValue: report.desc,
//                                                                 const.time.rawValue: report.time])
//            { err in
//                if err != nil {
//                    completion(err)
//                } else {
//                    setCounter += 1
//                    if setCounter == data.count {
//                        completion(nil)
//                    }
//                }
//            }
//        }
        
    }
}
