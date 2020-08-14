//
//  DataService.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/10/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

protocol LocalDataService {
    func isDatabaseEmpty() -> Bool
    
    func getData<T : LocalDataObject>(byID id: String) -> T?

    func getAllDatas<T : LocalDataObject>() -> [T]

    func addObject<T : LocalDataObject>(data: T)

    func updateObject<T : LocalDataObject>(data: T)

    func getShotData(from reportID: String) -> [ShotModel]

    func getShotData(from reportIDs: [String]) -> [ShotModel]
    
    func getOfflineStore(ofObjID id: String) -> [OfflineStorageModel]

    func deleteObject<T: LocalDataObject> (data: T)
    
    func restoreData<T: LocalDataObject> (data: [T])
}

typealias LocalDataObject = Object & DataServiceObjectDetail

final class RealmDataService: LocalDataService {
    
    private let realm: Realm
    
    init(_realm: Realm = try! Realm()) {
        self.realm = _realm
    }
    
    func isDatabaseEmpty() -> Bool {
        return realm.isEmpty
    }
    
    func convertToModel<T: LocalDataObject> (_ data: Results<T>) -> [T]{
        return data.map({ $0})
    }
    
    func getData<T: LocalDataObject> (byID id: String) -> T? {
        return realm.object(ofType: T.self, forPrimaryKey: id)
    }
    
    func getAllDatas<T: LocalDataObject> () -> [T] {
        
        let result = convertToModel(realm.objects(T.self))
        return result
    }
    
    func addObject<T: LocalDataObject> (data: T) {
        
        realm.beginWrite()
        realm.add(data)
        do {
            try realm.commitWrite()
        } catch {
        }
    }
    
    func updateObject<T: LocalDataObject> (data: T) {
        
        realm.beginWrite()
        realm.add(data, update: .modified)
        do {
            try realm.commitWrite()
        } catch {
        }
    }
    
    func getShotData (from reportID: String) -> [ShotModel] {
        
        let predicate = NSPredicate(format: "\(Constants.ShotModel.Properties.reportID) = %@", argumentArray: [reportID])
        let result = convertToModel(realm.objects(ShotModel.self).filter(predicate)) as [ShotModel]
        return result
    }
    
    func getShotData(from reportIDs: [String]) -> [ShotModel] {
        
        let predicate = NSPredicate(format: "\(Constants.ShotModel.Properties.reportID) IN %@", argumentArray: [reportIDs])
        let result = convertToModel(realm.objects(ShotModel.self).filter(predicate)) as [ShotModel]
        return result
    }
    
    func deleteObject<T: LocalDataObject>(data: T) {
//        if (getData(byID: data.id) as T?) == nil {
//            return
//        }
        realm.beginWrite()
        realm.delete(data)
        do {
            try realm.commitWrite()
        } catch {
        }
    }
    
    func getOfflineStore(ofObjID objID: String) -> [OfflineStorageModel] {
        let predicate = NSPredicate(format: "\(Constants.OfflineStorageModel.Properties.objectID) = %@", argumentArray: [objID])
        let result = convertToModel(realm.objects(OfflineStorageModel.self).filter(predicate)) as [OfflineStorageModel]
        return result
    }
    
    func restoreData<T: LocalDataObject> (data: [T]) {
        realm.beginWrite()
        realm.delete(realm.objects(T.self))
        
        for item in data {
            realm.add(item)
        }
        try! realm.commitWrite()
    }
    
//    func deleteObject(data: ShotModel, completion: @escaping ((Error?) -> ())) {
//        realm.beginWrite()
//        print("Will deleted shot: ", data.id)
//        realm.delete(data)
//        do {
//            try realm.commitWrite()
//            completion(nil)
//        } catch {
//            completion(error)
//        }
//    }
//
//    func deleteObject(data: ReportModel, completion: @escaping ((Error?) -> ())) {
//        realm.beginWrite()
//        for item in ShotModel.getAllData(from: data.id) {
//            print("Will deleted shot: ", item.id)
//            realm.delete(item)
//        }
//        print("Will deleted report: ", data.id)
//        realm.delete(data)
//        do {
//            try realm.commitWrite()
//            completion(nil)
//        } catch {
//            completion(error)
//        }
//    }
}
