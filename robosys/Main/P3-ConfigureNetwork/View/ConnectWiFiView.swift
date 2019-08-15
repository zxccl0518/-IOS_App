//
//  ConnectWiFiView.swift
//  robosys
//
//  Created by Cheer on 16/5/24.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit


class ConnectWiFiView: AppView
{
    //-MARK: 属性
    @IBOutlet weak var ensureBtn: UIButton!
    @IBOutlet weak var pswTxtField: UITextField!
    @IBOutlet weak var ssidTxtField: UITextField!
    private var status: Int!
    
    private lazy var SN = ""
    var timer : NSTimer?
    
    var alert:AppAlert!
    
    var isError = false
    {
        didSet
        {
            if isError
            {
                    let alertV = UINib(nibName: "AppAlertView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AppAlertView
                    
                    alertV.contentLabel.removeFromSuperview()
                    alertV.backBtn.removeFromSuperview()
                    
                    alertV.titleLabel.text = "连接服务器超时，请检查网络"
                    alertV.subTitleLabel.numberOfLines = 0
                    alertV.titleLabel.textAlignment = .Center
                    
                    alertV.subTitleLabel.text = "  如果没有听到机器人连上网的提示音，有可能是wifi账号密码错误或者信号差，请重新配置"
                
                    alertV.frame = CGRectMake(0, 0, 300, 300)
                    
                    let btn = UIButton(frame: CGRectMake(50,140,200,40))
                    btn.center.x = 160
                    btn.setBackgroundImage(UIImage(named: "小橙按钮"), forState: .Normal)
                    btn.addTarget(self, action: #selector(ConnectWiFiView.jump2Connect), forControlEvents: .TouchUpInside)
                    btn.setTitle("重新配置", forState: .Normal)
                    alertV.addSubview(btn)
                    
                    let label = UILabel(frame: CGRectMake(alertV.subTitleLabel.frame.origin.x,200,300,50))
                    label.attributedText = NSAttributedString(string:"如果听到机器人的提示音已经连上网，请扫描机器人底部二维码直接配对", attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont.systemFontOfSize(17)])
                    label.lineBreakMode = .ByWordWrapping
                    label.numberOfLines = 3
                    label.center.x = 160
                    alertV.addSubview(label)
                    
                    let btn1 = UIButton(frame: CGRectMake(50,250,200,40))
                    btn1.center.x = 160
                    btn1.setBackgroundImage(UIImage(named: "小蓝按钮"), forState: .Normal)
                    btn1.setTitle("连接在线机器人", forState: .Normal)
                    btn1.addTarget(self, action: #selector(ConnectWiFiView.jump2ScanQR), forControlEvents: .TouchUpInside)
                    alertV.addSubview(btn1)
                    
                    self.alert = AppAlert(frame: UIScreen.mainScreen().bounds, view: alertV, currentView: self, autoHidden: false)
            }
        }
    }
    
    func jump2Connect()
    {
        alert.dismiss()
        
        let (success,ssid,bssid) = getSSID()

        if success && ssid.hasPrefix("MrBox") && bssid != "" && ssid.characters.count == 18
        {
            
        }
        else
        {
            //没连接WIFI
            let vc = ScanRobotViewController(nibName:"ScanRobotView",bundle: nil)
            (vc.view as! ScanRobotView).isWifi = true
            jump2AnyController(vc)
        }
    }
    //跳转在线机器人
    func jump2ScanQR()
    {
        alert.dismiss()
        jump2AnyController(QRCodeViewController())
    }
    ///UITextField状态
    @IBAction func TxtFieldStatus(sender: AnyObject)
    {
        ensureBtn.enabled = !ssidTxtField.text!.isEmpty ? true : false
    }
    //-MARK: 生命周期
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        initHeadView("配置WIFI", imageName: "返回")
        
        initTxtField(ssidTxtField, string: "WIFI选择", type: "text")
        initTxtField(pswTxtField, string: "WIFI密码", type: "text")
        
        ssidTxtField.delegate = self
        pswTxtField.delegate = self
    }
    //-MARK:点击方法
    //点击确定
    
    @IBAction func clickEnsure(sender: UIButton)
    {
        ssidTxtField.resignFirstResponder()
        pswTxtField.resignFirstResponder()
        
        step1()
    }
    
    //步骤1
    func step1()
    {
        let (success,ssid,bssid) = getSSID()
        
        guard success && ssid.hasPrefix("MrBox") && bssid != "" && ssid.characters.count == 18 else
        {
            Alert({}, title: "请先连接机器人Wifi", message: "")
            return
        }
        
        //step1 >>>>>> 弹窗 正在发送 <<<<<<
        let v = UINib(nibName: "AppAlertView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AppAlertView
        v.titleLabel.hidden = true
        v.subTitleLabel.hidden = true
        v.contentLabel.textAlignment = .Center
        v.backBtn.hidden = true
        v.contentLabel.text = "正在发送wifi信息,\n请稍候.."
        v.frame = CGRectMake(0, 0, 300, 240)
        
        alert = AppAlert(frame: UIScreen.mainScreen().bounds, view: v, currentView: self, autoHidden: false)
    
            //SN: 小盒的序列号
        print("+++++_______  \(NSThread.currentThread())")
        
        dispatch_async(dispatch_get_global_queue(0, 0)) { [unowned self] in
            
            self.SN = self.connect.didWifiSetup(self.ssidTxtField.text, pass: self.pswTxtField.text)
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {[unowned self] in
            
            self.step2(self.SN, v: v)
        })
    }
    
    func step2(SN:String,v:AppAlertView){
        
        let robotManager = RobotManager.shareManager
        
        
        v.contentLabel.text = "机器人正在连接路由器wifi"
        
        //查询机器人网络连接状态
        robotManager.robotOnlineState(nil, netFinished: { (resArry) in
            
            //不在线就进首页
            if resArry.firstObject as! Int == -1
            {
                self.alert.dismiss()
                
                self.Alert({[unowned self] in
                    
                    let vc = ScanRobotViewController(nibName:"ScanRobotView",bundle: nil)
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(0.01 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
                    {
                        networkModel.sharedInstance.isConnectRobot = false
                        robotModel.sharedInstance.connect = false
                        self.getCurrentVC().navigationController?.pushViewController(vc, animated: true)
                    }
                }, title: "机器人不在线,请为机器人配置网络", message: "")
                
                //不在线就重新配置
            }
            else if resArry.firstObject as! Int == 301 || resArry.firstObject as! Int == 302
            {
                self.alert.dismiss()
                self.Alert({
                    [unowned self] in
                    
                    self.getCurrentVC().navigationController?.popToRootViewControllerAnimated(false)
                    }, title: "用户登录过期请重新登录", message: "")
                
            }
            else if resArry.firstObject as! Int == 0
            {
                print("\(NSThread.currentThread())")
                
                print("resArry+++++++________    \(resArry)")
                
                //如果ip地址不为空
                if resArry[1].length! != 0{
                    
                    
                    dispatch_async(dispatch_get_global_queue(0, 0), {[unowned self] in
                        //连接机器人
                        self.connectRobot(v)
                    })
                
                }else{
                    
                    self.alert.dismiss()
                    self.isError = true
                    networkModel.sharedInstance.isConnectRobot = false
                    robotModel.sharedInstance.connect = false
                    robotModel.sharedInstance.online = false
                    
                }
                
            }
            else {

                self.alert.dismiss()
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(0.01 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
                {[unowned self] in
        
                    self.getCurrentVC().navigationController?.pushViewController(MainViewController(), animated: true)
                }
            }
            
        })

        
    }
    
    
//    func step2(SN:String,v:AppAlertView)
//    {
//        //并发队列去执行20s内判断
//        dispatch_async(dispatch_get_global_queue(0, 0))
//        {
//            [weak self] in
//            
//            if SN != ""
//            {
//                self!.loginM.robotId = SN//"B10CN7180061"
//                
//                //主线程入口1
//                dispatch_async(dispatch_get_main_queue(),
//                               {
//                                [weak self] in
//                                
//                                v.contentLabel.text = "机器人正在连接路由器wifi"
//                                
//                                self!.step3(v)
//                    })
//                return
//            }
//    
//            //不return就进入主线程入口2
//            dispatch_async(dispatch_get_main_queue(),
//            {//主线程
//                [weak self] in
//                
//                v.contentLabel.text = "账号密码错误，请重新输入"
//                
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(2 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
//                {
//                    [weak self] in
//
//                        self!.alert.dismiss()
//                    
//                        //判断
//                        let (success,ssid,bssid) = self!.getSSID()
//                        
//                        if success && ssid.hasPrefix("MrBox") && bssid != "" && ssid.characters.count == 18
//                        {
//                            
//                            //连上wifi，保持页面什么也不做
//                        }
//                        else
//                        {
//                            self!.jump2AnyController(ScanRobotViewController(nibName:"ScanRobotView",bundle: nil))
//                    }
//                }
//            })//主线程
//        }//子线程
//    }
//    
//    
//    
//    func step3(v:AppAlertView)
//    {
//        
//        dispatch_async(dispatch_get_global_queue(0, 0),
//                       {
//                        [weak self] in
//                        //60s判断机器人上线
//                        
//                        let retDic = self!.connect.didQueryUserList(self?.loginM.num, token: self?.loginM.token, robotId: self?.loginM.robotId) as NSDictionary
//                        
//                        let userArray : NSArray = retDic.objectForKey("userArray") as! NSArray
//                        let adminCount : NSNumber = retDic.objectForKey("adminCount") as! NSNumber
//                        let ret : NSNumber = retDic.objectForKey("ret") as! NSNumber
//                        
//                        let isHaveMeBool = false
//                        var isHaveAdminBool = false
//                        
//                        if Int(adminCount) == 0
//                        {
//                            isHaveAdminBool = false
//                        }
//                        else
//                        {
//                            isHaveAdminBool = true
//                        }
//                        
//                        for i in 0 ..< userArray.count {
//                            
//                            let userName = Int(userArray.objectAtIndex(i) as! String)
//                            //如果没有
//                            if userName != nil && userName != 0 {
//                                
//                                self!.alert.dismiss()
//                                self!.isError = true
//                                break;
//                            }
//                        }
//                        
//                        //如果返回不成功
//                        if Int(ret) != 0
//                        {
//                            self!.alert.dismiss()
//                            self!.isError = true
//                            return
//                        }
//                        
//                        //有管理员
//                        if isHaveAdminBool
//                        {
//                            var isBindingSuccessBool = true
//                            
//                            //无我
//                            if !isHaveMeBool
//                            {
//                                //绑定0
//                                let bindingCode = self!.connect.didBind(self!.loginM.num, token: self!.loginM.token, robotId: self!.loginM.robotId, admin: 0)
//                                
//                                if bindingCode == 0{
//                                    isBindingSuccessBool = true
//                                }
//                                else
//                                {
//                                    isBindingSuccessBool = false
//                                }
//                            }
//                            //有我
//                            else
//                            {
//                                self!.connectRobot(v)
//                            }
//                            //如果绑定失败
//                            if !isBindingSuccessBool
//                            {
//                                dispatch_async(dispatch_get_main_queue(), {
//                                    self!.alert.dismiss()
//                                    self!.isError = true
//                                })
//                            }
//                            else
//                            {
//                                self!.connectRobot(v)
//                            }
//                        }
//                        else
//                        {
//                            dispatch_async(dispatch_get_main_queue(), {
//                                
//                                self!.alert.dismiss()
//                                
//                                let vc = BindViewController(nibName: "BindView",bundle: nil)
//                                (vc.view as! BindView).isBind = isHaveMeBool
//                                self!.jump2AnyController(vc)
//                            })
//                        }
//            })
//    }
    
    
    //step5  >>>>>>弹窗 正在配对<<<<<<
    func connectRobot(v:AppAlertView)
    {

        
        
        for _ in 0..<6{
            
            self.status = self.connect.didConnRobot(self.loginM.token, userName: self.loginM.num, robotId: self.loginM.robotId).firstObject as! Int
            
            if self.status == 0 {
                break
            }
        }
        
            alert.dismiss()
        
                
                switch status
                {
                case 301,302:
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                    self.Alert({[unowned self] in
                        self.jump2AnyController(HomeViewController())
                        }, title: "用户过期请重新登录", message: "")
                    }
                    
                case 0:
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(0.01 * Double(NSEC_PER_SEC))),dispatch_get_main_queue()){
                    //配对结果
                    self.Alert({[unowned self] in
                        
                            robotModel.sharedInstance.connect = true
                            robotModel.sharedInstance.online = true
                            networkModel.sharedInstance.isConnectRobot = true
                        
                            RobotManager.shareManager.getRobotInfo()
                        
                            print("------\(NSThread.currentThread())")
                        
                            self.jump2AnyController(MainViewController())
                        }, title: "配对成功", message: "")
                    }
                //超时
                case -1:
                    
                    self.isError = true
                default:
                    self.isError = true
            }
    }
    
    
    //UITextField状态
    @IBAction func clickSSID(sender: UITextField)
    {
        if !Platform.isSimulator
        {
            let (success,ssid,bssid) = getSSID()
            print((success,ssid,bssid))
        }
    }
    @IBAction func txtFieldStatus(sender: UITextField) {
        ensureBtn.enabled = !pswTxtField.text!.isEmpty && !ssidTxtField.text!.isEmpty ? true : false
    }
    //点击问号
    @IBAction func clickIssue(sender: AnyObject)
    {
        let v = UINib(nibName: "AppAlertView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AppAlertView
        v.frame = CGRectMake(0, 0, 300, 240)
        _ = AppAlert(frame: UIScreen.mainScreen().bounds, view: v, currentView: self, autoHidden: false)
    }
    //点击不联网
    @IBAction func clickNoWIFI(sender: AnyObject)
    {
        if Platform.isSimulator
        {
            jump2AnyController(ScanRobotViewController(nibName:"ScanRobotView",bundle: nil))
        }
        else
        {
            let (success,ssid,bssid) = getSSID()
            
            if success && ssid.hasPrefix("MrBox") && bssid != "" && ssid.characters.count == 18
            {
                let status = connect.didConnOfflineRobot() == 0
                
                networkM.isConnectRobot = status
                
                robotM.connect = status
                robotM.online = false
                
                Alert({
                    
                    [unowned self] in
                    
                    self.jump2AnyController(MainViewController())
                    
                    }, title: status ? "成功连接离线机器人" : "连接失败", message: "")
            }
            else
            {
                //没连接WIFI
                
                jump2AnyController(ScanRobotViewController(nibName:"ScanRobotView",bundle: nil))
            }
            
        }
    }
    
    deinit
    {
        print("\(classForCoder)--hello there")
    }
}
