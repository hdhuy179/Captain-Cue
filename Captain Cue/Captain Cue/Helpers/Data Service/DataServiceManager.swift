//
//  DataServiceManager.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/12/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import Foundation

//protocol DataService {
//
//    func configDB(_localDB: LocalDataService, _remoteDB: RemoteDataService?)
//
//    func getData<T : DataServiceObject>(byID id: String) -> T?
//
//    func getAllDatas<T : DataServiceObject>() -> [T]
//
//    func addObject<T : DataServiceObject>(data: T, completion: ((Error?) -> ())?)
//
//    func updateObject<T : DataServiceObject>(data: T, completion: ((Error?) -> ())?)
//
//    func getShotDatas(from reportID: String) -> [ShotModel]
//
//    func getShotDatas(from reportIDs: [String]) -> [ShotModel]
//
//    func deleteObject<T : DataServiceObject> (data: T, completion: ((Error?) -> ())?)
//}

typealias DataServiceObject = RemoteDataObject & LocalDataObject

protocol DataServiceObjectDetail {
    var id: String { get set }
}

protocol FireBaseObjectDetails {
    static func getRemoteCollectionName() -> String
    func getJSONData() -> [String: Any]
}

class DataServiceManager {//: DataService {

    private var localDataService: LocalDataService?
    private var remoteDataService: RemoteDataService?
    
    private var network: Network?
    
    static let shared = DataServiceManager()
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeInternetConnection), name: kNetworkConnectionChangedNotification, object: nil)
    }
    
    @objc public func changeInternetConnection() {
        
        checkAndMergeChangeInLocalDatabase()
    }
    
    func configDB(_localDB: LocalDataService, _remoteDB: RemoteDataService?) {
        self.localDataService = _localDB
        self.remoteDataService = _remoteDB
    }
    
    func configNetwork(_network: Network) {
        self.network = _network
    }
    
    func changeLocalDB(to db: LocalDataService) {
        self.localDataService = db
    }
    
    func changeRemoteDB(to db: RemoteDataService) {
        self.remoteDataService = db
    }
    
    func checkAndMergeChangeInLocalDatabase() {
        if network?.isInternetAvailable != .Available {
            return
        }
        
        if let offlineData = localDataService?.getAllDatas() as [OfflineStorageModel]? {
            
            for item in offlineData {
                
                switch item.collectionName {
                    
                case ShotModel.getRemoteCollectionName():
                    if let localObj = localDataService?.getData(byID: item.objectID) as ShotModel? {
                        mergeChangeToRemoteDatabase(byRecordChangeObj: item, withLocalObj: localObj)
                    } else {
                        remoteDataService?.deleteObject(data: item, completion: { [weak self] (err) in
                            if err == nil {
                                self?.localDataService?.deleteObject(data: item)
                            }
                        })
                    }
                    
                case ReportModel.getRemoteCollectionName():
                    print("check and merge")
                    if let localObj = localDataService?.getData(byID: item.objectID) as ReportModel? {
                        mergeChangeToRemoteDatabase(byRecordChangeObj: item, withLocalObj: localObj)
                    } else {
                        remoteDataService?.deleteObject(data: item, completion: { [weak self] (err) in
                            if err == nil {
                                self?.localDataService?.deleteObject(data: item)
                            }
                        })
                    }
                    
                default:
                    continue
                }
                
            }
        }
    }
    
    func mergeChangeToRemoteDatabase<T: DataServiceObject> (byRecordChangeObj item: OfflineStorageModel, withLocalObj localObj: T?) {
        switch item.getMenthod() {
        case .create:
            guard let localObj = localObj else { return }
            remoteDataService?.addObject(data: localObj, completion: { [weak self] (err) in
                if err == nil {
                    self?.localDataService?.deleteObject(data: item)
                }
            })
        case .update:
            guard let localObj = localObj else { return }
            remoteDataService?.updateObject(data: localObj, completion: { [weak self] (err) in
                if err == nil {
                    self?.localDataService?.deleteObject(data: item)
                }
            })
        case .delete:
            print("Merge")
            remoteDataService?.deleteObject(data: item, completion: { [weak self] (err) in
                if err == nil {
                    self?.localDataService?.deleteObject(data: item)
                }
            })
        default:
            break
        }
        
    }
    
    func prepareChangeInLocalDatabase<T: DataServiceObject>(data: T, menthodType: MenthodType, completion: ((Error?) -> ())? = nil) {
        guard let localDataService = localDataService else {
            let err = NSError(domain: "Config local database before using is menthod", code: -1, userInfo: nil)
            completion?(err)
            return
        }
        
        let previousRecords = localDataService.getOfflineStore(ofObjID: data.id)
        
        for item in previousRecords {
            localDataService.deleteObject(data: item)
        }
        
        let obj = OfflineStorageModel(_collectionName: T.getRemoteCollectionName(), _menthodType: menthodType, _objectID: data.id)
        localDataService.addObject(data: obj)
        
        checkAndMergeChangeInLocalDatabase()
        
//        if network?.isInternetAvailable == .Available {
//            remoteDataService?.addObject(data: data, completion: { [weak self] err in
//                if err == nil {
//                    completion?(nil)
//                } else {
//
//                    completion?(err)
//                }
//            })
//        } else {
//            let obj = OfflineStorageModel(_collectionName: T.getRemoteCollectionName(), _menthodType: menthodType, _objectID: data.id)
//            localDataService?.addObject(data: obj)
//            completion?(nil)
//        }
    }
    
    func getData<T: DataServiceObject>(byID id: String) -> T? {
        let result = localDataService?.getData(byID: id) as T?
        return result
    }
    
    func getAllData<T: DataServiceObject>() -> [T] {
        let result = (localDataService?.getAllDatas() ?? []) as [T]
        return result
    }
    
    func addObject<T: DataServiceObject>(data: T, completion: ((Error?) -> ())? = nil) {
        guard let localDataService = localDataService else {
            let err = NSError(domain: "Config local database before using is menthod", code: -1, userInfo: nil)
            completion?(err)
            return
        }
        
        localDataService.addObject(data: data)
        prepareChangeInLocalDatabase(data: data, menthodType: .create)
    }
    
    func updateObject<T: DataServiceObject>(data: T, completion: ((Error?) -> ())? = nil) {
        guard let localDataService = localDataService else {
            let err = NSError(domain: "Config local database before using is menthod", code: -1, userInfo: nil)
            completion?(err)
            return
        }
        
        localDataService.updateObject(data: data)
        prepareChangeInLocalDatabase(data: data, menthodType: .update)
    }
    
    func getShotData(from reportID: String) -> [ShotModel] {
        let result = (localDataService?.getShotData(from: reportID) ?? []) as [ShotModel]
        return result
    }
    
    func getShotData(from reportIDs: [String]) -> [ShotModel] {
        let result = (localDataService?.getShotData(from: reportIDs) ?? []) as [ShotModel]
        return result
    }
    
    func deleteObject<T: DataServiceObject>(data: T, completion: ((Error?) -> ())? = nil) {
        guard let localDataService = localDataService else {
            let err = NSError(domain: "Config local database before using is menthod", code: -1, userInfo: nil)
            completion?(err)
            return
        }
        prepareChangeInLocalDatabase(data: data, menthodType: .delete)
        
        if data is ReportModel {
            let shotList = localDataService.getShotData(from: data.id)
            for item in shotList {
                deleteObject(data: item)
            }
        }
        localDataService.deleteObject(data: data)
        print("Done.")
    }
}
