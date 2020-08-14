//
//  App.swift
//  RestaurantManager_DATN
//
//  Created by Hoang Dinh Huy on 1/30/20.
//  Copyright © 2020 Hoang Dinh Huy. All rights reserved.
//

import UIKit
import FirebaseAuth

final class App: UINavigationController {
    static let shared = App()
    
    var window: UIWindow!
    
    func startInterface() {
        if Auth.auth().currentUser != nil {
            let nav = PresentHandler().main.instantiateViewController(withIdentifier: "HomeNAV") as! UINavigationController
            
            nav.isNavigationBarHidden = true
            
            UIView.transition(with: window, duration: 0, animations: {
                self.window.rootViewController = nav
            }, completion: nil)
            transitionToTableView()
        } else {
            transitionToLoginView()
        }
        
        window.makeKeyAndVisible()
    }
    
    func transitionToLoginView() {
        let vc = PresentHandler().main.instantiateViewController(withIdentifier: "LoginNAV") as! UINavigationController
        do {
            try Auth.auth().signOut()
            changeView(vc)
        } catch {
            print("Error signing out: \(error.localizedDescription)")
        }
    }
    
    func transitionToTableView(fromVC: UIViewController? = nil) {
        if let currentUser = Auth.auth().currentUser {
            
        }
    }
    
     func changeView(_ rootViewController: UINavigationController) {
            UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: {
                self.window.rootViewController = rootViewController
            }, completion: nil)
        }
}
