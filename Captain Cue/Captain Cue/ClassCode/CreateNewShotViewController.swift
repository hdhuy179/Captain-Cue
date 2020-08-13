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
    @IBOutlet weak var tbvMistakes: UITableView!
    
    var selectedIndex: Int = -1
    
    var reportData: ReportModel!
    var shotResult: [ShotModel]?
    
    var mistakeDict: [Int: Bool] = [:]
    var isMistakeDisabled: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupViews()
        setupDatas()
    }
    
    func setupViews() {
        sgmcResult.selectedSegmentIndex = ResultType.hold.rawValue
        tbvMistakes.layer.cornerRadius = 3
        
        tbvMistakes.layer.cornerRadius = 3
        tbvMistakes.borderColor = .lightGray
        tbvMistakes.layer.borderWidth = 1.5
        
        clsvBall.layer.borderWidth = 1.5
        clsvBall.layer.borderColor = UIColor.lightGray.cgColor
        clsvBall.layer.cornerRadius = 5
        
        tbvMistakes.dataSource = self
        tbvMistakes.delegate = self
        
        clsvBall.dataSource = self
        clsvBall.delegate = self
        
        tbvMistakes.register(UINib(nibName: Constants.CreateNewShotVC.tbvNibName, bundle: nil), forCellReuseIdentifier: Constants.CreateNewShotVC.tbvCellID)
        
        clsvBall.register(UINib(nibName: Constants.CreateNewShotVC.clsvNibName, bundle: nil), forCellWithReuseIdentifier: Constants.CreateNewShotVC.clsvCellID)
    }
    
    func setupDatas() {
        shotResult = DataServiceManager.shared.getShotData(from: reportData.id) as [ShotModel]
        
    }
    
    @IBAction func btnSubmitWasTapped(_ sender: Any) {
        if selectedIndex < 0 || selectedIndex > Constants.CreateNewShotVC.clsvNumberOfItems - 1 {
            showAlert(title: "Thiếu thông tin", message: "Hãy chọn số bóng bạn đã bắn.")
            return
        }
        let technicallyShot = swIsTechnically.isOn ? TechnicallyShotType.technicallyShot.rawValue: TechnicallyShotType.none.rawValue
        
        let mistakes: List<Int> =  List<Int>()
        
        if !swIsTechnically.isOn {
            mistakes.append(objectsIn: mistakeDict.keys.sorted(by: <)) 
        }
        
        let shot = ShotModel(_ballNumber: selectedIndex + 1,
                             _result: sgmcResult.selectedSegmentIndex,
                             _technicallyShot: technicallyShot,
                             _mistakes: mistakes,
                             _time: Date(),
                             _reportID: reportData.id)
        DataServiceManager.shared.addObject(data: shot)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func swTechnicallyShotChangedValue(_ sender: UISwitch) {
//        if sender.isOn {
//            setAllCheckBox(toDisable: true)
//
//        } else {
//            setAllCheckBox(toDisable: false)
//        }
        isMistakeDisabled = sender.isOn
        tbvMistakes.reloadData()
    }
//
//    func setAllCheckBox(toDisable: Bool) {
//
//        for index in 0..<checkBoxList.count {
//            setCheckBox(checkBoxList[index], isDisable: toDisable)
//            if let btn = self.view.viewWithTag(index + 1) as? RaisedButton {
//                if toDisable {
//                    btn.pulseOpacity = 0
//                } else {
//                    btn.pulseOpacity = 0.2
//                }
//            }
//        }
//    }
//
//    func setCheckBox(_ checkBox: M13Checkbox, isDisable: Bool) {
//        if isDisable {
//            checkBox.setCheckState(.mixed, animated: true)
//            checkBox.tintColor = .lightGray
//            checkBox.isEnabled = false
//        } else {
//            checkBox.isEnabled = true
//            checkBox.tintColor = .systemBlue
//            checkBox.setCheckState(.unchecked, animated: true)
//        }
//    }
    
//    @IBAction func btnMistakesWereTapped(_ sender: UIButton) {
//        let tag = sender.tag - 1
//        if tag >= 0 && tag < checkBoxList.count {
//            let checkBox = checkBoxList[tag]
//            if checkBox.isEnabled == false {
//                return
//            }
//            let nextState: M13Checkbox.CheckState = checkBox.checkState == .checked ? .unchecked : .checked
//            checkBox.setCheckState(nextState, animated: true)
//        }
//    }
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

extension CreateNewShotViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MistakeType.allCases.count - 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: Constants.CreateNewShotVC.tbvCellID, for: indexPath) as? MistakeTableViewCell else { fatalError()}
        
        if isMistakeDisabled {
            cell.configDisabledView(index: indexPath.item)
            return cell
        }
        
        if mistakeDict[indexPath.item] == true {
            cell.configView(index: indexPath.item, isSelected: true)
        } else {
            cell.configView(index: indexPath.item, isSelected: false)
        }
        return cell
    }
}

extension CreateNewShotViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return Constants.CreateNewShotVC.tbvCellHeight
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        if isMistakeDisabled {
            return false
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if mistakeDict[indexPath.item] == true {
            mistakeDict[indexPath.item] = false
        } else {
            mistakeDict[indexPath.item] = true
        }
        if let cell = tableView.cellForRow(at: indexPath) as? MistakeTableViewCell {
            cell.cellWasTapped()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
