//
//  ScanRobotView.swift
//  robosys
//
//  Created by Cheer on 16/5/24.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class ScanRobotView: AppView,UIScrollViewDelegate
{
    @IBOutlet weak var connectBtn: UIButton!
    @IBOutlet weak var step2: UIImageView!
    @IBOutlet weak var step1: UIImageView!
    
    var isWifi:Bool!
    
    //=======================
     lazy var scrollV : UIScrollView = {
        
        let scr = UIScrollView()
        
        scr.contentSize = self.scrol.frame.size
        scr.contentInset = UIEdgeInsetsMake(0, 0, 0, 0)
//        scr.zoomScale = 0.35
        
        scr.bouncesZoom = false
        
//        scr.maximumZoomScale = 1.0
//        scr.minimumZoomScale = 0.35
        
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

    //========================
    private lazy var topImageV : UIView = {

        let headView = AppHeadView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,140))
        headView.titleLabel.text = "切换网络"
        
        headView.leftBtn.setImage(UIImage(named: "返回"), forState: .Normal)
        
        return headView
    }()

    
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        self.addSubview(topImageV)

        setUp(step1, duration: 2)
        setUp(step2, duration: 2)
        
        self.addSubview(guideBtn)
        
        self.addSubview(self.scrollV)
        self.scrollV.addSubview(self.scrol)
        self.addGestureRecognizer(tap)
        
        self.scrollV.hidden = true
        
        self.scrollV.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
        
        self.scrol.snp_makeConstraints { (make) in
            make.edges.equalTo(self.scrollV)
        }
        
        
        guideBtn.snp_makeConstraints { (make) in
            
            make.right.equalTo(self).offset(-17)
             make.centerY.equalTo((topImageV as! AppHeadView).leftBtn)
        }
        
        topImageV.snp_makeConstraints { (make) in
            
            make.left.top.right.equalTo(self)
            make.height.equalTo(140)
        }
    }
    
    //点击下一步，跳到WIFI设置
    @IBAction func clickConnect(sender: UIButton)
    {
        
        jump2AnyController(ConfigurationVC())
    }
    
    //添加动画效果
    func setUp(imgV:UIImageView,duration:NSTimeInterval)
    {
        imgV.contentMode = .ScaleAspectFit
        imgV.animationRepeatCount = 0
        imgV.animationDuration = duration

        var tempArr = [UIImage]()
        
        for i in 1...(imgV == step1 ? 12 : 11)
        {
            tempArr.append(UIImage(named: (imgV == step1 ? "step1-\(i)" : "step2-\(i)"))!)
        }
        imgV.animationImages = tempArr
      
        imgV.startAnimating()
    }

    deinit
    {
        step1.stopAnimating()
        step1.animationImages = []
        
        step2.stopAnimating()
        step2.animationImages = []
        
        print("\(classForCoder)--hello there")
    }
    
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return self.scrol
    }
    
}
