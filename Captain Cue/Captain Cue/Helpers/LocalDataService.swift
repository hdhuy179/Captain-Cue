//
//  DataService.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/10/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import Foundation
import RealmSwift

protocol DataService {
//    func getData (byID id: Any, completion: )
}

class LocalDataService: DataService {
    
    private var realm: Realm
    
    init(_realm: Realm = try! Realm()) {
        self.realm = _realm
    }
    
    func convertToModel<T: Object> (_ data: Results<T>) -> [T]{
        return data.map({ $0})
    }
    
    func getData<T: Object> (byID id: Any, completion: @escaping ((T?, Error?) -> ())) {
        completion(realm.object(ofType: T.self, forPrimaryKey: id), nil)
    }
    
    func getAllDatas<T: Object> () -> [T] {
        
        let result = realm.objects(T.self)
        return convertToModel(result)
    }
    
    func addObject<T: Object> (data: T) {
        
        realm.beginWrite()
        realm.add(data)
        try! realm.commitWrite()
    }
    
    func updateObject<T: Object> (data: T) {
        
        realm.beginWrite()
        realm.add(data, update: .modified)
        try! realm.commitWrite()
    }
    
    func getShotDatas(from reportID: String) -> [ShotModel] {
        
        let predicate = NSPredicate(format: "\(Constants.ShotModel.Properties.reportID) = %@", argumentArray: [reportID])
        let result = realm.objects(ShotModel.self).filter(predicate)
        return convertToModel(result)
    }
    
    func getShotDatas(from reportIDs: [String]) -> [ShotModel] {
        
        let predicate = NSPredicate(format: "\(Constants.ShotModel.Properties.reportID) IN %@", argumentArray: [reportIDs])
        let result = realm.objects(ShotModel.self).filter(predicate)
        return convertToModel(result)
    }
    
    func deleteObject(data: ShotModel) {
        realm.beginWrite()
        print("Will deleted shot: ", data.id)
        realm.delete(data)
        try! realm.commitWrite()
    }
    
    func deleteObject(data: ReportModel) {
        realm.beginWrite()
        for item in ShotModel.getAllData(from: data.id) {
            print("Will deleted shot: ", item.id)
            realm.delete(item)
        }
        print("Will deleted report: ", data.id)
        realm.delete(data)
        try! realm.commitWrite()
    }
}
