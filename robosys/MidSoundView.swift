//
//  MidSoundView.swift
//  robosys
//
//  Created by 刘渊 on 2017/4/20.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

class MidSoundView: UIView {

    //重用标记
    private let collVID : String = "collVID"
    var soundDataArr : NSMutableArray = NSMutableArray()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    private lazy var SoundCollectionView : UICollectionView = {
       
        let SoundFlowLayout = MidSoundFlowLayout()
        let SoundCollV = UICollectionView(frame: CGRect.zero, collectionViewLayout: SoundFlowLayout)
        SoundCollV.backgroundColor = UIColor.whiteColor()
        SoundCollV.backgroundView = UIImageView(image: UIImage(named: "Middle_Background_Normal"))
        return SoundCollV
    }()
    
    func setupUI() {
        setupCollectionView()
    }
    
    func setupCollectionView() {
        
        SoundCollectionView.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: collVID)
        SoundCollectionView.dataSource = self
        SoundCollectionView.delegate = self
        
        SoundCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(SoundCollectionView)
        
        let leftConstraint = NSLayoutConstraint(item: SoundCollectionView, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 6)
        let rightConstraint = NSLayoutConstraint(item: SoundCollectionView, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: -6)
        let topConstraint = NSLayoutConstraint(item: SoundCollectionView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: SoundCollectionView, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 6)
        leftConstraint.active = true
        rightConstraint.active = true
        topConstraint.active = true
        bottomConstraint.active = true

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension MidSoundView : UICollectionViewDataSource,UICollectionViewDelegate{
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell : UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(collVID, forIndexPath: indexPath)
        
        let imgV = UIImageView()
        imgV.image = UIImage(named: soundDataArr[indexPath.row] as! String)
        imgV.sizeToFit()
        imgV.center = cell.contentView.center
        cell.contentView.addSubview(imgV)
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
//        switch indexPath.row {
//        case 0:
//            <#code#>
//        default:
//            <#code#>
//        retur
//        n "点击了中间的按钮"
        
        }
//    }
    
}

