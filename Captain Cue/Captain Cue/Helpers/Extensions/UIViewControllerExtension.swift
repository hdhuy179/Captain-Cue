//
//  UIViewControllerExtension.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/6/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okeAction = UIAlertAction(title: "Xác nhận", style: .cancel) { _ in
            completion?()
        }
        alert.addAction(okeAction)
        present(alert, animated: true, completion: nil)
    }
    
    func showConfirmAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okeAction = UIAlertAction(title: "Xác nhận", style: .cancel) { _ in
            completion?()
        }
        let cancelAction = UIAlertAction(title: "Huỷ", style: .default) { _ in
            
        }
        alert.addAction(okeAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
}
