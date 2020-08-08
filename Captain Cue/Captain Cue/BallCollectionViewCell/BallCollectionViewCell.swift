//
//  BallCollectionViewCell.swift
//  
//
//  Created by HuyHoangDinh on 8/6/20.
//

import UIKit

class BallCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imvBall: UIImageView!
    @IBOutlet weak var imvFaded: UIImageView!
    
    func configViews(ballNumber: Int, isSelected: Bool) {
        if isSelected {
            imvFaded.layer.cornerRadius = 5
            imvFaded.backgroundColor = .black
            imvFaded.alpha = 0.5
        }
        let imageName = "Ball\(ballNumber)"
        imvBall.image = UIImage(named: imageName)
    }
    
    func configViews(ballNumber: Int, isNotSelected: Bool) {
        if isNotSelected {
            imvFaded.layer.cornerRadius = 5
            imvFaded.backgroundColor = .white
            imvFaded.alpha = 0.5
        }
        let imageName = "Ball\(ballNumber)"
        imvBall.image = UIImage(named: imageName)
    }
    
    func configViews(ballNumber: Int, isInHold: Bool) {
        if isInHold {
            imvFaded.layer.cornerRadius = 5
            imvFaded.backgroundColor = .red
            imvFaded.alpha = 0.5
        }
        let imageName = "Ball\(ballNumber)"
        imvBall.image = UIImage(named: imageName)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imvBall.image = nil
        imvFaded.backgroundColor = .clear
    }
}
