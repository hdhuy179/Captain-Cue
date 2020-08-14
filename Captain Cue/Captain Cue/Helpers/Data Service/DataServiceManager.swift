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
    func getJSONData() -> [String: Any]
}

protocol FireBaseObjectDetails {
    static func getRemoteCollectionName() -> String
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
            remoteDataService?.deleteObject(data: item, completion: { [weak self] (err) in
                if err == nil {
                    self?.localDataService?.deleteObject(data: item)
                }
            })
        default:
            break
        }
        
    }
    
    func changeInLocalDatabase<T: DataServiceObject>(data: T, menthodType: MenthodType, completion: ((Error?) -> ())? = nil) {
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
        changeInLocalDatabase(data: data, menthodType: .create)
    }
    
    func updateObject<T: DataServiceObject>(data: T, completion: ((Error?) -> ())? = nil) {
        guard let localDataService = localDataService else {
            let err = NSError(domain: "Config local database before using is menthod", code: -1, userInfo: nil)
            completion?(err)
            return
        }
        
        localDataService.updateObject(data: data)
        changeInLocalDatabase(data: data, menthodType: .update)
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
        
        if data is ReportModel {
            let shotList = localDataService.getShotData(from: data.id)
            for item in shotList {
                deleteObject(data: item)
            }
        }
        changeInLocalDatabase(data: data, menthodType: .delete)
        localDataService.deleteObject(data: data)
    }
    
    func isLocalDatabaseEmpty() -> Bool {
        guard let localDataService = localDataService else {
            fatalError("Config local database before using is menthod")
        }
        return localDataService.isDatabaseEmpty()
    }
    
    func checkRestoreAbility(fromVC vc: UIViewController, completion: @escaping (Error?) -> ()) {
        guard let remoteDataService = remoteDataService,
            let localDataService = localDataService else { return }
        
        if localDataService.isDatabaseEmpty() == false {
            return
        }
        
        var reportData: [ReportModel]? = nil
        var shotData: [ShotModel]? = nil
        
        let reportClosure: (([ReportModel]?, Error?) -> Void) = { datas, err in
            if let err = err {
                completion(err)
            } else {
                reportData = datas ?? []
                checkShowAlert(completion: completion)
            }
        }
        
        let shotClosure: (([ShotModel]?, Error?) -> Void) = { datas, err in
            if let err = err {
                completion(err)
            } else {
                shotData = datas ?? []
                checkShowAlert(completion: completion)
            }
            
        }
        
        func checkShowAlert(completion: @escaping ((Error?) -> ())) {
            if let shotData = shotData, let reportData = reportData, (shotData.isEmpty == false || reportData.isEmpty == false) {
                vc.showConfirmAlert(title: "Restore", message: "Bạn có muốn khôi phục dữ liệu từ server không?") {
                    localDataService.restoreData(data: reportData)
                    localDataService.restoreData(data: shotData)
                    completion(nil)
                }
            }
        }
        
        remoteDataService.getAllData(completion: reportClosure)
        remoteDataService.getAllData(completion: shotClosure)
    }
    
    func backupData(completion: @escaping ((CGFloat? ,Error?) -> ())) {
        guard let remoteDataService = remoteDataService,
        let localDataService = localDataService else { return }
        
        let reportLocalData: [ReportModel] = localDataService.getAllDatas()
        let shotLocalData: [ShotModel] = localDataService.getAllDatas()
        
        var reportCloudData: [ReportModel]? = nil
        var shotCloudData: [ShotModel]? = nil
        
        let reportClosure: (([ReportModel]?, Error?) -> Void) = { datas, err in
            if let err = err {
                completion(nil, err)
            } else {
                reportCloudData = datas ?? []
                checkLoadingDataDone()
            }
        }
        
        let shotClosure: (([ShotModel]?, Error?) -> Void) = { datas, err in
            if let err = err {
                completion(nil, err)
            } else {
                shotCloudData = datas ?? []
                checkLoadingDataDone()
            }
            
        }
        
        func checkLoadingDataDone() {
            if let reportCloudData = reportCloudData, let shotCloudData = shotCloudData {
                
                let totalTask = reportCloudData.count + shotCloudData.count + reportLocalData.count + shotLocalData.count
                var currentProgress = 0
                
                var shotDeleteCounter = 0
                var reportDeleteCounter = 0
                
                for item in shotCloudData {
                    remoteDataService.deleteObject(data: item) { (err) in
                        
                        if let err = err {
                            completion(nil, err)
                        } else {
                            
                            currentProgress += 1
                            completion((CGFloat(currentProgress)/CGFloat(totalTask)), nil)
                            shotDeleteCounter += 1
                            if shotDeleteCounter == shotCloudData.count {
                                for itemLocal in shotLocalData {
                                    remoteDataService.addObject(data: itemLocal) { (err) in
                                        if let err = err {
                                            completion(nil, err)
                                        } else {
                                            currentProgress += 1
                                            completion((CGFloat(currentProgress)/CGFloat(totalTask)), nil)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                for item in reportCloudData {
                    
                    remoteDataService.deleteObject(data: item) { (err) in
                        
                        if let err = err {
                            completion(nil, err)
                        } else {
                            
                            currentProgress += 1
                            completion((CGFloat(currentProgress)/CGFloat(totalTask)), nil)
                            reportDeleteCounter += 1
                            
                            if reportDeleteCounter == reportCloudData.count {
                                for itemLocal in reportLocalData {
                                    remoteDataService.addObject(data: itemLocal) { (err) in
                                        if let err = err {
                                            completion(nil, err)
                                        } else {
                                            currentProgress += 1
                                            completion((CGFloat(currentProgress)/CGFloat(totalTask)), nil)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
        completion(0, nil)
        
        remoteDataService.getAllData(completion: reportClosure)
        remoteDataService.getAllData(completion: shotClosure)
    }
}
