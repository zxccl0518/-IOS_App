//
//  ConnectView.swift
//  robosys
//
//  Created by 刘渊 on 2017/5/17.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

class ConnectView: UIView {
    
    var SelectedData : CellWifiModel?{
        
        didSet{
            wifiLabel.text = SelectedData?.ESSID
            
            if SelectedData?.Encryption?.characters.count == 3 {
                lockImg.hidden = true
            }else{
                lockImg.hidden = false
            }
        }
    }
    
    
    //背景图片
    private lazy var backImg : UIImageView = UIImageView(image: UIImage(named: "Configure Network-Middle-Background-"))
    //wifi名称
    lazy var wifiLabel : UILabel = {
        
        let lab : UILabel = UILabel()
        lab.textColor = UIColor.whiteColor()
        
        return lab
    }()
    
    //选中标志
    private lazy var selectedImgV : UIImageView = {
        
        let img : UIImageView = UIImageView()
        img.image = UIImage(named: "Configure Network-Icon-Check-")
        img.sizeToFit()
//        img.hidden = true
        return img
    }()
    
    //锁标记
    lazy var lockImg : UIImageView = {
        
        let img : UIImageView = UIImageView()
        
        img.image = UIImage(named: "Configure Network-Middle-lock-")
        img.sizeToFit()
        img.hidden = true
        return img
    }()
    
    //小wifi
    private lazy var wifiImg : UIImageView = {
        
        let img : UIImageView = UIImageView()
        
        img.image = UIImage(named: "Configure Network-Icon-WiFi-")
        img.sizeToFit()
        return img
    }()
    
    //底部横线
    private lazy var bottomLine : UIImageView = {
        
        let img : UIImageView = UIImageView()
        img.image = UIImage(named: "Configure Network-Middle-Line-")
//        img.sizeToFit()
        return img
    }()
    
    //wifi详细信息
    private lazy var infoImg : UIButton = {
        
        let btn : UIButton = UIButton()
        btn.sizeToFit()
        btn.setImage(UIImage(named:"Configure Network-Icon-Info-"), forState: UIControlState.Normal)
        return btn
        
    }()
    
    func setupUI(){
        
        self.addSubview(backImg)
        self.addSubview(selectedImgV)
        self.addSubview(wifiLabel)
        self.addSubview(lockImg)
        self.addSubview(wifiImg)
        self.addSubview(infoImg)
        self.addSubview(bottomLine)
        
        backImg.snp_makeConstraints { (make) in
            
            make.edges.equalTo(self)
        }
        
        selectedImgV.snp_makeConstraints { (make) in
            
            make.left.equalTo(self).offset(10)
            make.centerY.equalTo(self)
        }
        
        wifiLabel.snp_makeConstraints { (make) in
            
            make.left.equalTo(selectedImgV.snp_right).offset(10)
            make.centerY.equalTo(selectedImgV)
            make.right.equalTo(lockImg.snp_left)
        }
        
        infoImg.snp_makeConstraints { (make) in
            
            make.right.equalTo(self.snp_right).offset(-10)
            make.centerY.equalTo(wifiLabel)
        }
        
        wifiImg.snp_makeConstraints { (make) in
            
            make.centerY.equalTo(infoImg)
            make.right.equalTo(infoImg.snp_left).offset(-10)
        }
        
        lockImg.snp_makeConstraints { (make) in
            
            make.right.equalTo(wifiImg.snp_left).offset(-10)
            make.centerY.equalTo(wifiImg)
        }
        
        bottomLine.snp_makeConstraints { (make) in
            
            make.bottom.equalTo(self)
            make.left.equalTo(wifiLabel.snp_left)
            make.right.equalTo(backImg)
        }
        
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
}
