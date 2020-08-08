//
//  CreateNewShotViewController.swift
//  Captain Cue
//
//  Created by HuyHoangDinh on 8/6/20.
//  Copyright © 2020 HuyHoangDinh. All rights reserved.
//

import UIKit
import RealmSwift
import Material
import M13Checkbox

class CreateNewShotViewController: UIViewController {

    @IBOutlet weak var clsvBall: UICollectionView!
    @IBOutlet weak var sgmcResult: UISegmentedControl!
    @IBOutlet weak var swIsTechnically: UISwitch!
    @IBOutlet weak var btnSubmit: RaisedButton!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    @IBOutlet weak var scrvMistake: UIScrollView!
    
    @IBOutlet weak var btnMistakes: RaisedButton!
    
    @IBOutlet weak var ckbNo1: M13Checkbox!
    @IBOutlet weak var ckbNo2: M13Checkbox!
    @IBOutlet weak var ckbNo3: M13Checkbox!
    @IBOutlet weak var ckbNo4: M13Checkbox!
    @IBOutlet weak var ckbNo5: M13Checkbox!
    @IBOutlet weak var ckbNo6: M13Checkbox!
    @IBOutlet weak var ckbNo7: M13Checkbox!
    @IBOutlet weak var ckbNo8: M13Checkbox!
    
    var checkBoxList: [M13Checkbox]!
    
    var selectedIndex: Int = -1
    
    var reportData: ReportModel!
    var shotResult: Results<ShotModel>?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        setupDatas()
    }
    
    func setupViews() {
        checkBoxList = [ckbNo1, ckbNo2, ckbNo3, ckbNo4, ckbNo5, ckbNo6, ckbNo7, ckbNo8]
        
        scrvMistake.layer.cornerRadius = 3
        
        clsvBall.layer.borderWidth = 1.5
        clsvBall.layer.borderColor = UIColor.lightGray.cgColor
        clsvBall.layer.cornerRadius = 5
        
        clsvBall.dataSource = self
        clsvBall.delegate = self
        
        clsvBall.register(UINib(nibName: Constants.CreateNewShotVC.clsvNibName, bundle: nil), forCellWithReuseIdentifier: Constants.CreateNewShotVC.clsvCellID)
        sgmcResult.selectedSegmentIndex = ResultType.hold.rawValue
    }
    
    func setupDatas() {
        shotResult = ShotModel.getAllData(from: reportData.id)
        
    }
    
    @IBAction func btnSubmitWasTapped(_ sender: Any) {
        if selectedIndex < 0 || selectedIndex > Constants.CreateNewShotVC.clsvNumberOfItems - 1 {
            showAlert(title: "Thiếu thông tin", message: "Hãy chọn số bóng bạn đã bắn.")
            return
        }
        let technicallyShot = swIsTechnically.isOn ? TechnicallyShotType.technicallyShot.rawValue: TechnicallyShotType.none.rawValue
        
        let mistakes = List<Int>()
        
        for index in 0..<checkBoxList.count {
            if checkBoxList[index].checkState == .checked {
                mistakes.append(index)
            }
        }
        
        let shot = ShotModel(_ballNumber: selectedIndex + 1,
                             _result: sgmcResult.selectedSegmentIndex,
                             _technicallyShot: technicallyShot,
                             _mistakes: mistakes,
                             _time: Date(),
                             _reportID: reportData.id)
        print(mistakes)
        ShotModel.addNew(data: shot)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func swTechnicallyShotChangedValue(_ sender: UISwitch) {
        if sender.isOn {
            setAllCheckBox(toDisable: true)
        } else {
            setAllCheckBox(toDisable: false)
        }
    }
    
    func setAllCheckBox(toDisable: Bool) {

        for index in 0..<checkBoxList.count {
            setCheckBox(checkBoxList[index], isDisable: toDisable)
            if let btn = self.view.viewWithTag(index + 1) as? RaisedButton {
                if toDisable {
                    btn.pulseOpacity = 0
                } else {
                    btn.pulseOpacity = 0.2
                }
            }
        }
    }
    
    func setCheckBox(_ checkBox: M13Checkbox, isDisable: Bool) {
        if isDisable {
            checkBox.setCheckState(.mixed, animated: true)
            checkBox.tintColor = .lightGray
            checkBox.isEnabled = false
        } else {
            checkBox.isEnabled = true
            checkBox.tintColor = .systemBlue
            checkBox.setCheckState(.unchecked, animated: true)
        }
    }
    
    @IBAction func btnMistakesWereTapped(_ sender: UIButton) {
        let tag = sender.tag - 1
        if tag >= 0 && tag < checkBoxList.count {
            let checkBox = checkBoxList[tag]
            if checkBox.isEnabled == false {
                return
            }
            let nextState: M13Checkbox.CheckState = checkBox.checkState == .checked ? .unchecked : .checked
            checkBox.setCheckState(nextState, animated: true)
        }
    }
}

extension CreateNewShotViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Constants.CreateNewShotVC.clsvNumberOfItems
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.CreateNewShotVC.clsvCellID, for: indexPath) as? BallCollectionViewCell else { fatalError("") }
        
        //        if shotResult?.contains(where: {$0.result == ResultType.hold.rawValue && $0.ballNumber == indexPath.item + 1}) ?? false {
        //            cell.configViews(ballNumber: indexPath.item + 1, isInHold: true)
        //        } else {
        var isSelected = false
        if indexPath.item == selectedIndex {
            isSelected = true
        }
        if isSelected {
            cell.configViews(ballNumber: indexPath.item + 1, isSelected: isSelected)
        } else if selectedIndex >= 0 {
            cell.configViews(ballNumber: indexPath.item + 1, isNotSelected: true)
        } else {
            cell.configViews(ballNumber: indexPath.item + 1, isSelected: isSelected)
        }
        
        //        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        if shotResult?.contains(where: {$0.result == ResultType.hold.rawValue && $0.ballNumber == indexPath.item + 1}) ?? false {
//            return
//        }
        selectedIndex = indexPath.item
        collectionView.reloadData()
    }
    
}

extension CreateNewShotViewController: UICollectionViewDelegateFlowLayout {
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
       let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
       let minimumInteritemSpacing = layout?.minimumInteritemSpacing ?? 0.0
       let leftAndRightSectionInset = (layout?.sectionInset.left ?? 0) + (layout?.sectionInset.right ?? 0)
       
       
       let tableCellWidth = ((collectionView.bounds.width - leftAndRightSectionInset - minimumInteritemSpacing * (CGFloat(Constants.CreateNewShotVC.clsvNumberOfColumn) - 1.0)) / CGFloat(Constants.CreateNewShotVC.clsvNumberOfColumn)).rounded(.towardZero)
       return CGSize(width: tableCellWidth, height: tableCellWidth)
   }
}
