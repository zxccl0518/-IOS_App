//
//  LeftView.swift
//  robosys
//
//  Created by Cheer on 16/5/20.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit
import SVProgressHUD
class LeftView: AppView,UIGestureRecognizerDelegate//,CAAnimationDelegate
{
    @IBOutlet weak var leftVoiceBtn: UIButton!
    @IBOutlet weak var rightVoiceBtn: UIButton!
    @IBOutlet weak var slider: UISlider!
    
    //是否有文字单例
    let titleM : titleModel = titleModel.sharedInstance
    
    //wifi列表模型
    var wifiListData : [CellWifiModel]?
    
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        if touch.isEqual(UISlider) {
            return true
        }else{
            return false
        }
    }
    
    var isShow : Bool = false
    
    private lazy var left:UISwipeGestureRecognizer =
    {
        let ges = UISwipeGestureRecognizer(target: self, action: #selector(LeftView.swipeGesture(_:)))
        ges.direction = .Left
        
        return ges
    }()
    
    func swipeGesture(swipe:UISwipeGestureRecognizer)
    {
        if swipe.direction == .Left && swipe.view!.frame.origin.x > -swipe.view!.frame.width
        {
            hide()
        }
    }
    
    override func awakeFromNib()
    {
        //设置滑块的图片
        slider.setThumbImage(UIImage(named: "进度"), forState: .Normal)
        slider.setThumbImage(UIImage(named: "进度-按下"), forState: .Selected)
        //设置划过
        slider.setMinimumTrackImage(UIImage(named: "音量条"), forState: .Normal)
        //设置未划过
        slider.setMaximumTrackImage(UIImage(named: "音量底"), forState: .Normal)
        slider.backgroundColor = .clearColor()
        
        //设置滑块位置
        slider.value = 0.5
        //最小边界值
        slider.minimumValue = 0.0
        //最大边界值
        slider.maximumValue = 1.0
        
//        addGestureRecognizer(left)
        
        hidden = true
        
    }
    
    
    func hide()
    {
        isShow = false
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.toValue = -frame.width
        animation.duration = 0.15
        animation.removedOnCompletion = false
        animation.repeatCount = 1
        animation.fillMode = kCAFillModeForwards
//        animation.delegate = self
        layer.addAnimation(animation, forKey: nil)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(0.25 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
        {
            [weak self] in
            
            self!.hidden = true
        }
    }

    func show()
    {
        hidden = false
        isShow = true
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(0.1 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
        {
            [weak self] in
            
            let animation = CABasicAnimation(keyPath: "transform.translation.x")
            animation.toValue = 0
            animation.duration = 0.2
            animation.removedOnCompletion = false
            animation.repeatCount = 1
            animation.fillMode = kCAFillModeForwards
//            animation.delegate = self
           
            self!.layer.addAnimation(animation, forKey: nil)
            
            let vc = self!.getCurrentVC()
            guard self!.isShow == true else {
                            return
        }
            let tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
            tapGestureRecognizer.addTarget(self!, action: #selector(self!.tapSelector))
            
            tapGestureRecognizer.delegate = self
            
            vc.view.addGestureRecognizer(tapGestureRecognizer)
            vc.view.addGestureRecognizer(self!.left)
        }
    }
    
    func  tapSelector(){
         hide()
    }

    //-MARK:连接在线方法
    @IBAction func connectOnline(sender: AnyObject)
    {
//        let vc = QRCodeViewController()
//        vc.lastClass = classForCoder.debugDescription()
//        getCurrentVC().navigationController?.pushViewController(vc, animated: false)
        let vc = LeftConnectViewController()
        getCurrentVC().navigationController?.pushViewController(vc, animated: true)
    }
    
    //配置网络
    @IBAction func configrationWIFI(sender: AnyObject)
    {
            //拿到WIFI的SSID
            let (success,ssid,bssid) = self.getSSID()

            //判断是否是连接了离线机器人 或者 在线机器人
            guard (success && ssid.hasPrefix("MrBox") && bssid != "" && ssid.characters.count == 18) || (self.networkM.isConnectRobot && self.robotM.online!) else
            {
                print("提示用户连接机器人热点")
                let vc = ScanRobotViewController(nibName:"ScanRobotView",bundle: nil)
                (vc.view as! ScanRobotView).isWifi = true
                
                titleM.title = ""
                self.titleM.title = "配置网络"
                
                self.jump2AnyController(vc)
                SVProgressHUD.dismiss()
                return
            }

            print("连接了机器人,将要获取机器人的WIFI列表")

            SVProgressHUD.showWithStatus("正在检测机器人网络状态")
        
        
            dispatch_async(dispatch_get_global_queue(0, 0)) {[weak self] in
                
                if let dict = self!.control.didQueryWifiList() {
                    
                    dispatch_async(dispatch_get_main_queue(), {
                        
                        self!.titleM.title = ""
                        let Dic = dict as! [String : AnyObject]
                        let switchVC = SwitchWifiVC()
                        switchVC.CellWifi = Dic
                        //跳转到wifi列表
                        self!.getCurrentVC().navigationController?.pushViewController(switchVC, animated: false)
                        SVProgressHUD.dismiss()
                    })
                    
                }else{
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                    
                        //拿到WIFI的SSID
                        let (success,ssid,bssid) = self!.getSSID()
                        
                        //判断是否是连接了离线机器人 或者 在线机器人
                        guard (success && ssid.hasPrefix("MrBox") && bssid != "" && ssid.characters.count == 18)else
                        {
                            print("提示用户连接机器人热点")
                            let vc = ScanRobotViewController(nibName:"ScanRobotView",bundle: nil)
                            (vc.view as! ScanRobotView).isWifi = true
                            
                            self!.titleM.title = ""
                            self!.titleM.title = "配置网络"
                            
                            self!.jump2AnyController(vc)
                            SVProgressHUD.dismiss()
                            return
                        }
                        
                        // 走原来的配网流程
                        self!.titleM.title = "配置网络"
                        SVProgressHUD.dismiss()
                        
                        self?.getCurrentVC().navigationController?.pushViewController(ConnectWiFiViewController(nibName: "ConnectWiFiView",bundle: nil), animated: true)
                    }
                }
        }
    }
    
    //点击退出
    @IBAction func logout(sender: UIButton)
    {
        guard networkM.state == true else
        {
            Alert({}, title:"手机网络连接不可用", message: "")
            return
        }
        
        let (success,ssid,bssid) = getSSID()
        
        if success && ssid.hasPrefix("MrBox") && bssid != "" && ssid.characters.count == 18
        {
            Alert({}, title: "请检查WiFi是否能上网", message: "")
    
            return
        }
        
        loginM.isAutoLogin = false
        
        getCurrentVC().navigationController!.popToRootViewControllerAnimated(true)
        

        dispatch_async(dispatch_get_global_queue(0, 0))
        {
            [weak self] in
            self!.connect.didLogout(self!.loginM.num, token: self!.loginM.token)
        }
      
    }
    
    //点击改变slider条
    @IBAction func changeSlider(sender: UISlider)
    {
        guard  networkM.isConnectRobot == true else
        {
            Alert({}, title: "请连接机器人", message: "")
            return
        }

        control.didSetVolume(Int32(sender.value * 100))
    }

    
    @IBAction func volumeMax(sender: UIButton)
    {
        guard  networkM.isConnectRobot == true else
        {
            Alert({}, title: "请连接机器人", message: "")
            return
        }
        
//        slider.value += 0.1
        slider.value = 1
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {[weak self] in
            
            self!.control.didSetVolume(100)
        }
    }
    
    @IBAction func volumeMin(sender: UIButton)
    {
        guard  networkM.isConnectRobot == true else
        {
            Alert({}, title: "请连接机器人", message: "")
            return
        }
//        slider.value -= 0.1
        slider.value = 0
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {[weak self] in
            
            self!.control.didSetVolume(0)
        }
    }
    
    //点击唤醒
    @IBAction func clickWeakUp(sender: UIButton)
    {
        guard  networkM.isConnectRobot == true else
        {
            Alert({}, title: "请连接机器人", message: "")
            return
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {[weak self] in
            
            self!.control.didWakeup(1)
        }
    }
    
    //点击睡眠
    @IBAction func clickSleep(sender: UIButton)
    {
        guard  networkM.isConnectRobot == true else
        {
            Alert({}, title: "请连接机器人", message: "")
            return
        }
        
        dispatch_async(dispatch_get_global_queue(0, 0)) {[weak self] in
            
            self!.control.didWakeup(0)
        }
    
    }
}
