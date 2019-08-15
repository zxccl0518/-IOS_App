//
//  TopImageView.swift
//  robosys
//
//  Created by max.liu on 2017/4/20.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit
import SnapKit

class TopImageView: UIView {
    
    var pictureData = NSMutableArray()
   //重用标记
    private let collVID : String = "collVID"
    
    private lazy var control = RobotControl.shareInstance()
    
    
    //MARK:懒加载
    private lazy var picture: UIImageView = {
        
        let imageView = UIImageView()
        imageView.image = UIImage(named:"iphone")
        return imageView
    }()
    
    private lazy var collectionV: UICollectionView = {
       
        let collFlowLayout = TopPictureFlowLayout()
        
        let collVc = UICollectionView(frame: CGRect.zero, collectionViewLayout: collFlowLayout)
        collVc.backgroundColor = UIColor.clearColor()
        return collVc
    }()
    
    
    //MARK:初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    //MARK:设置UI
    func setupUI() {
        
        setupPicture()
        setupCollectionView()
    }
    
    //MARK:设置CollectionView
    func setupCollectionView() {
        
        collectionV.registerClass(UICollectionViewCell.self, forCellWithReuseIdentifier: collVID)
        collectionV.dataSource = self
        collectionV.delegate = self
        collectionV.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(collectionV)
        

        let leftConstraint = NSLayoutConstraint(item: collectionV, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let rightConstraint = NSLayoutConstraint(item: collectionV, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0.0)
        let bottomConstraint = NSLayoutConstraint(item: collectionV, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0.0)
        let heightConstraint = NSLayoutConstraint(item: collectionV, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 100)
        leftConstraint.active = true
        rightConstraint.active = true
        bottomConstraint.active = true
        heightConstraint.active = true
        
    }
    
    //MARK:设置背景图
    func setupPicture() {
        
        picture.translatesAutoresizingMaskIntoConstraints = false
        picture.contentMode = .ScaleAspectFit
        self.addSubview(picture)
        let leftConstraint = NSLayoutConstraint(item: picture, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0.0)
        let topConstraint = NSLayoutConstraint(item: picture, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0.0)
        let widthConstraint = NSLayoutConstraint(item: picture, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0.0)
        let heightConstraint = NSLayoutConstraint(item: picture, attribute: .Height, relatedBy: .Equal, toItem: self, attribute: .Height, multiplier: 1.0, constant: 0.0)
        leftConstraint.active = true
        topConstraint.active = true
        widthConstraint.active = true
        heightConstraint.active = true
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:
}


extension TopImageView : UICollectionViewDataSource,UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell : UICollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier(collVID, forIndexPath: indexPath)
        
       let imgV = UIImageView()
        imgV.sizeToFit()
        
        if indexPath.row <= 1 {
            imgV.image = UIImage(named: pictureData[indexPath.row] as! String)
        }else{
            imgV.image = UIImage(named: pictureData[2] as! String)
        }
        
        cell.contentView.addSubview(imgV)
        
        imgV.snp_makeConstraints { (make) in
            make.edges.equalTo(cell)
        }
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        switch indexPath.row {
            
        case 0:
            self.control.didNod(1, times: 1)
            return
        case 1:
            self.control.didShake(1, times: 1)
            return
            
        default:
            break
        }
        
        
        return
        
    }
    
    
}



