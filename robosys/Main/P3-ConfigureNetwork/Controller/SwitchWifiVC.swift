
//  SwitchWifiVC.swift
//  robosys
//
//  Created by max.liu on 2017/5/9.
//  Copyright © 2017年 joekoe. All rights reserved.
//  切换网络界面 展示wifi列表

import UIKit
import YYModel
import SVProgressHUD


private let SwithWifiVCID = "SwithWifiVC"
private let otherID = "otherID"

class SwitchWifiVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    private var alert:AppAlertView!
    private var aler : AppAlert!
    private var status: Int!
    
    //正在连接中 ...
    func displayMessage() {
        
        let v = UINib(nibName: "AppAlertView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AppAlertView
        v.titleLabel.hidden = true
        v.subTitleLabel.hidden = true
        v.contentLabel.textAlignment = .Center
        v.backBtn.hidden = true
        v.contentLabel.text = "正在连接中..."
        v.frame = CGRectMake(0, 0, 300, 240)
        
        aler = AppAlert(frame: UIScreen.mainScreen().bounds, view: v, currentView: self.view, autoHidden: false)
    }
    
    
    lazy var robotM = robotModel.sharedInstance
    lazy var networkM = networkModel.sharedInstance
    
    //机器人连接
    lazy var connect = RobotConnect.shareInstance()
    lazy var control = RobotControl.shareInstance()
    
    lazy var loginM = loginModel.sharedInstance
    
    //wifi界面数据
    var CellWifi : [String : AnyObject]?{
        didSet{
            self.tableV.reloadData()
        }
    }
    
    
    //转换成功的模型
    var CellData: WifiModel?{
        
        didSet{
            
                if let sn = CellData?.SN {
                    
                    num_Label.text = "设备号 : \(sn) "
                }
                
                
                if let wifiLabel = CellData?.ESSID {
                    
                    connectView.wifiLabel.text = wifiLabel
                }
            }
    }
    
    
    //当前连接的view
    private lazy var connectView : ConnectView = {
       let cV = ConnectView()
        cV.hidden = true
        return cV
    }()
    
    //设备号 展示
    private lazy var num_Label : UILabel = {
        let lab = UILabel()
        
        lab.textColor = UIColor.whiteColor()
        
        return lab
        
    }()
    
    private lazy var topImageV : UIView = {
        
         let  headView = AppHeadView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,150))
        self.view.addSubview(headView)
        
        headView.titleLabel.text = "切换网络"
        headView.leftBtn.setImage(UIImage(named: "返回"), forState: .Normal)
        
        return headView
    }()

    private lazy var imageV : UIImageView = {
        
        let imgV = UIImageView()
        imgV.image = UIImage(named: "首页-背景")
        return imgV
    }()
    
    //存放 tableV
    private lazy var tableV : UITableView = {
       
        let tableV = UITableView(frame: CGRectZero, style: UITableViewStyle.Grouped)
        tableV.bounces = false
        tableV.scrollEnabled = true
        tableV.showsVerticalScrollIndicator = false
        tableV.separatorStyle = .None
        tableV.backgroundColor = UIColor.clearColor()
        
        
        return tableV
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData()
        setupUI()
    }
    
    
    func loadData() {

        /// 过滤5Gwifi --Alan.li
        guard let cellWifi = CellWifi else { return }
        
        guard let wifiModelDic = WifiModel.yy_modelWithJSON(cellWifi) else { return }
        
        let cellsWithout5G = wifiModelDic.Cells?.filter({ (cell) -> Bool in
            
            guard let frequency = cell.Frequency else { return false }
            let value = (frequency as NSString).substringToIndex(4)
            
            guard let doubleValue = Double(value) else { return false }
            return doubleValue < 4.99
        })
        
        wifiModelDic.Cells = cellsWithout5G
        self.CellData = wifiModelDic
    }
    
    
    func setupUI() {
        
        view.backgroundColor = UIColor.clearColor()
        
        tableV.delegate = self
        tableV.dataSource = self
        
        tableV.registerClass(SwitchTableViewCell.self, forCellReuseIdentifier: SwithWifiVCID)
        tableV.registerClass(UITableViewCell.self, forCellReuseIdentifier: otherID)
        
        view.addSubview(imageV)
        view.addSubview(topImageV)
        view.addSubview(tableV)
        view.addSubview(num_Label)
        view.addSubview(connectView)
        
        //头部视图
        topImageV.snp_makeConstraints { (make) in
            
            make.left.top.right.equalTo(self.view)
            make.height.equalTo(150)
        }
        //背景图片
        imageV.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        
        //当前连接的小盒
        num_Label.snp_makeConstraints { (make) in
            
            make.top.equalTo(topImageV.snp_bottom).offset(50)
            make.right.equalTo(self.view)
            make.left.equalTo(self.view).offset(20)
            make.height.equalTo(20)
        }
  
        let (success,ssid,bssid) = self.view.getSSID()
        
        if success && ssid.hasPrefix("MrBox") && bssid != "" && ssid.characters.count == 18{
            connectView.hidden = true
            
            tableV.snp_makeConstraints(closure: { (make) in
                make.left.right.bottom.equalTo(self.view)
                make.top.equalTo(num_Label.snp_bottom)
            })
        }else{
            
            connectView.hidden = false
            
            connectView.snp_makeConstraints { (make) in
                
                make.left.right.equalTo(self.view)
                make.top.equalTo(num_Label.snp_bottom).offset(10)
                make.height.equalTo(50)
            }
            
            //tableView
            tableV.snp_makeConstraints { (make) in
                
                make.left.right.bottom.equalTo(self.view)
                make.top.equalTo(connectView.snp_bottom)
            }
        }
    }
    
    
    //-MARK:代理方法
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 3;
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
//            print(self.CellData?.Cells?.count)
            return (self.CellData?.Cells!.count)!
            
        }else{
            return 1
        }
    }
    

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
            if indexPath.section == 0 {
                
                let cell = tableView.dequeueReusableCellWithIdentifier(SwithWifiVCID, forIndexPath: indexPath) as! SwitchTableViewCell
                cell.backgroundView = UIImageView(image: UIImage(named: "Configure Network-Middle-Background-"))
                cell.backgroundColor = UIColor.clearColor()
                cell.cellD = self.CellData?.Cells![indexPath.row]
                return cell
                
            }else if indexPath.section == 1{
                
                 let cell = tableView.dequeueReusableCellWithIdentifier(otherID, forIndexPath: indexPath)
                cell.backgroundColor = UIColor.clearColor()
                cell.backgroundView = UIImageView(image: UIImage(named: "Configure Network-Middle-Background1-"))
                
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.textLabel?.textColor = UIColor.whiteColor()
                cell.textLabel!.text = "给其他机器人配置网络"
                return cell
            }else{
                
                let cell = tableView.dequeueReusableCellWithIdentifier(otherID, forIndexPath: indexPath)
                cell.backgroundView = UIImageView(image: UIImage(named: "Configure Network-Middle-Background1-"))
                cell.backgroundColor = UIColor.clearColor()
                cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
                cell.textLabel?.textColor = UIColor.whiteColor()

                cell.textLabel!.text = "还原网络设置"
                return cell
        }
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
            let v = UIView()
            v.frame = CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, 5)
        
            let lab = UILabel()
        
            lab.text = "请选择需要连接的网络"
            lab.textColor = UIColor.whiteColor()
            lab.sizeToFit()
            v.addSubview(lab)
        
        lab.snp_makeConstraints { (make) in
            
            make.left.equalTo(v.snp_left).offset(10)
            make.centerY.equalTo(v)
            
        }
        
        
        if section == 0 {
            return v
            
        }else{
            return nil
        }
    }
    
    func bindMethodSwitch(){
        
        //查询绑定的用户
        let retDic = self.connect.didQueryUserList(self.loginM.num, token: self.loginM.token, robotId: self.loginM.robotId) as NSDictionary
        
        robotModel.sharedInstance.online = true
        
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
            self.Alert({

                self.aler.dismiss()
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
        
        //有管理员
        if isHaveAdminBool
        {
            //无我
            if !isHaveMeBool
            {
                //绑定0
                let bindingCode = self.connect.didBind(self.loginM.num, token: self.loginM.token, robotId: self.loginM.robotId, admin: 0)

                if bindingCode == 0{
                    
                    makePair()
                }else{
                    
                    self.Alert({[unowned self] in
                        self.aler.dismiss()
                        
                        self.navigationController?.pushViewController(MainViewController(), animated: true)
                        }, title: "绑定失败", message: "")
                }
            }else{
                print("\(NSThread.currentThread())")
                makePair()
            }
        }else{
            
            dispatch_async(dispatch_get_main_queue(), {
                self.aler.dismiss()
                
                let vc = BindViewController(nibName: "BindView",bundle: nil)
                (vc.view as! BindView).isBind = isHaveMeBool
                self.navigationController?.pushViewController(vc, animated: true)
            })
        }
    }
    
    //查询在线机器人
    func transimit(v:AppAlertView){
        
        let robotManager = RobotManager.shareManager
        v.contentLabel.text = "正在连接在线机器人..."
        
        robotManager.robotOnlineState(nil, netFinished: { (resArry) in
            
            //不在线就进首页
            if resArry.firstObject as! Int == -1
            {
                self.aler.dismiss()
                self.Alert({
                    
                    let vc = ScanRobotViewController(nibName:"ScanRobotView",bundle: nil)
                    
                        self.navigationController?.pushViewController(vc, animated: true)
                        networkModel.sharedInstance.isConnectRobot = false
                        robotModel.sharedInstance.connect = false
                    }, title: "机器人不在线,请为机器人配置网络", message: "")
                
                //不在线就重新配置
            }
            else if resArry.firstObject as! Int == 301 || resArry.firstObject as! Int == 302
            {
                self.aler.dismiss()
                
                self.Alert({
                    [unowned self] in
                    
                    self.navigationController?.popToRootViewControllerAnimated(false)
                    }, title: "用户登录过期请重新登录", message: "")
                
            }
            else if resArry.firstObject as! Int == 0
            {
                print("\(NSThread.currentThread())")
                //如果ip地址不为空
                if resArry[1].length! != 0
                {
                    NSThread.detachNewThreadSelector(#selector(self.bindMethodSwitch), toTarget: self, withObject: nil)
                    
                }
                    //不在线
                else
                {
                    self.aler.dismiss()
                    
                    self.warningView()
                    
                }
                
            }
            else {
                
                self.aler.dismiss()
                    self.navigationController?.pushViewController(MainViewController(), animated: true)
            }
            
        })

    }
    
    
    //配对
    func makePair(){
        
            robotModel.sharedInstance.online = true
            
            for _ in 0..<6 {
                
                self.status = self.connect.didConnRobot(self.loginM.token, userName: self.loginM.num, robotId: self.loginM.robotId).firstObject as! Int
                
                if self.status == 0 {
                    break
                }
            }
        
            switch self.status
            {
                case 301,302:
                    self.aler.dismiss()
                    self.Alert({
                        
                        self.navigationController?.popToRootViewControllerAnimated(false)

                        }, title: "用户登录过期请重新登录", message: "")
                    break

                case 0:
                    
                    self.aler.dismiss()
                    
                    self.Alert({
                        networkModel.sharedInstance.isConnectRobot = true
                        robotModel.sharedInstance.connect = true
                            
                        RobotManager.shareManager.getRobotInfo()
                        self.navigationController?.pushViewController(MainViewController(), animated: true)
                            
                        }, title: "配对成功", message: "")
                    break

                //超时
                case -1:
                    self.aler.dismiss()
                        self.Alert({
                            robotModel.sharedInstance.connect = false
                            networkModel.sharedInstance.isConnectRobot = false
                            print("\(NSThread.currentThread())")
                            self.navigationController?.pushViewController(MainViewController(), animated: true)
                        }, title: "配对失败,请手动扫描在线小盒", message: "")
                    break
                    
                default:
                
                    self.dismissViewControllerAnimated(true, completion: { [unowned self] in
                        self.Alert({}, title: "\(self.status)", message: "")
                    })
            }
    }
    
    //警示框
    func warningView(){
        let alertV = UINib(nibName: "AppAlertView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AppAlertView
        
        alertV.titleLabel.text = "连接失败"
        alertV.subTitleLabel.text = "请检查是否由于以下问题导致连接失败"
        alertV.subTitleLabel.numberOfLines = 0
        
        
        alertV.titleLabel.textAlignment = .Center
        alertV.contentLabel.numberOfLines = 0
        alertV.contentLabel.text = "1.WiFi密码错啦 \n 2.WiFi的信号太弱啦 \n 3.手机离机器太远啦"
        alertV.contentLabel.numberOfLines = 0
        alertV.frame = CGRectMake(0, 0, 300, 300)
        
        let btn = UIButton()
        btn.sizeToFit()
        
        btn.setTitle("重新配置", forState: .Normal)
        btn.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        btn.setBackgroundImage((UIImage(named: "圆角矩形-1")), forState: .Normal)
        btn.addTarget(self, action: #selector(self.resetConfig), forControlEvents: .TouchUpInside)
        
        alertV.backBtn = btn
        
        self.aler = AppAlert(frame: UIScreen.mainScreen().bounds, view: alertV, currentView: self.view, autoHidden: false)
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if indexPath.section == 0 {
            
            
            //判断是否连接过  是否有锁  调用接口 发送给小盒去连接
            let cellModel : CellWifiModel = (CellData?.Cells![indexPath.row])!
            
            if cellModel.ESSID == CellData?.ESSID {
                tableView.cellForRowAtIndexPath(indexPath)?.selected = false
                return
            }
            
            //如果 已经连接过 没有wifi密码
            if (cellModel.Registered! == 1) || ((cellModel.Encryption?.characters.count)! == 3){

                tableView.cellForRowAtIndexPath(indexPath)?.selected = false
                //正在 超时处理

                let v = UINib(nibName: "AppAlertView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AppAlertView
                v.titleLabel.hidden = true
                v.subTitleLabel.hidden = true
                v.contentLabel.textAlignment = .Center
                v.backBtn.hidden = true
                v.contentLabel.text = "正在向机器人发送WiFi账号和密码..."
                v.frame = CGRectMake(0, 0, 300, 240)
                
                aler = AppAlert(frame: UIScreen.mainScreen().bounds, view: v, currentView: self.view, autoHidden: false)
                
                
                //连接过 有密码
                if (cellModel.Registered! == 1 && (cellModel.Encryption?.characters.count)! != 3){
                    
                    dispatch_async(dispatch_get_global_queue(0, 0), { 
                        self.control.didSetSpecifiedSSID(cellModel.ESSID, passWord: cellModel.Password)
                    })
                }else{
                    dispatch_async(dispatch_get_global_queue(0, 0), { 
                        self.control.didSetSpecifiedSSID(cellModel.ESSID, passWord: "")
                        
                    })
                }
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {[unowned self] in
                    
                    print("\(loginModel.sharedInstance.robotId)")
                    self.transimit(v)
                })
                
            }else{
                
            print("第一次连接")
                
            let inputVC = InputPasswordViewController()
 
            inputVC.inPutName.text = cellModel.ESSID
            inputVC.inPutPassWord.text = cellModel.Password
                
            self.navigationController?.pushViewController(inputVC, animated: false)
            
                inputVC.callBack = {[unowned self](ssidName,passwordName) -> Void in
                
                //正在连接... 超时处理
                let v = UINib(nibName: "AppAlertView", bundle: nil).instantiateWithOwner(nil, options: nil)[0] as! AppAlertView
                v.titleLabel.hidden = true
                v.subTitleLabel.hidden = true
                v.contentLabel.textAlignment = .Center
                v.backBtn.hidden = true
                v.contentLabel.text = "正在向机器人发送WiFi账号和密码..."
                v.frame = CGRectMake(0, 0, 300, 240)
                
                self.aler = AppAlert(frame: UIScreen.mainScreen().bounds, view: v, currentView: self.view, autoHidden: false)

                    dispatch_async(dispatch_get_global_queue(0, 0), { 
                        
                        self.control.didSetSpecifiedSSID(ssidName, passWord: passwordName)
                    })
                    
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(10 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                    
                        self.transimit(v)
                })
            }
        }
//
        }else if indexPath.section == 1{
            //给其他机器人配置网络
            self.navigationController?.pushViewController(ScanRobotViewController(nibName:"ScanRobotView",bundle: nil), animated: true)
            
        }else{
            
            //还原网络设置
            let alertV = UIAlertController(title: "提示", message: "删除机器人上所有网络设置,并恢复到默认的出厂设置", preferredStyle: .Alert)
            
            let okAlertAction = UIAlertAction(title: "确定", style: .Default, handler: { (ACTION) in
                self.control.reSetWifiConfig()
                
                //显示连接  是否在线
                robotModel.sharedInstance.connect = false
                robotModel.sharedInstance.online = false
                RobotManager.shareManager.getRobotInfo()
                networkModel.sharedInstance.isConnectRobot = false
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(0.01 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
                {
                    
                    self.navigationController?.pushViewController(MainViewController(), animated: true)
                }
            })
            let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: { (ACTION) in
                return
            })
            
            alertV.addAction(okAlertAction)
            alertV.addAction(cancelAction)
            
            self.presentViewController(alertV, animated: true, completion: nil)
            
        }
    }
    
    
    func resetConfig(){
        
        aler.dismiss()
        
        //重新获取与机器人的连接状态,并刷新wifi列表
        //拿到WIFI的SSID
        if !Platform.isSimulator
        {
            let (success,ssid,bssid) = self.view.getSSID()
            
            guard (success && ssid.hasPrefix("MrBox") && bssid != "" && ssid.characters.count == 18) || (networkM.isConnectRobot && robotM.online!) else
            {
                
                //提示用户去连接机器人
                print("提示用户连接机器人热点")
                let vc = ScanRobotViewController(nibName:"ScanRobotView",bundle: nil)
                (vc.view as! ScanRobotView).isWifi = true
                self.navigationController?.pushViewController(vc, animated: true)
                return
            }
            
        }

    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    deinit {
        CellWifi = nil
        self.tableV.delegate = nil
        CellData = nil
    }
    
}




