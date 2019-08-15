//
//  MainViewController.swift
//  robosys
//
//  Created by Cheer on 16/5/26.
//  Copyright © 2016年 joekoe. All rights reserved.
//  休闲主控制器

import UIKit

class MainViewController:AppViewController,UIScrollViewDelegate
{
    lazy var connect = RobotConnect.shareInstance()
    
    //单例
    let control : RobotControl = RobotControl.shareInstance()
    //获取wifi列表的数据
    
    
    var scrollView = UIScrollView()
    
    lazy var titleUnderLineView : UIView = {
       
        let v = UIView()
        v.backgroundColor = UIColor.redColor()
        
        return v
    }()
    
    lazy var clickedTitleBtn = UIButton()
    
    var temp:CGFloat!
    var window:UIView!
    var leftView:LeftView!

    let titleArray = ["学习","休闲","发现","我的"]
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        leftView.hidden = true
        window.hidden = false
        
    }
    
    
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        window.hidden = true
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupScrollView()
        setupAllChildVC()
        setupTitlesView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
               
        UIView.animateWithDuration(0.01) {
            
        ((self.scrollView.subviews[1] as! RecreationalView).headView).titleLabel.text =  networkModel.sharedInstance.isConnectRobot ? robotModel.sharedInstance.name : "未连接"
            
            
        print("viewDidAppear++++\(networkModel.sharedInstance.isConnectRobot)+++++++\(((self.scrollView.subviews[1] as! RecreationalView).headView ).titleLabel.text)")
        }
    }
    
    
    func setupAllChildVC()
    {
        for index in 0..<titleArray.count
        {
            var controller = UIViewController()
            switch index
            {
                
            case 0: controller = LearnViewController()
            case 1: controller = RecreationalViewController(nibName: "RecreationalView",bundle: nil)
            case 2: controller = FindViewController()
            case 3: controller = MyViewController(nibName: "MyView",bundle: nil)
                
            default:break
            }
            addChildViewController(controller)
            controller.view.frame = CGRectMake(UIScreen.mainScreen().bounds.width * CGFloat(index), 0, UIScreen.mainScreen().bounds.width, UIScreen.mainScreen().bounds.height)
            scrollView.addSubview(controller.view)
            controller.didMoveToParentViewController(self)
        }
        let contentW = CGFloat(childViewControllers.count) * scrollView.frame.size.width
        scrollView.contentSize = CGSizeMake(contentW,300)
        scrollView.contentOffset = CGPointMake(UIScreen.mainScreen().bounds.width,0)
        
    }
    
    func setupTitlesView()
    {
        window = UIView(frame: CGRectMake(0,view.frame.size.height - 60,view.frame.size.width,60))
        window.backgroundColor = UIColor(red: 17 / 255, green: 22 / 255, blue: 51 / 255, alpha: 0.2)
        
        view.addSubview(window)
        
        leftView = UINib(nibName: "LeftView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! LeftView
        leftView.frame = CGRectMake(0, 0,UIScreen.mainScreen().bounds.width * 0.75,UIScreen.mainScreen().bounds.height)
        view.addSubview(leftView)
        
        titleUnderLineView.frame.size.height = 1
        titleUnderLineView.frame.origin.y = window.frame.size.height - titleUnderLineView.frame.size.height
        titleUnderLineView.backgroundColor = UIColor.redColor()
        window.addSubview(titleUnderLineView)
        
        let titleW = window.frame.size.width / CGFloat(titleArray.count)
        let titleH = window.frame.size.height
        
        for i in 0..<titleArray.count
        {
            let titleButton = UIButton(type: UIButtonType.Custom)
            titleButton.tag = i
            titleButton.addTarget(self, action: #selector(MainViewController.titleClick(_:)), forControlEvents: .TouchUpInside)
            window.addSubview(titleButton)
            
            titleButton.setImage(UIImage(named: "\(titleArray[i])"), forState: UIControlState.Normal)
            titleButton.setImage(UIImage(named:"\(titleArray[i]) + 1"), forState: UIControlState.Selected)
            
            titleButton.imageView?.contentMode = .ScaleAspectFit
            titleButton.frame.size.width = titleW
            titleButton.frame.size.height = titleH
            titleButton.frame.origin.y = 0
            titleButton.frame.origin.x = CGFloat(i) * titleW
            
            if i == 1
            {
                titleButton.selected = true
                clickedTitleBtn = titleButton
                titleButton.titleLabel?.sizeToFit()
                titleUnderLineView.frame.size.width = (titleButton.titleLabel?.frame.size.width)!
                titleUnderLineView.center.x = titleButton.center.x
            }            
        }
    }
    
    func setupScrollView()
    {
        automaticallyAdjustsScrollViewInsets = false
        
        scrollView = UIScrollView(frame: view.bounds)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.pagingEnabled = true
        scrollView.bounces = false
        scrollView.scrollEnabled = false

        view.addSubview(scrollView)
    }
    //MARK: - 监听
    func titleClick(titleButton:UIButton)
    {
        
        navigationController?.dismissViewControllerAnimated(true, completion: nil)

        clickedTitleBtn.selected = false
        titleButton.selected = true
        clickedTitleBtn = titleButton
        
        UIView.animateWithDuration(0.25)
        {
            [weak self]() -> Void in
            self?.titleUnderLineView.frame.size.width = (titleButton.titleLabel?.frame.size.width)!
            self?.titleUnderLineView.center.x = titleButton.center.x
        }
        var offset = scrollView.contentOffset
        offset.x = CGFloat(titleButton.tag) * scrollView.frame.size.width
        
        if titleButton.tag == 1
        {
            ((scrollView.subviews[1] as! RecreationalView).headView).titleLabel.text =  networkModel.sharedInstance.isConnectRobot ? robotModel.sharedInstance.name : "未连接"
                        
            if  networkModel.sharedInstance.state == true
            {
                (scrollView.subviews[1] as! RecreationalView).warningLabel.hidden = true
                (scrollView.subviews[1] as! RecreationalView).warningImg.hidden = true

            }else{
                (scrollView.subviews[1] as! RecreationalView).warningLabel.hidden = false
                (scrollView.subviews[1] as! RecreationalView).warningImg.hidden = false
            }
            
        }
        
        if titleButton.tag == 3
        {
            
            let (success,ssid,_) = view.getSSID()
            
            //当前连接的是离线机器人
            if networkModel.sharedInstance.isConnectRobot && success && ssid.hasPrefix("MrBox") && ssid.characters.count == 18{
                
                (self.scrollView.subviews[3] as! MyView).tableView?.reloadData()
                
            }else{
                //查询机器人 改变状态    判断是否连接的离线机器人
                if let id  = loginModel.sharedInstance.robotId where id.characters.count > 0
                {
                    dispatch_async(dispatch_get_global_queue(0, 0), {
                        let res = RobotConnect.shareInstance().didOnline(loginModel.sharedInstance.num, token: loginModel.sharedInstance.token, robotId: loginModel.sharedInstance.robotId) == 0
                        robotModel.sharedInstance.online = res ?  true : false
                        
                        //机器人不在线,连接断开
                        if !robotModel.sharedInstance.online!
                        {
                            robotModel.sharedInstance.connect = false
                            networkModel.sharedInstance.isConnectRobot = false
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            ((self.scrollView.subviews[1] as! RecreationalView).headView).titleLabel.text =  networkModel.sharedInstance.isConnectRobot ? robotModel.sharedInstance.name : "未连接"
                            (self.scrollView.subviews[3] as! MyView).tableView?.reloadData()
                        })
                    })
                }else{
                    robotModel.sharedInstance.connect = false
                    networkModel.sharedInstance.isConnectRobot = false
                    dispatch_async(dispatch_get_main_queue(), { 
                        ((self.scrollView.subviews[1] as! RecreationalView).headView).titleLabel.text =  networkModel.sharedInstance.isConnectRobot ? robotModel.sharedInstance.name : "未连接"
                        (self.scrollView.subviews[3] as! MyView).tableView?.reloadData()
                    })
                }
            }
        }
        scrollView.setContentOffset(offset, animated: false)
    }
    
    deinit
    {
        scrollView.delegate = nil
        print("\(classForCoder)--hello there")
    }
}
