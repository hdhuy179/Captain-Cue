//
//  Network.swift
import UIKit
import Reachability
import CoreTelephony


let kNW_DISCONNECT   = 0
let kNW_WIFI         = 1
let kNW_CELL_2G      = 2
let kNW_CELL_3G      = 3
let kNW_CELL_4G      = 4
let kNW_CELL_UNKNOWN = 5

enum InternetState: Int {
    case Available, Unavailable
}

let kNetworkConnectionChangedNotification = Notification.Name(rawValue: "NetworkConnectionChanged")

public class Network {
    
    static let internet = Network()
    private(set) var reachability: Reachability?
    
    var isInternetAvailable: InternetState
    var status: Int
    
    
    init() {
        isInternetAvailable = .Unavailable
        status = kNW_DISCONNECT
        startMonitor()
    }
    
    
    /// Start monitoring Internet connection.
    func startMonitor() {
        if reachability != nil { return }
        do {
            try reachability = Reachability()
        } catch {
            
        }
        
        if let reach = reachability {
            isInternetAvailable = reach.connection == .unavailable ? .Unavailable : .Available
            status = reach.connection == .unavailable ? kNW_WIFI : kNW_DISCONNECT
        }
        if reachability?.connection != .none {
            status = reachability?.connection == .wifi ? kNW_WIFI : kNW_CELL_UNKNOWN
        }
        // Set up handler for reachable
        reachability?.whenReachable = { reachability in
            if reachability.connection == .wifi {
                print("Reachable via WiFi")
                self.status = kNW_WIFI
            } else {
                print("Reachable via Cellular")
                let networkInfo = CTTelephonyNetworkInfo()
                let carrierType = networkInfo.currentRadioAccessTechnology
                switch carrierType {

                case CTRadioAccessTechnologyGPRS?,CTRadioAccessTechnologyEdge?,CTRadioAccessTechnologyCDMA1x?:
                    self.status = kNW_CELL_2G

                case CTRadioAccessTechnologyWCDMA?,CTRadioAccessTechnologyHSDPA?,CTRadioAccessTechnologyHSUPA?,CTRadioAccessTechnologyCDMAEVDORev0?,CTRadioAccessTechnologyCDMAEVDORevA?,CTRadioAccessTechnologyCDMAEVDORevB?,CTRadioAccessTechnologyeHRPD?:
                    self.status = kNW_CELL_3G

                case CTRadioAccessTechnologyLTE?:
                    self.status = kNW_CELL_4G

                default:
                    self.status = kNW_CELL_UNKNOWN

                }
            }
            
            if self.isInternetAvailable == .Unavailable {
                self.isInternetAvailable = .Available
                
                NotificationCenter.default.post(name: kNetworkConnectionChangedNotification, object: nil)
            }

        }
        // Set up handler for unreachable
        reachability?.whenUnreachable = { _ in
            print("Reachable no internet")
            self.status = kNW_DISCONNECT
            if self.isInternetAvailable == .Available {
                self.isInternetAvailable = .Unavailable
                NotificationCenter.default.post(name: kNetworkConnectionChangedNotification, object: nil)
            }
        }
        
        do {
            try reachability?.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }
    
    @objc func reachabilityChanged(notification: NSNotification) {
        if reachability?.connection == .wifi {
            print("Reachable via WiFi")
            self.status = kNW_WIFI
        } else {
            print("Reachable via Cellular")
            let networkInfo = CTTelephonyNetworkInfo()
            let carrierType = networkInfo.currentRadioAccessTechnology
            switch carrierType {
                
            case CTRadioAccessTechnologyGPRS?,CTRadioAccessTechnologyEdge?,CTRadioAccessTechnologyCDMA1x?:
                self.status = kNW_CELL_2G
                
            case CTRadioAccessTechnologyWCDMA?,CTRadioAccessTechnologyHSDPA?,CTRadioAccessTechnologyHSUPA?,CTRadioAccessTechnologyCDMAEVDORev0?,CTRadioAccessTechnologyCDMAEVDORevA?,CTRadioAccessTechnologyCDMAEVDORevB?,CTRadioAccessTechnologyeHRPD?:
                self.status = kNW_CELL_3G
                
            case CTRadioAccessTechnologyLTE?:
                self.status = kNW_CELL_4G
                
            default:
                self.status = kNW_CELL_UNKNOWN
                
            }
        }
    }
    
    /// Stop monitoring Internet connection
    func stopMonitor() {
        reachability?.stopNotifier()
    }
    
}
