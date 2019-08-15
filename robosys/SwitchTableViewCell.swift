
//
//  SwitchTableViewCell.swift
//  robosys
//
//  Created by max.liu on 2017/5/11.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {

    var cellD : CellWifiModel?{
        
        didSet{
            
            wifiLabel.text = cellD?.ESSID
            
            if cellD?.Encryption!.characters.count == 3 {
                lockImg.hidden = true
            }else{
                lockImg.hidden = false
            }
            
            
            if cellD!.Quality != nil {
                
                switch (cellD?.Quality)! as Int {
                case 1:
                    wifiImg.image = UIImage(named: "Configure Network-Icon-WiFi-1")
                    print("1")
                    break
                case 2,3:
                    wifiImg.image = UIImage(named: "Configure Network-Icon-WiFi-2")
                    print("2")
                    break
                case 4,5:
                    wifiImg.image = UIImage(named:"Configure Network-Icon-WiFi-")
                    print("3")
                    break
                default:
                    break
                }
            }
        }
    }
    //wifi名称
    private lazy var wifiLabel : UILabel = {
       
        let lab : UILabel = UILabel()
//        lab.text = "PC_ROBOT"
        lab.textColor = UIColor.whiteColor()
        
        return lab
    }()
    
    //选中标志
//    private lazy var selectedImgV : UIImageView = {
//       
//        let img : UIImageView = UIImageView()
//        img.image = UIImage(named: "Configure Network-Icon-Check-")
//        img.sizeToFit()
//        img.hidden = true
//        return img
//    }()
    
    private lazy var backImg : UIImageView = UIImageView(image: UIImage(named: "Configure Network-Middle-Background-"))
    
    //锁标记
    private lazy var lockImg : UIImageView = {
       
        let img : UIImageView = UIImageView()
        
        img.image = UIImage(named: "Configure Network-Middle-lock-")
        img.sizeToFit()
        img.hidden = true
        return img
    }()
    
    //小wifi
    private lazy var wifiImg : UIImageView = {
        
        let img : UIImageView = UIImageView()
        
//        img.image = UIImage(named: "Configure Network-Icon-WiFi-")
        img.sizeToFit()
        return img
    }()
    
    //底部横线
    private lazy var bottomLine : UIImageView = {
       
        let img : UIImageView = UIImageView()
        img.image = UIImage(named: "Configure Network-Middle-Line-")
        img.sizeToFit()
        return img
    }()
    
    //wifi详细信息
    private lazy var infoImg : UIButton = {
       
        let btn : UIButton = UIButton()
        btn.sizeToFit()
        btn.setImage(UIImage(named:"Configure Network-Icon-Info-"), forState: UIControlState.Normal)
        btn.addTarget(self, action: #selector(infoBtnClick), forControlEvents: UIControlEvents.TouchUpInside)
        return btn
        
    }()
    
    func infoBtnClick() {
        
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
    func setupUI() {
        
        contentView.backgroundColor = UIColor.clearColor()
        contentView.addSubview(backImg)
        
        backImg.addSubview(wifiLabel)
        backImg.addSubview(lockImg)
        backImg.addSubview(wifiImg)
        backImg.addSubview(bottomLine)
        backImg.addSubview(infoImg)
        
        backImg.snp_makeConstraints { (make) in
            make.edges.equalTo(contentView)
        }
        
        wifiLabel.snp_makeConstraints { (make) in
            
            make.left.equalTo(backImg).offset(20)
            make.centerY.equalTo(backImg)
            make.width.equalTo(200)
//            make.right.equalTo(lockImg.snp_left)
        }
//
        infoImg.snp_makeConstraints { (make) in
            
            make.right.equalTo(backImg.snp_right).offset(-10)
            make.centerY.equalTo(wifiLabel)
        }
//
        wifiImg.snp_makeConstraints { (make) in
            
            make.centerY.equalTo(infoImg)
            make.right.equalTo(infoImg.snp_left).offset(-10)
        }
//
        lockImg.snp_makeConstraints { (make) in
            
            make.right.equalTo(wifiImg.snp_left).offset(-10)
            make.centerY.equalTo(wifiImg)
        }
//
        bottomLine.snp_makeConstraints { (make) in
            make.bottom.equalTo(backImg)
            make.left.equalTo(wifiLabel.snp_left)
            make.right.equalTo(backImg)
        }
        
    }

//    override func setHighlighted(highlighted: Bool, animated: Bool){
//        
//        super.setHighlighted(highlighted, animated: animated)
//    
//        UIView.animateWithDuration(0.1, delay: 0.1, options: UIViewAnimationOptions.CurveEaseIn, animations: { 
//            self.contentView.backgroundColor = UIColor
//            }, completion: <#T##((Bool) -> Void)?##((Bool) -> Void)?##(Bool) -> Void#>)
//    }
    
    //被选中的时候 需要怎么做
//    override func setSelected(selected: Bool, animated: Bool) {
//        super.setSelected(selected, animated: animated)
//        
//    }

    //判断密码  是否连接  1/1 2,3/2 45/5
    
}
