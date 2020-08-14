//
//  ReportModel.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/6/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import ObjectMapper

@objcMembers final class ReportModel: Object, DataServiceObjectDetail {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var title: String = ""
    @objc dynamic var desc: String = ""
    @objc dynamic var time: Date = Date()
    
    override static func primaryKey() -> String? {
        return Constants.ReportModel.Properties.id.rawValue
    }
    
    convenience init(_title: String, _desc: String = "", _time: Date) {
        self.init()
        
        self.title = _title
        self.desc = _desc
        self.time = _time
    }
}

extension ReportModel: FireBaseObjectDetails {
    static func getRemoteCollectionName() -> String {
        return Constants.ReportModel.firebaseCollectionName
    }
    func getJSONData() -> [String: Any] {
        
        let const = Constants.ReportModel.Properties.self
        var jsonResult: [String: Any] = [:]
        
        jsonResult[const.id.rawValue] = id
        jsonResult[const.title.rawValue] = title
        jsonResult[const.desc.rawValue] = desc
        jsonResult[const.time.rawValue] = time
        
        return jsonResult
    }
}

extension ReportModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let newObj =  ReportModel(_title: self.title, _desc: self.desc, _time: self.time)
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
        
        var timestamp: Timestamp?
        timestamp <- map[const.time.rawValue]
        time = timestamp?.dateValue().getDateFormatted() ?? Date()
    }

}
