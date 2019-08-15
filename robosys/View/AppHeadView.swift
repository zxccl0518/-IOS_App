//
//  AppHeadView.swift
//  robosys
//
//  Created by Cheer on 16/5/18.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit
import SnapKit
class AppHeadView: UIView
{
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var leftBtn: UIButton!
//    @IBOutlet weak var imgView: UIImageView!

    lazy var titleLabel: UILabel = {
        
        let titleLab = UILabel()
        titleLab.textColor = UIColor.whiteColor()
        titleLab.font = UIFont(name: "RTWS yueGothic Trial", size: 17)
        return titleLab
    }()
    
    lazy var leftBtn: UIButton = {
        
        let btn = UIButton()
        btn.addTarget(self, action: #selector(self.back), forControlEvents: .TouchUpInside)
        return btn
    }()
    
    private lazy var imageV : UIImageView = UIImageView(image: UIImage(named: "小盒形象"))
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        
        self.addSubview(imageV)
        imageV.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        self.addSubview(leftBtn)
        self.addSubview(titleLabel)
        
        leftBtn.snp_makeConstraints { (make) in
            
            make.centerY.equalTo(self).offset(-20)
            make.left.equalTo(18)
            make.width.equalTo(40)
        }
        
        titleLabel.snp_makeConstraints { (make) in
            
            make.height.equalTo(20.5)
            make.centerX.equalTo(self)
            make.centerY.equalTo(leftBtn)
        }
}


    func back()
    {
        print("点击了返回按钮")
        
        dispatch_async(dispatch_get_main_queue()) { 
            let vc = self.getCurrentVC()
            if vc.classForCoder == ConnectWiFiViewController.classForCoder() ||  vc.classForCoder == BindViewController.classForCoder() || (vc.classForCoder == ConfigurationViewController.classForCoder() && loginModel.sharedInstance.robotCount == 0) || vc.classForCoder == ScanRobotViewController.classForCoder() || vc.classForCoder == SwitchWifiVC().classForCoder
            {
                for sub in vc.navigationController!.viewControllers
                {
                    if sub.classForCoder == MainViewController.classForCoder()
                    {
                        vc.navigationController?.popToViewController(sub, animated: true)
                        print("开始推出")
                        
                        return
                    }
                }
                
                vc.navigationController?.pushViewController(MainViewController(), animated: true)
                
                return
            }
            
            vc.navigationController?.popViewControllerAnimated(true)
            print("开始推出")

        }
    
    }
    
}
