//
//  ConfigurationVC.swift
//  robosys
//
//  Created by max.liu on 2017/5/5.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit
import SnapKit

class ConfigurationVC: UIViewController,UIScrollViewDelegate {
    
    private lazy var scrollV : UIScrollView = {
        
        let scr = UIScrollView()
        
        scr.contentSize = self.scrol.frame.size
        scr.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
        
        scr.bouncesZoom = false
        
        scr.maximumZoomScale = 1.0
        scr.minimumZoomScale = 0.35
        
        scr.delegate = self
        
        scr.bounces = false
        scr.showsVerticalScrollIndicator = false
        scr.showsHorizontalScrollIndicator = false
        
        return scr
    }()
    
    //联网向导视图
    private lazy var scrol : UIView = {
        
        let sc = UIView()
        
        let imgV : UIImageView = UIImageView(image: UIImage(named: "联网向导"))
        sc.addSubview(imgV)
        
        imgV.snp_makeConstraints(closure: { (make) in
            make.edges.equalTo(sc)
        })
        
        return sc
    }()
    
    //点击的手势
    private lazy var tap : UITapGestureRecognizer = {
        
        let ta = UITapGestureRecognizer(target: self, action: #selector(tapG))
        return ta
    }()
    
    func tapG (){
        self.scrollV.hidden = true
    }
    
    
    override func viewWillAppear(animated: Bool) {
        self.scrollV.zoomScale = 0.35
    }
    
    private lazy var imageV : UIImageView = {
       
        let imgV = UIImageView()
        imgV.image = UIImage(named: "首页-背景")
        return imgV
    }()
    
    
    private lazy var guideBtn : UIButton = {
        
        let btn = UIButton()
        
        btn.setImage(UIImage(named: "Configure Network-Top-Button-"), forState: .Normal)
        btn.addTarget(self, action: #selector(guideClick), forControlEvents: .TouchUpInside)
        btn.sizeToFit()
        return btn
    }()
    
    func guideClick(){
        
        self.scrollV.hidden = false
    }
    
    private lazy var topImageV : UIView = {
       
        let  headView = AppHeadView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,140))
        self.view.addSubview(headView)
        
        headView.titleLabel.text = "配置网络"
//        headView.titleLabel.font = UIFont(name: "RTWS yueGothic Trial", size: 17)
        
        headView.leftBtn.setImage(UIImage(named: "返回"), forState: .Normal)
        
        return headView
    }()
    
    //第三步
    private lazy var step3_Label : UILabel = {
       
        let label = UILabel()
        label.text = "Step3 连接机器人WiFi"
        label.textColor = UIColor.whiteColor()
        label.font = UIFont(name: "RTWS yueGothic Trial", size: 17)
        return label
    }()
    
    //中间提示图
    private lazy var imgV : UIImageView = {
        
        let imagV = UIImageView()
        imagV.image = UIImage(named: "Configure Network-Middle-Image-")
        imagV.sizeToFit()
        return imagV
    }()
    
    //警告文字
    private lazy var hint_Label : UILabel = {
        
        let label = UILabel()
        
        label.backgroundColor = UIColor.blackColor()
        label.alpha = 0.45
        label.numberOfLines = 0
        
        label.text = "   1.现在请前往局域网界面，手动选择带有\"MrBoxCNxxxxx\"字样的WiFi连接\n\n   2.成功连接后，返回小盒机器人\n"
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Left

        return label
    }()
    
    
    //去连接按钮
    private lazy var Go2Wifi : UIButton = {
       let btn = UIButton()
        btn.setBackgroundImage(UIImage(named:"圆角矩形-1"), forState: .Normal)
        btn.setTitle("去设置WiFi", forState: .Normal)
        btn.addTarget(self, action: #selector(goToSetWiFi), forControlEvents: .TouchUpInside)
        return btn
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageV)
        view.addSubview(topImageV)
        view.addSubview(step3_Label)
        view.addSubview(imgV)
        view.addSubview(hint_Label)
        view.addSubview(Go2Wifi)
        topImageV.addSubview(guideBtn)
        
        
        self.view.addSubview(self.scrollV)
        self.scrollV.addSubview(self.scrol)
        self.view.addGestureRecognizer(tap)
        
        self.scrollV.hidden = true
        
        self.scrollV.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        self.scrol.snp_makeConstraints { (make) in
            make.edges.equalTo(self.scrollV)
        }

        
        guideBtn.snp_makeConstraints { (make) in
            
            make.right.equalTo(topImageV).offset(-17)
//            make.top.equalTo(topImageV).offset(25)
            make.centerY.equalTo((topImageV as! AppHeadView).leftBtn)
        }
        
        topImageV.snp_makeConstraints { (make) in
            
            make.left.top.right.equalTo(self.view)
            make.height.equalTo(140)
        }
        
        imageV.snp_makeConstraints { (make) in
            
            make.edges.equalTo(self.view)
        }
        
        imgV.snp_makeConstraints { (make) in
            
            make.top.equalTo(step3_Label.snp_bottom).offset(20)
            make.centerX.equalTo(self.view)
        }
        
        step3_Label.snp_makeConstraints { (make) in
            
            make.top.equalTo(self.view).offset(150)
            make.left.equalTo(self.view).offset(27)
            make.height.equalTo(17)
            make.right.equalTo(self.view).offset(-27)
        }
        
        hint_Label.snp_makeConstraints { (make) in
            
            make.left.equalTo(self.view).offset(30)
            make.right.equalTo(self.view).offset(-30)
            make.top.equalTo(imgV.snp_bottom).offset(30)
            make.height.equalTo(150)
        }
        
        Go2Wifi.snp_makeConstraints { (make) in
            
            make.bottom.equalTo(-15)
            make.height.equalTo(37)
            make.centerX.equalTo(self.view)
        }
    }
    
    
    func goToSetWiFi() {
        
        if let url = NSURL(string:"App-Prefs:root=WIFI") {
            
        if #available(iOS 10.0, *) {

            UIApplication.sharedApplication().openURL(url, options: [:], completionHandler: nil)
        } else {

            UIApplication.sharedApplication().openURL(url)
                }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.scrol
    }
    
    
}




