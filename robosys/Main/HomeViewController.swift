//
//  HomeViewController.swift
//  robosys
//
//  Created by Cheer on 16/5/18.
//  Copyright © 2016年 joekoe. All rights reserved.
//  登录界面

import UIKit
import AVFoundation

class HomeViewController: AppViewController,UITextFieldDelegate
{
    //-MARK: 属性
    private let btnColor = UIColor(red: 169/255, green: 185/255, blue: 234/255, alpha: 1)
    private lazy var tempTextField = UITextField()
    private lazy var connect = RobotConnect.shareInstance()
    private lazy var loginM = loginModel.sharedInstance
    private lazy var networkM = networkModel.sharedInstance
    private lazy var registM = registModel.sharedInstance
    private var alert:AppAlert!
    var isAutoLoginBool = false
    private lazy var popView:UIView =
    {
        let popView = UIView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width - 40 ,80))
        popView.backgroundColor = UIColor(white: 1, alpha: 0.9)
        popView.layer.cornerRadius = 7
        
        let label = UILabel(frame: popView.frame)
        label.textColor = .blackColor()
        label.font = UIFont.systemFontOfSize(17)
        label.text = "自动登录中..."
        label.textAlignment = .Center
        
        popView.addSubview(label)
        
        return popView
    }()
    
    
    @IBOutlet weak var pswTxtField: UITextField!
    @IBOutlet weak var userNameTxtField: UITextField!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var forgotPswBtn: UIButton!
    
    
    override func viewDidAppear(animated: Bool) {
        if self.alert != nil {
            self.alert.dismiss()
        }
        
        self.pswTxtField.resignFirstResponder()
        self.userNameTxtField.resignFirstResponder()
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        self.pswTxtField.resignFirstResponder()
        self.userNameTxtField.resignFirstResponder()
    }
    
    //-MARK: 生命周期
    override func viewWillAppear(animated: Bool)
    {
        super.viewWillAppear(animated)
        
        let reachability = Reachability.reachabilityForInternetConnection()
        let internetStatus = reachability.currentReachabilityStatus()
        if internetStatus == NotReachable {
            networkM.state = false
        } else {
            networkM.state = true
        }
        
        self.pswTxtField.resignFirstResponder()
        self.userNameTxtField.resignFirstResponder()
        
        if self.alert != nil {
            self.alert.dismiss()
        }

        self.isAutoLoginBool = loginM.isAutoLogin
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        userNameTxtField.delegate = self
        pswTxtField.delegate = self

        userNameTxtField.text = ""
        pswTxtField.text = ""
        
        if loginM.isAutoLogin {
            userNameTxtField.text = KeychainWrapper.defaultKeychainWrapper().stringForKey("robosys_username")
            pswTxtField.text = KeychainWrapper.defaultKeychainWrapper().stringForKey("robosys_password")
            
            guard userNameTxtField.text!.checkMatch(const.telPatten) else
            {
                alert.dismiss()
                
                Alert({
                    self.registerBtn.userInteractionEnabled = true
                    self.forgotPswBtn.userInteractionEnabled = true
                    }, title:"手机号格式不正确，请输入11位数字", message: "")
                return
            }
            guard pswTxtField.text!.checkMatch(const.pswPatten) else
            {
                alert.dismiss()
                
                Alert({
                    [unowned self] in
                    self.pswTxtField.text = ""
                    self.registerBtn.userInteractionEnabled = true
                    self.forgotPswBtn.userInteractionEnabled = true
                    }, title:"密码格式不正确，请检查密码", message: "")
                return
            }

            alert = AppAlert(frame: UIScreen.mainScreen().bounds, view: popView, currentView: view, autoHidden: false)
            alert.isLogin = true
            
            self.login(UIButton())
            
        } else {
            guard networkM.state == true else
            {
                //                alert.dismiss()
                
                Alert({
                    
                    self.registerBtn.userInteractionEnabled = true
                    self.forgotPswBtn.userInteractionEnabled = true
                    
                    }, title:"手机网络连接不可用", message: "")
                return
            }
            
        }
                
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(HomeViewController.reachabilityChanged(_:)), name: kReachabilityChangedNotification, object: nil)
        
        const.hostReach.startNotifier()
        
        let result = view.getSSID()
        
        
        
        if result.0
        {
            NSUserDefaults.standardUserDefaults().setObject(result.1, forKey: "robosys_ssid")
        }
        else
        {
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: "robosys_ssid")
        }
        
        setUp()
    }
    func reachabilityChanged(note:NSNotification)
    {
        let curReach = note.object as! Reachability
        assert(curReach.isKindOfClass(Reachability.classForCoder()))
        if curReach.currentReachabilityStatus() == NotReachable
        {
            networkM.state = false
            networkM.isConnectRobot = false
        }
        else
        {
            networkM.state = true
        }
    }
    override func viewWillDisappear(animated: Bool)
    {
        super.viewWillDisappear(animated)
        
        pswTxtField.resignFirstResponder()
        userNameTxtField.resignFirstResponder()
        
        userNameTxtField.delegate = nil
        pswTxtField.delegate = nil
    }
    //-MARK: 初始化
    func setUp()
    {
        initTxtField(userNameTxtField,string:"手机",type: "image")
        initTxtField(pswTxtField,string:"密码",type: "image")
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(HomeViewController.textFieldEditChange(_:)), name: "UITextFieldTextDidChangeNotification", object: userNameTxtField)
        
        registerBtn.setTitleColor(const.globalColor, forState: .Normal)
        forgotPswBtn.setTitleColor(const.globalColor, forState: .Normal)
    }
    
    func textFieldEditChange(noti:NSNotification){
        
        var textF = noti.object as! UITextField
        let toBeString:NSString = textF.text!
        
        if toBeString.length > 11 {
            textF.text = toBeString.substringToIndex(11)
        }
    }
    
    //-MARK: 点击方法
    ///UITextField状态
    @IBAction func TxtFieldStatus(sender: AnyObject)
    {
        loginBtn.enabled = !userNameTxtField.text!.isEmpty && !pswTxtField.text!.isEmpty ? true : false
    }
    ///登陆动作
    @IBAction func login(sender: UIButton)
    {
        
        pswTxtField.resignFirstResponder()
        userNameTxtField.resignFirstResponder()
        registerBtn.userInteractionEnabled = false
        forgotPswBtn.userInteractionEnabled = false
        loginBtn.enabled = false
        
        //2
        dispatch_async(dispatch_get_main_queue()) { 
            
            [unowned self] in
            
            var label : UILabel?
            
            for v in self.popView.subviews
            {
                if v is UILabel
                {
                    label = v as? UILabel
                }
            }
            
            if self.isAutoLoginBool
            {
                label?.text = "自动登录中..."
            }
            else
            {
                label?.text = "登录中..."
            }
            
            self.alert = AppAlert(frame: UIScreen.mainScreen().bounds, view: self.popView, currentView: self.view, autoHidden: false)
            self.alert.isLogin = true
            self.view.addSubview(self.alert)
            self.login()
        }
    }
    
    func login()
    {
        if Platform.isSimulator
        {
            navigationController?.pushViewController(MainViewController(), animated: true)
            return
        }
        
        isAutoLoginBool = false
        guard networkM.state == true else
        {
            alert.dismiss()
            
            Alert({
                
                self.registerBtn.userInteractionEnabled = true
                self.forgotPswBtn.userInteractionEnabled = true
                
                }, title:"手机网络连接不可用", message: "")
            return
        }
        guard userNameTxtField.text!.checkMatch(const.telPatten) else
        {
            alert.dismiss()
            
            Alert({
                self.registerBtn.userInteractionEnabled = true
                self.forgotPswBtn.userInteractionEnabled = true
                }, title:"手机号格式不正确，请输入11位数字", message: "")
            return
        }
        guard pswTxtField.text!.checkMatch(const.pswPatten) else
        {
            alert.dismiss()
            
            Alert({
                [unowned self] in
                self.pswTxtField.text = ""
                self.registerBtn.userInteractionEnabled = true
                self.forgotPswBtn.userInteractionEnabled = true
                }, title:"密码格式不正确，请检查密码", message: "")
            return
        }
        
        if view.getSSID().ssid.hasPrefix("MrBox")
        {
            alert.dismiss()
            
            Alert({
                [unowned self] in
                self.userNameTxtField.text = KeychainWrapper.defaultKeychainWrapper().stringForKey("robosys_username")
                self.pswTxtField.text = ""
                self.registerBtn.userInteractionEnabled = true
                self.forgotPswBtn.userInteractionEnabled = true
                }, title:"请不要连接机器人网络登录", message: "")
            
            self.pswTxtField.becomeFirstResponder()
            self.userNameTxtField.becomeFirstResponder()

            return
        }
        
        registerBtn.userInteractionEnabled = true
        forgotPswBtn.userInteractionEnabled = true

        NSThread.detachNewThreadSelector(#selector(self.loginMethod), toTarget: self, withObject: nil)
        
    }
    
    //异步登录方法
    func loginMethod(){
        
  
        let tempDic = self.connect.didLogon(self.userNameTxtField.text, psw: self.pswTxtField.text!.md5) as! [String:AnyObject]
        
        self.loginM.robotCount = (tempDic as NSDictionary)["count"] as! Int
        
//        print("4444444loginMethod+++++++=   \(NSThread.currentThread())")
//        
//        //true 当前线程执行完毕继续执行,等待当前线程执行完以后，主线程才会执行aSelector方法
//        
//        print("555555555loginMethod+++++++=   \(NSThread.currentThread())")
//        
//        
//        print("00000loginMethod+++++++=   \(NSThread.currentThread())")
        
        //获取用户信息
        let tempArr = self.connect.didGetUserInfo(self.loginM.num, token:self.loginM.token)
        
        if 4 == tempArr.count
        {
            (self.registM.name,self.registM.isMale,self.registM.createTime,self.registM.birthday) = (tempArr[0] as! String,(tempArr[1] as! Int) == 0 ? true : false,tempArr[2] as! String,tempArr[3] as! String)
        }
        
//        self.performSelectorOnMainThread(#selector(self.goBackMainThread(_:)), withObject: tempDic, waitUntilDone: true)
        
        if 0 == tempDic.first!.1 as! Int || 1 == tempDic.first!.1 as! Int {
            
            if tempDic.first!.1 as? Int == 0{
                
                self.loginM.isAutoLogin = true
                
                (self.loginM.token,self.loginM.num) = (tempDic.dropFirst().first?.1 as? String ,self.userNameTxtField.text)
                KeychainWrapper.defaultKeychainWrapper().setString(
                    self.userNameTxtField.text!, forKey: "robosys_username")
                KeychainWrapper.defaultKeychainWrapper().setString(self.pswTxtField.text!, forKey: "robosys_password")
                //保证重新登录后 要重连
                networkModel.sharedInstance.isConnectRobot = false
                
                dispatch_async(dispatch_get_main_queue(), {
                    self.alert.dismiss()

                    self.navigationController?.pushViewController(MainViewController(), animated: true)
                })
                
                
            }else if 300 == tempDic.first!.1 as! Int{
                self.alert.dismiss()
                
                self.Alert({
                    [unowned self] in
                    self.userNameTxtField.text = ""
                    self.pswTxtField.text = ""
                    self.loginM.isAutoLogin = false
                    self.registerBtn.userInteractionEnabled = true
                    self.forgotPswBtn.userInteractionEnabled = true
                    self.pswTxtField.becomeFirstResponder()
                    self.userNameTxtField.becomeFirstResponder()
                    
                    }, title:"用户不存在", message: "")
                
            }else if 202 == tempDic.first!.1 as! Int{
                self.alert.dismiss()
                self.Alert({
                    [unowned self] in
                    self.pswTxtField.text = ""
                    self.loginM.isAutoLogin = false
                    self.registerBtn.userInteractionEnabled = true
                    self.forgotPswBtn.userInteractionEnabled = true
                    self.pswTxtField.becomeFirstResponder()
                    self.userNameTxtField.becomeFirstResponder()
                    
                    }, title:"密码错误", message: "")
                
            }else{
                
                self.alert.dismiss()
                
                self.Alert({
                    [unowned self] in
                    self.userNameTxtField.text = ""
                    self.pswTxtField.text = ""
                    self.loginM.isAutoLogin = false
                    
                    }, title:"登陆失败，请检查账号密码和网络", message: "")
            }
        }else{
            
            self.alert.dismiss()
            
            self.Alert({
                [unowned self] in
                self.userNameTxtField.text = ""
                self.pswTxtField.text = ""
                self.loginM.isAutoLogin = false
                
                }, title:"登陆失败，请检查账号密码和网络", message: "")
        }
    }
    
    ///点击快速注册
    @IBAction func regist(sender: UIButton)
    {
        self.pswTxtField.resignFirstResponder()
        self.userNameTxtField.resignFirstResponder()
        navigationController?.pushViewController(RegistViewController(nibName:"RegistView",bundle: nil), animated: true)
        self.resignFirstResponder()
    }
    ///点击忘记密码
    @IBAction func forgot(sender: UIButton)
    {
        navigationController?.pushViewController(ForgotPasswordViewController(nibName: "ForgotPasswordView",bundle:nil), animated: true)
    }
    
    ///上移
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        tempTextField = textField
        
        UIView.animateWithDuration(0.2)
        {
            self.view.frame.origin.y = -216.0
        }
        
        return true
    }
    ///下降
    func textFieldDidEndEditing(textField: UITextField)
    {
        guard tempTextField != textField else
        {
            UIView.animateWithDuration(0.2)
            {
                self.view.frame.origin.y = 0
            }
            return
        }
    }
    ///点击return
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        UIView.animateWithDuration(0.2)
        {
            self.view.frame.origin.y = 0
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        
    }
    deinit
    {
        const.hostReach.stopNotifier()
        print("\(classForCoder)--hello there")
    }
}
