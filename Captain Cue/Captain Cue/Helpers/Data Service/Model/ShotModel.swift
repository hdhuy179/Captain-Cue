//
//  ShotModel.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/6/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import ObjectMapper

enum ResultType: Int {
    case left = 0, leftHold, hold, righHold, right
}

enum TechnicallyShotType: Int {
    case none = 0, technicallyShot
}

@objcMembers final class ShotModel: Object, DataServiceObjectDetail {
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
        
        self.ballNumber = _ballNumber
        self.result = _result
        self.technicallyShot = _technicallyShot
        self.mistakes = _mistakes
        self.time = _time
        self.reportID = _reportID
    }
    
    func getStringResult() -> String {
        if result < 0 || result >= Constants.resultList.count {
            return ""
        }
        return Constants.resultList[result]
    }
    
    static func restoreData(in realm: Realm = try! Realm(), data: [ShotModel]) {
        realm.beginWrite()
        realm.delete(realm.objects(ShotModel.self))
        
        for item in data {
            realm.add(item)
        }
        try! realm.commitWrite()
    }
}

extension ShotModel: FireBaseObjectDetails {
    func getJSONData() -> [String : Any] {
        let const = Constants.ShotModel.Properties.self
        var jsonResult: [String: Any] = [:]
        
        jsonResult[const.id.rawValue] = self.id
        jsonResult[const.ballNumber.rawValue] = self.ballNumber
        jsonResult[const.result.rawValue] = self.result
        jsonResult[const.technicallyShot.rawValue] = self.technicallyShot
        jsonResult[const.reportID.rawValue] = self.reportID
        
        let listMistakes: [Int] = self.mistakes.map({ $0 })
        jsonResult[const.mistakes.rawValue] = listMistakes
        
        return jsonResult
    }
    
    static func getRemoteCollectionName() -> String {
        return Constants.ShotModel.firebaseCollectionName
    }
}

//extension ShotModel {
//    static func addNew(in realm: Realm = try! Realm(), data: ShotModel) {
//        realm.beginWrite()
//        realm.add(data)
//        try! realm.commitWrite()
//    }
//
//    static func restoreData(in realm: Realm = try! Realm(), data: [ShotModel]) {
//        realm.beginWrite()
//        realm.delete(realm.objects(ShotModel.self))
//
//        for item in data {
//            realm.add(item)
//        }
//        try! realm.commitWrite()
//    }
//
//    static func getAllData(in realm: Realm = try! Realm()) -> Results<ShotModel> {
//        return realm.objects(ShotModel.self)
//    }
//
//    static func getAllData(in realm: Realm = try! Realm(), from reportID: String) -> Results<ShotModel> {
//        let predicate = NSPredicate(format: "reportID = %@", argumentArray: [reportID])
//        return realm.objects(ShotModel.self).filter(predicate)
//    }
//
//    static func getAllData(in realm: Realm = try! Realm(), from reportIDs: [String]) -> Results<ShotModel> {
//        let predicate = NSPredicate(format: "\(Constants.ShotModel.Properties.reportID) IN %@", argumentArray: [reportIDs])
//        return realm.objects(ShotModel.self).filter(predicate)
//    }
//
//    static func delete(in realm: Realm = try! Realm(), data: ShotModel) {
//        realm.beginWrite()
//        realm.delete(data)
//        try! realm.commitWrite()
//    }
//
//}

extension ShotModel: Decodable {
    
}

extension ShotModel: Mappable {
    convenience init?(map: Map) {
        self.init()
        
        self.mapping(map: map)
    }
    
    func mapping(map: Map) {
        let const = Constants.ShotModel.Properties.self
        
        self.id <- map[const.id.rawValue]
        self.ballNumber <- map[const.ballNumber.rawValue]
        self.result <- map[const.ballNumber.rawValue]
        self.technicallyShot <- map[const.technicallyShot.rawValue]
        self.reportID <- map[const.reportID.rawValue]
        
        var timestamp: Timestamp?
        timestamp <- map[const.time.rawValue]
        time = timestamp?.dateValue().getDateFormatted() ?? Date()
        
        var mistakes: [Int] = []
        mistakes <- map[const.mistakes.rawValue]
        self.mistakes.removeAll()
        self.mistakes.append(objectsIn: mistakes)
    }
    
    
    static func backupCloudData(_ data: [ShotModel], completion: @escaping ((CGFloat? ,Error?) -> ())) {

        let db = Firestore.firestore()
        let const = Constants.ShotModel.Properties.self

        var setCounter: CGFloat = 0
        var deleteCounter: CGFloat = 0
        
        getAllCouldData { (cloudData, err) in
            let totalTask = CGFloat(data.count + (cloudData?.count ?? 0))
            if cloudData?.isEmpty == true {
                if data.isEmpty {
                    completion(1, nil)
                    return
                }
                data.forEach { (shot) in
                    let listMistakes: [Int] = shot.mistakes.map({ $0 })
                    db.collection("Shot").document(shot.id).setData([const.id.rawValue: shot.id,
                                                                          const.ballNumber.rawValue: shot.ballNumber,
                                                                          const.result.rawValue: shot.result,
                                                                          const.technicallyShot.rawValue: shot.technicallyShot,
                                                                          const.time.rawValue: shot.time,
                                                                          const.reportID.rawValue: shot.reportID,
                                                                          const.mistakes.rawValue: listMistakes])
                    { err in
                        if err != nil {
                            completion(nil, err)
                        } else {
                            setCounter += 1
                            completion((setCounter + deleteCounter)/totalTask, nil)
                        }
                    }
                }
            } else if let cloudData = cloudData {
                for item in cloudData {
                    db.collection("Shot").document(item.id).delete() { err in
                        deleteCounter += 1
                        if Int(deleteCounter) == cloudData.count {
                            if data.isEmpty {
                                completion(1, nil)
                                return
                            }
                            data.forEach { (shot) in
                                let listMistakes: [Int] = shot.mistakes.map({ $0 })
                                db.collection("Shot").document(shot.id).setData([const.id.rawValue: shot.id,
                                                                                      const.ballNumber.rawValue: shot.ballNumber,
                                                                                      const.result.rawValue: shot.result,
                                                                                      const.technicallyShot.rawValue: shot.technicallyShot,
                                                                                      const.time.rawValue: shot.time,
                                                                                      const.reportID.rawValue: shot.reportID,
                                                                                      const.mistakes.rawValue: listMistakes])
                                { err in
                                    if err != nil {
                                        completion(nil, err)
                                    } else {
                                        setCounter += 1
                                        completion((setCounter + deleteCounter)/totalTask, nil)
                                    }
                                }
                            }
                        }                    }
                }
            }
        }
        
//        data.forEach { (shot) in
//            let listMistakes: [Int] = shot.mistakes.map({ $0 })
//            db.collection("Shot").document(shot.id).setData([const.id.rawValue: shot.id,
//                                                                  const.ballNumber.rawValue: shot.ballNumber,
//                                                                  const.result.rawValue: shot.result,
//                                                                  const.technicallyShot.rawValue: shot.technicallyShot,
//                                                                  const.time.rawValue: shot.time,
//                                                                  const.reportID.rawValue: shot.reportID,
//                                                                  const.mistakes.rawValue: listMistakes])
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
    
    static func getAllCouldData(completion: @escaping (([ShotModel]? ,Error?) -> ())) {
        
        let db = Firestore.firestore()
        
        var result: [ShotModel] = []
        
        db.collection("Shot").getDocuments { (snapshot, err) in
            if err != nil {
                
            } else if snapshot != nil, !snapshot!.documents.isEmpty {
                
                snapshot!.documents.forEach({ (document) in
                    if let shot = ShotModel(JSON: document.data()) {
                        result.append(shot)
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
}
