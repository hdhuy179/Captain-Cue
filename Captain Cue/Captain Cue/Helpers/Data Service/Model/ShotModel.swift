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
}
extension ShotModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let newObj =  ShotModel(_ballNumber: self.ballNumber, _result: self.result, _technicallyShot: self.technicallyShot, _mistakes: self.mistakes, _time: self.time, _reportID: self.reportID)
        newObj.id = id
        return newObj
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
        self.result <- map[const.result.rawValue]
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
}
