//
//  OfflineStorageModel.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/12/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import Foundation

enum MenthodType: Int {
    case create = 0, update, delete
}

@objcMembers final class OfflineStorageModel: Object, DataServiceObjectDetail {
    @objc dynamic var id: String = UUID().uuidString
    @objc dynamic var collectionName: String = ""
    @objc dynamic var menthodType: Int = -1
    @objc dynamic var objectID: String = ""
    
    override class func primaryKey() -> String? {
        return Constants.OfflineStorageModel.Properties.id.rawValue
    }
    
    convenience init(_collectionName: String, _menthodType: MenthodType, _objectID: String) {
        self.init()
        
        self.collectionName = _collectionName
        self.menthodType = getMenthodValue(from: _menthodType)
        self.objectID = _objectID
    }
    
    convenience init(_collectionName: String, _menthodType: Int, _objectID: String) {
        self.init()
        
        self.collectionName = _collectionName
        self.menthodType = _menthodType
        self.objectID = _objectID
    }
    
    func getMenthodValue(from menthod: MenthodType) -> Int {
        switch menthod {
        case .create:
            return 0
        case .update:
            return 1
        case .delete:
            return 2
        }
    }
    
    func getMenthod() -> MenthodType? {
        switch menthodType {
        case 0:
            return .create
        case 1:
            return .update
        case 2:
            return .delete
        default:
            return nil
        }
    }
}

extension OfflineStorageModel: NSCopying {
    func copy(with zone: NSZone? = nil) -> Any {
        let newObj = OfflineStorageModel(_collectionName: self.collectionName, _menthodType: self.menthodType, _objectID: self.objectID)
        newObj.id = self.id
        return newObj
    }
    
    
}
