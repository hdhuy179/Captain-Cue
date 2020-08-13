//
//  RemoteDataService.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/11/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import Foundation

protocol RemoteDataService {
    func getData<T : RemoteDataObject>(byID id: String, completion: @escaping ((T?, Error?) -> ()))
    
    func getAllData<T : RemoteDataObject>(completion: @escaping (([T]?, Error?) -> ()))
    
    func addObject<T : RemoteDataObject>(data: T, completion: @escaping ((Error?) -> ()))
    
    func updateObject<T : RemoteDataObject>(data: T, completion: @escaping ((Error?) -> ()))
    
    func getShotData(from reportID: String, completion: @escaping (([ShotModel]?, Error?) -> ()))
    
    func getShotData(from reportIDs: [String], completion: @escaping (([ShotModel]?, Error?) -> ()))
    
    func deleteObject<T : RemoteDataObject> (data: T, completion: @escaping ((Error?) -> ()))
    
    func deleteObject (data: OfflineStorageModel, completion: @escaping ((Error?) -> ()))
}

typealias RemoteDataObject = Mappable & Decodable & FireBaseObjectDetails & DataServiceObjectDetail

final class FirebaseDataService: RemoteDataService {

    let db:Firestore
    
    init(_db: Firestore = Firestore.firestore()) {
        self.db = _db
    }
    
    func getData<T: RemoteDataObject>(byID id: String, completion: @escaping ((T?, Error?) -> ())){
        
        db.collection(T.getRemoteCollectionName()).document(id).getDocument { (snapshot, err) in
            var result: T? = nil
            if let responseData = snapshot?.data() {
                result = T.init(JSON: responseData)
            }
            completion(result, err)
        }
    }
    
    func getAllData<T : RemoteDataObject>(completion: @escaping (([T]?, Error?) -> ())){
        db.collection(T.getRemoteCollectionName()).getDocuments { (snapshot, err) in
            var result: [T]?
            
            if let responseData = snapshot?.documents {
                result = []
                for item in responseData {
                    guard let newObject = T.init(JSON: item.data()) else { continue }
                    result?.append(newObject)
                }
            }
            
            completion(result, err)
        }
    }
    
    func addObject<T : RemoteDataObject>(data: T, completion: @escaping ((Error?) -> ())){
        db.collection(T.getRemoteCollectionName()).document(data.id).setData(data.getJSONData()) { err in
            completion(err)
        }
    }
    
    func updateObject<T : RemoteDataObject>(data: T, completion: @escaping ((Error?) -> ())){
//        db.collection(T.getFirebaseCollectionName()).document(data.id).updateData(data.getJSONData()) { err in
//            completion(err)
//        }
        db.collection(T.getRemoteCollectionName()).document(data.id).setData(data.getJSONData()) { err in
            completion(err)
        }
    }
    
    func getShotData(from reportID: String, completion: @escaping (([ShotModel]?, Error?) -> ())) {
        
        let reportIDProperties = Constants.ShotModel.Properties.reportID.rawValue
        db.collection(ShotModel.getRemoteCollectionName()).whereField(reportIDProperties, isEqualTo: reportID).getDocuments { (snapshot, err) in
            var result: [ShotModel]?
            
            if let responseData = snapshot?.documents {
                result = []
                for item in responseData {
                    guard let newObject = ShotModel.init(JSON: item.data()) else { continue }
                    result?.append(newObject)
                }
            }
            
            completion(result, err)
        }
    }
    
    func getShotData(from reportIDs: [String], completion: @escaping (([ShotModel]?, Error?) -> ())) {
        
        let reportIDProperties = Constants.ShotModel.Properties.reportID.rawValue
        db.collection(ShotModel.getRemoteCollectionName()).whereField(reportIDProperties, in: reportIDs).getDocuments { (snapshot, err) in
            var result: [ShotModel]?
            
            if let responseData = snapshot?.documents {
                result = []
                for item in responseData {
                    guard let newObject = ShotModel.init(JSON: item.data()) else { continue }
                    result?.append(newObject)
                }
            }
            
            completion(result, err)
        }
    }
    
    func deleteObject<T: RemoteDataObject>(data: T, completion: @escaping ((Error?) -> ())) {
        db.collection(T.getRemoteCollectionName()).document(data.id).delete() { err in
            completion(err)
        }
    }
    
    func deleteObject(data: OfflineStorageModel, completion: @escaping ((Error?) -> ())) {
        db.collection(data.collectionName).document(data.objectID).delete() { err in
            completion(err)
        }
    }
    
//    func deleteObject(data: ShotModel, completion: @escaping ((Error?) -> ())) {
//        getShotDatas(from: data.id) { [weak self] (shotList, err) in
//            if let err = err {
//                completion(err)
//                return
//            } else if shotList?.isEmpty == true {
//                self?.db.collection(ShotModel.getFirebaseCollectionName()).document(data.id).delete() { err in
//                    completion(err)
//                }
//            } else {
//
//            }
//        }
//    }
//
//    func deleteObject(data: ReportModel, completion: @escaping ((Error?) -> ())) {
//        db.collection(ReportModel.getFirebaseCollectionName()).document(data.id).delete() { err in
//            completion(err)
//        }
//    }
}
