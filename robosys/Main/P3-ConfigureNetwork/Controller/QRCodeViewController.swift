

//
//  QRCodeViewController.swift
//  robosys
//
//  Created by Cheer on 16/5/20.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import AVFoundation
import UIKit

class QRCodeViewController: AppViewController,AVCaptureMetadataOutputObjectsDelegate
{
    //-MARK:属性
    internal lazy var lastClass : String = ""
    private  let WIDTH = UIScreen.mainScreen().bounds.width
    
    private var alertV:AppAlertView!
    private var alertObj:AnyObject!
    
    private lazy var session = AVCaptureSession()
    private lazy var layer = AVCaptureVideoPreviewLayer()
 
    private lazy var timer = NSTimer()
    private lazy var loginM = loginModel.sharedInstance
    private lazy var connect = RobotConnect.shareInstance()
    private lazy var control = RobotControl.shareInstance()
    private lazy var networkM = networkModel.sharedInstance
    
    private lazy var imgView:UIImageView =
    {
        let imgV = UIImageView(frame:CGRectMake(0, 0, 0, 0))
        imgV.image = UIImage(named: "line")
        return imgV
    }()
    private lazy var contentLabel:UILabel =
    {
        let y = UIScreen.mainScreen().bounds.size.height - 200
        let label = UILabel(frame: CGRectMake(0,y,UIScreen.mainScreen().bounds.width,100))
        label.textAlignment = .Center
        label.numberOfLines = 2
        label.textColor = UIColor.whiteColor()
        label.text = "将机器人底部的二维码放入框内,即可自动扫描"
        return label
    }()
    private lazy var navBar:UIView =
    {
        let nav = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,64))
        nav.backgroundColor = UIColor.blackColor()
        
        let leftBtn = UIButton(frame: CGRectMake(5,25,66,34))
        leftBtn.setTitle("返回", forState: UIControlState.Normal)
        leftBtn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        leftBtn.addTarget(self, action: #selector(QRCodeViewController.back), forControlEvents: .TouchUpInside)
        
        nav.addSubview(leftBtn)
        
        
        return nav
    }()
    

    private weak var delegate:AVCaptureMetadataOutputObjectsDelegate?
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(0.01 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
        {
            [unowned self] in

            self.timer.invalidate()
            self.delegate = nil
            
            dispatch_async(dispatch_get_global_queue(0, 0), { 
                self.session.stopRunning()
            })
        }
    }
    
    
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
    
        let authStatus = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        
        if(authStatus == .Restricted || authStatus == .Denied)
        {
            let alert = UIAlertController(title:"无法使用相机", message:"请在iPhone中的\"设置-隐私-相机\"中允许访问相机", preferredStyle: .Alert)
            
            let action = UIAlertAction(title: "好的", style: .Default, handler: nil)
            alert.addAction(action)
            
            if let vc = UIApplication.sharedApplication().keyWindow!.rootViewController
            {
                vc.presentViewController(alert, animated: true, completion: nil)
            }
            else
            {
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
        
        delegate = self
        
        //开启
        session.startRunning()

        timer = NSTimer.scheduledTimerWithTimeInterval(4, target: self, selector: #selector(QRCodeViewController.animation(_:)), userInfo: imgView, repeats: true)
        
        timer.fireDate = NSDate.distantPast()
        
    }
    override func viewDidLoad()
    {
        super.viewDidLoad()
 
        self.view.backgroundColor = UIColor.whiteColor()
        
        setUp()
    }
    
    //-MARK:初始化
    func setUp()
    {
        let bg = UIImageView(frame: UIScreen.mainScreen().bounds)
        bg.image = UIImage(named: "扫描二维码")
        view.addSubview(bg)
        
        
        imgView.frame = CGRect(origin: CGPointMake(view.center.x - WIDTH * 0.3,view.center.y - WIDTH * 0.3), size: CGSizeMake(WIDTH * 0.6, 20))
        view.addSubview(imgView)

        view.backgroundColor = .lightGrayColor()
        view.addSubview(contentLabel)
        view.addSubview(navBar)
        
        if !Platform.isSimulator
        {
            let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
            
            do
            {
                let input = try AVCaptureDeviceInput(device: device)
                
                let output = AVCaptureMetadataOutput()
                output.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
                session.sessionPreset = AVCaptureSessionPresetHigh
                
                session.addInput(input)
                session.addOutput(output)
                output.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode128Code]
                
                layer = AVCaptureVideoPreviewLayer(session: session)
                layer.videoGravity = AVLayerVideoGravityResizeAspectFill
                layer.frame = UIScreen.mainScreen().bounds//CGRect(origin: CGPointMake(view.center.x - WIDTH * 0.3,view.center.y - WIDTH * 0.3), size: CGSizeMake(WIDTH * 0.6, WIDTH * 0.6))
                view.layer.insertSublayer(layer, atIndex:0)
                
            }
            catch
            {
                print(error)
            }
            
            //开始捕获
            session.startRunning()
        }
    }
 
    func animation(timer:NSTimer)
    {
        let imgV = timer.userInfo as! UIImageView
        
        UIView.animateKeyframesWithDuration(4, delay: 0, options: .CalculationModeCubic, animations: { 
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: {
                imgV.frame.origin.y = self.view.center.y + self.WIDTH * 0.3 - 20
            })
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: {
                imgV.frame.origin.y = self.view.center.y - self.WIDTH * 0.3
            })
        }, completion: nil)
    }
    //扫描方法
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!)
    {
        var isIllegal = false
        
        if (metadataObjects.count > 0)
        {
            //获得扫描数据，最后一个是最新扫描的数据
            if let tempStr = metadataObjects.last?.stringValue where tempStr.componentsSeparatedByString("-").count == 2
            {
                loginM.robotId = tempStr.componentsSeparatedByString("-").last!
            }
            //如果扫描失败
            else
            {
                alertV = UINib(nibName: "AppAlertView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AppAlertView
                alertV.titleLabel.hidden = true
                alertV.subTitleLabel.hidden = true
                alertV.backBtn.hidden = true
                alertV.contentLabel.text = "二维码无效，请重新扫描"
                alert(alertV, frame: CGRectMake(0, 0, 270, 240))
                isIllegal = true
            }
            
            // 停止扫描
            session.stopRunning()
            //暂停
            timer.fireDate = NSDate.distantFuture()
        }
        
        guard !isIllegal else
        {
            dismissViewControllerAnimated(false, completion: {
                    [weak self] in
                self?.session.startRunning()
                self?.timer.fireDate = NSDate.distantPast()
            })
            return
        }
        
        /*------------------------------------------------------------*/
        guard networkM.state == true else
        {
            Alert({}, title: "手机网络连接不可用", message: "")
            return
        }
        
        
        alertV = UINib(nibName: "AppAlertView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AppAlertView
    
        alertV.titleLabel.hidden = true
        alertV.subTitleLabel.hidden = true
        alertV.backBtn.removeFromSuperview()
        alertV.contentLabel.textAlignment = .Center
        alertV.contentLabel.text = "正在处理，请稍后"
        alertObj = alert(alertV, frame: CGRectMake(0, 0, 270, 240))
        
        NSThread.detachNewThreadSelector(#selector(self.OnLineOrNot), toTarget: self, withObject: nil)
    }
    
    func OnLineOrNot(){
        
        //60s判断机器人上线
        let res = connect.didReset(loginM.num, token: loginM.token,robotId:loginM.robotId,isLogin:false)
        /*
          - [0] : 0
          - [1] : 192.168.31.10
          - [2] : Robosys-PC
          - [3] : Robosys-PC
        */
        
        print(res.classForCoder)
        
        let retDic = self.connect.didQueryUserList(self.loginM.num, token: self.loginM.token, robotId: self.loginM.robotId) as NSDictionary
//
        let tempDic = ["res":res,"retDic":retDic]
        
//        self.performSelectorOnMainThread(#selector(self.judgeOnLine(_:)), withObject: res, waitUntilDone: true)
        self.performSelectorOnMainThread(#selector(self.judgeOnLine(_:)), withObject: tempDic, waitUntilDone: true)
    }
    
//    func judgeOnLine(resArr:NSArray){
    func judgeOnLine(rets:NSDictionary){
    
        let resArr = rets.objectForKey("res") as! NSArray
        
        //不在线就重新配置网络
        if resArr.firstObject as! Int == -1
        {
            //超时
            self.dismissViewControllerAnimated(true, completion:
            {
                self.alertV.dismiss()
                 self.Alert({[unowned self] in
                    
                        self.navigationController?.popViewControllerAnimated(true)
                        networkModel.sharedInstance.isConnectRobot = false
                        robotModel.sharedInstance.connect = false

                    }, title: "机器人不在线", message: "")
            })

        }else if resArr.firstObject as! Int == 301 || resArr.firstObject as! Int == 302{
            
            self.dismissViewControllerAnimated(true, completion: {
                self.alertV.dismiss()
                
                self.Alert({[unowned self] in
                    
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    }, title: "用户登录过期请重新登录", message: "")

                
            })

        }else if resArr.firstObject as! Int == 0{
            
            
            if resArr[1].length! != 0
            {
                self.dismissViewControllerAnimated(true, completion: {
                    robotModel.sharedInstance.online = true
                    
                    let retDic = rets.objectForKey("retDic") as! NSDictionary
                    
                    //userArray
                    let userArray : NSArray = retDic.objectForKey("userArray") as! NSArray
                    //管理员数量
                    let adminCount : NSNumber = retDic.objectForKey("adminCount") as! NSNumber
                    
                    let ret : NSNumber = retDic.objectForKey("ret") as! NSNumber
                    //
                    var isHaveMeBool = false
                    var isHaveAdminBool = false
                    
                    if Int(adminCount) == 0
                    {
                        isHaveAdminBool = false
                    }
                    else
                    {
                        isHaveAdminBool = true
                    }
                    
                    for i in 0 ..< userArray.count {
                        
                        let userName = Int(userArray.objectAtIndex(i) as! String)
                        
                        if userName != nil && userName != 0 {
                            
                            isHaveMeBool = true
                            break;
                        }
                    }
                    
                    //如果返回不成功
                    if Int(ret) != 0
                    {
                        
                        self.alertV.dismiss()
                        self.Alert({
                            
                            for v in self.navigationController!.viewControllers
                            {
                                if v.classForCoder == MainViewController.classForCoder()
                                {
                                    self.navigationController?.popToViewController(v, animated: true)
                                    return
                                }
                            }
                            
                            self.navigationController?.pushViewController(MainViewController(), animated: true)
                            
                            }, title: "查询失败", message: "")
                        
                        return
                    }
                    //
                    //有管理员
                    if isHaveAdminBool
                    {
                        //无我
                        if !isHaveMeBool
                        {
                            //绑定0
                            let bindingCode = self.connect.didBind(self.loginM.num, token: self.loginM.token, robotId: self.loginM.robotId, admin: 0)
                            
                            if bindingCode == 0{
                                
                                NSThread.detachNewThreadSelector(#selector(self.connectOnLineRob), toTarget: self, withObject: nil)
                            }
                            else
                            {
                                self.alertV.dismiss()
                                dispatch_async(dispatch_get_main_queue(), {
                                    
                                    let bindingAlertView = UINib(nibName: "AppAlertView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AppAlertView
                                    
                                    bindingAlertView.titleLabel.hidden = true
                                    bindingAlertView.subTitleLabel.hidden = true
                                    bindingAlertView.backBtn.removeFromSuperview()
                                    bindingAlertView.contentLabel.textAlignment = .Center
                                    bindingAlertView.contentLabel.text = "绑定失败"
                                    let alertViewController = self.alert(bindingAlertView, frame: CGRectMake(0, 0, 270, 60))
                                    alertViewController.show()
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                                        
                                        alertViewController.removeFromSuperview()
                                        self.session.startRunning()
                                    })
                                })
                            }
                        }
                            //有我
                        else
                        {
                            print("\(NSThread.currentThread())")
                            NSThread.detachNewThreadSelector(#selector(self.connectOnLineRob), toTarget: self, withObject: nil)
                        }
                    }else
                    {
                        self.alertV.dismiss()
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            let vc = BindViewController(nibName: "BindView",bundle: nil)
                            (vc.view as! BindView).isBind = isHaveMeBool
                            self.navigationController?.pushViewController(vc, animated: true)
                        })
                    }
                })
                
            }else{
                
                self.alertV.contentLabel.text = "机器人不在线请配置机器人联网"
                let btn = UIButton(frame: CGRectMake(50,160,200,40))
                btn.center.x = self.alertV.frame.width * 0.5
                btn.setBackgroundImage(UIImage(named: "小橙按钮"), forState: .Normal)
                btn.setTitle("配置网络", forState: .Normal)
                btn.addTarget(self, action: #selector(QRCodeViewController.jump2connect), forControlEvents: .TouchUpInside)
                self.alertV.addSubview(btn)
            }

        }else{
            
            //机器人不在线
            self.alertV.contentLabel.text = "机器人不在线请配置机器人联网"
            let btn = UIButton(frame: CGRectMake(50,160,200,40))
            btn.center.x = self.alertV.frame.width * 0.5
            btn.setBackgroundImage(UIImage(named: "小橙按钮"), forState: .Normal)
            btn.setTitle("配置网络", forState: .Normal)
            btn.addTarget(self, action: #selector(QRCodeViewController.jump2connect), forControlEvents: .TouchUpInside)
            self.alertV.addSubview(btn)
        }
    }
    
    //连接在线
    func connectOnLineRob(){
        //连接在线机器人
        let status = RobotConnect.shareInstance().didConnRobot(loginM.token, userName: loginM.num, robotId: loginM.robotId).firstObject as! Int
        
        print("connectOnLineRob+++++++++++\(status)")
        
        dispatch_async(dispatch_get_main_queue()) {
            
            if status == 0 {
                
                self.alertV.dismiss()
                
                self.Alert({
                    
                    networkModel.sharedInstance.isConnectRobot = true
                    robotModel.sharedInstance.connect = true
                    RobotManager.shareManager.getRobotInfo()
                    self.navigationController?.popToViewController((self.navigationController?.viewControllers[1])!, animated: true)
                    
                    }, title: "配对成功", message: "")
            }else if status == -1{
                
                self.alertV.dismiss()
                self.Alert({
                    
                    networkModel.sharedInstance.isConnectRobot = false
                    robotModel.sharedInstance.connect = false
                    RobotManager.shareManager.getRobotInfo()
                    self.navigationController?.popViewControllerAnimated(true)

                    }, title: "配对失败", message: "")
                
            }else if status == 301 || status == 302{
                
                self.alertV.dismiss()
                self.Alert({
                    
                    self.navigationController?.popToRootViewControllerAnimated(true)
                    
                    }, title: "用户登录过期请重新登录", message: "")
            }
        }
    }
    
    //去首页
    func toHomeViewController()
    {
        for sub in self.navigationController!.viewControllers
        {
            if sub.classForCoder == MainViewController.classForCoder()
            {
                self.navigationController?.popToViewController(sub, animated: true)
            }
        }
        
        self.navigationController?.pushViewController(MainViewController(), animated: true)
    }

    //点击配置网络
    func jump2connect()
    {
        networkModel.sharedInstance.isConnectRobot = false
        robotModel.sharedInstance.connect = false
        robotModel.sharedInstance.online = false
        
        let (success,ssid,bssid) = self.view.getSSID()
        
        if success && ssid.hasPrefix("MrBox") && bssid != "" && ssid.characters.count == 18
        {   
            
            self.alertV.dismiss()
            navigationController?.dismissViewControllerAnimated(true, completion: nil)
            
            for v in  navigationController!.viewControllers
            {
                if v.classForCoder == ConnectWiFiViewController.classForCoder()
                {
                    navigationController?.popToViewController(v, animated: true)
                    return
                }
            }
            
            navigationController?.pushViewController(ConnectWiFiViewController(nibName: "ConnectWiFiView",bundle: nil), animated: true)

        }else{
            
            self.alertV.dismiss()
            self.dismissViewControllerAnimated(true, completion: {
                RobotManager.shareManager.getRobotInfo()
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
    }
    //弹窗
    func alert(v:UIView,frame:CGRect)->AnyObject
    {
        
        let alert = UIAlertController(title:"", message:"", preferredStyle: .Alert)
        
        for v in alert.view.subviews
        {
            v.removeFromSuperview()
        }
        v.frame = frame
        v.center = view.center
        alert.view.addSubview(v)
        
        presentViewController(alert, animated: true, completion: nil)
        
        return alert
    }
    
    //隐藏状态栏
    override func prefersStatusBarHidden() -> Bool {
        return false
    }
    //返回
    func back()
    {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(0.01 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
        {
            [unowned self] in
            self.navigationController?.popViewControllerAnimated(true)
        }

    }
    deinit
    {
        print("\(classForCoder)--hello there")
    }
    

    
    
}
