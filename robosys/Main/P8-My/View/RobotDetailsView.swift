//
//  RobotDetailsView.swift
//  robosys
//
//  Created by Cheer on 16/5/27.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class RobotDetailsView: AppView,UIScrollViewDelegate
{
 
    @IBOutlet weak var scroll: UIScrollView!
    @IBOutlet weak var robotID: UILabel!
    @IBOutlet weak var breakBtn: UIButton!
    @IBOutlet weak var connectLabel: UILabel!
    
    @IBOutlet weak var genderTxtField: UITextField!
    @IBOutlet weak var starTxtField: UITextField!
    @IBOutlet weak var birthdayTxtField: UITextField!
    
    @IBOutlet weak var robotNameTxtFiled: UITextField!
    @IBOutlet weak var adminTxtField: UITextField!
    @IBOutlet weak var voiceTxtField: UITextField!
    @IBOutlet weak var wakeTxtField: UITextField!
    @IBOutlet weak var oralTxtField: UITextField!
    
    @IBOutlet weak var birthBgView: UIImageView!
    @IBOutlet weak var starBgView: UIImageView!
    @IBOutlet weak var genderBgView: UIImageView!
    @IBOutlet weak var adminBgView: UIImageView!
    @IBOutlet weak var wakeBgView: UIImageView!
    @IBOutlet weak var oralBgView: UIImageView!
    @IBOutlet weak var voiceBgView: UIImageView!

    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var clipImageView: UIImageView!

    @IBOutlet weak var userView: UIView!
    @IBOutlet weak var userScroll: UIScrollView!
    
    @IBOutlet weak var nameBtn: UIButton!
    @IBOutlet weak var voiceBtn: UIButton!
    @IBOutlet weak var oralBtn: UIButton!
    @IBOutlet weak var adminBtn: UIButton!
    
    
    
    internal var model:robotModel!
    
    private lazy var lastLabel = UILabel()
    private var lastTxtField:UITextField!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        userScroll.delegate = self
        scroll.delegate = self
        robotNameTxtFiled.delegate = self
        adminTxtField.delegate = self
        voiceTxtField.delegate = self
        wakeTxtField.delegate = self
        oralTxtField.delegate = self

        userScroll.indicatorStyle = .White
        
        initMainHeadView("详情页", imageName: "返回")
        
        addBorder(userView)
        
        if networkM.isConnectRobot
        {
            let dic = connect.didQueryUserList(loginM.num, token: loginM.token, robotId: loginM.robotId)
            
            if dic.count > 0
            {
                if let array = dic["array"] as? NSArray
                {
                    for i in 0..<array.count
                    {
                        let label = UILabel(frame: CGRectMake(0,CGFloat(i) * 35,userScroll.frame.width,30))
                        
                        if let str = array[i] as? String
                        {
                            label.attributedText = NSAttributedString(string:str ,attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 14)!])
                        }
                        
                        userScroll.addSubview(label)
                        
                        if i == array.count - 1
                        {
                            lastLabel = label
                        }
                    }
                }
            }
        }
        
        setUp()

//        clip([60,40,60,80,60])
    
    }
    
    func setUp()
    {
        robotID.text = loginM.robotId
        
        if let name = robotM.name
        {
            robotNameTxtFiled.attributedText = NSAttributedString(string:name, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont.systemFontOfSize(17)])
        }
        if let admin = robotM.admin
        {
            adminTxtField.attributedText = NSAttributedString(string:admin, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont.systemFontOfSize(17)])
        }
        
        if let gender = robotM.gender
        {
            genderTxtField.attributedText = NSAttributedString(string:gender, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont.systemFontOfSize(17)])
        }
        if let birth = robotM.birthday
        {
            birthdayTxtField.attributedText = NSAttributedString(string:birth, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont.systemFontOfSize(17)])
        }
        if let star = robotM.star
        {
            starTxtField.attributedText = NSAttributedString(string:star, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont.systemFontOfSize(17)])
        }
        
        if let wakeWord = robotM.wakeWord
        {
            wakeTxtField.attributedText = NSAttributedString(string:wakeWord, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont.systemFontOfSize(17)])
        }
        if let pet_phrase = robotM.pet_phrase
        {
            oralTxtField.attributedText = NSAttributedString(string:pet_phrase, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont.systemFontOfSize(17)])
        }
        if let voice = robotM.voice
        {
            voiceTxtField.attributedText = NSAttributedString(string:voice, attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont.systemFontOfSize(17)])
        }
        
        //有管理员且是我，就可以更改
        if let admin = robotM.admin where admin == registM.name
        {
            addBorder(robotNameTxtFiled)
            addBorder(oralBgView)
            addBorder(voiceBgView)
            
//            addBorder(adminBgView)
//            addBorder(genderBgView)
//            addBorder(starBgView)
//            addBorder(birthBgView)
//            addBorder(wakeBgView)

            
            robotNameTxtFiled.enabled = true
            oralTxtField.enabled = true
            voiceTxtField.enabled = true
        
        
            (oralBtn.hidden,voiceBtn.hidden,nameBtn.hidden,adminBtn.hidden) = (false,false,false,false)
            
//            adminTxtField.enabled = true
//            genderTxtField.enabled = true
//            starTxtField.enabled = true
//            birthdayTxtField.enabled = true
//            wakeTxtField.enabled = true
  
        }
        
        //在线的话，连接按钮就显示连接，已经连接的话，显示断开
        if let connect = robotM.connect where connect == true
        {
            let breakImg = UIImage(named: "断开")
            breakImg?.accessibilityIdentifier = "断开"
            breakBtn.setBackgroundImage(breakImg, forState: .Normal)
            
            connectLabel.hidden = !connect
        }else{
            connectLabel.hidden = true
        }
    }
    func textFieldDidBeginEditing(textField: UITextField)
    {
        textField.allowsEditingTextAttributes = true
        
    }
//    func textFieldDidEndEditing(textField: UITextField) {
    
//        var type = 0
//        let name = textField.text
//        
//        switch textField
//        {
//        case robotNameTxtFiled:type = 0
//        case adminTxtField:type = 1
//        case genderTxtField:
//            
//            type = 2
//            
//            if let content = textField.text where content.hasPrefix("男") || content.hasSuffix("男")
//            {
//                name = "1"
//            }
//            else
//            {
//                name = "2"
//            }
//        case starTxtField:
//        
//            type = 3
//            
//            switch name
//            {
//            case let temp where temp == "金牛座": name = "1"
//            case let temp where temp == "双子座": name = "2"
//            case let temp where temp == "巨蟹座": name = "3"
//            case let temp where temp == "狮子座": name = "4"
//            case let temp where temp == "室女座": name = "5"
//            case let temp where temp == "天秤座": name = "6"
//            case let temp where temp == "天蝎座": name = "7"
//            case let temp where temp == "人马座": name = "8"
//            case let temp where temp == "摩羯座": name = "9"
//            case let temp where temp == "宝瓶座": name = "10"
//            case let temp where temp == "双鱼座": name = "11"
//            default: name = "0"
//            }
//
//        case birthdayTxtField:type = 4
//        case oralTxtField:type = 5
//        case voiceTxtField:type = 6
//            
//        default:break
//        }
//        
//        guard textField.text?.characters.count > 0 else {return}
//        
//        control.didSetRobotAttr(Int32(type), name: name)
//    }
    
    @IBAction func saveAttribute(sender: UIButton)
    {
        // 0--机器人名字 1--管理员姓名 2--性别 3--星座 4--生日 5--口头禅 6--音色 7--语速 
        var type:Int!
        var textField:UITextField!
        
        switch sender.tag
        {
        case 1801:type = 0
            textField = robotNameTxtFiled
        case 1802:type = 1
            textField = adminTxtField
        case 1803:type = 5
            textField = oralTxtField
        default:break
        }
        
        guard textField.text?.characters.count > 0 else {return}
        
        let res = control.didSetRobotAttr(Int32(type), name: textField.text)
        
        Alert({}, title: res == 0 ? "保存成功" : "保存失败", message: "")
    }
    
    @IBAction func jump2Permission(sender: UIButton)
    {
        if let admin = robotM.admin where admin == registM.name
        {
            jump2AnyController(PermissionViewController(nibName: "PermissionView", bundle: nil))
        }
    }
    
    
    override func layoutSubviews()
    {
        scroll.contentSize = CGSizeMake(scroll.frame.width, userView.frame.origin.y + userView.frame.height)
        userScroll.contentSize = CGSizeMake(userScroll.frame.width, lastLabel.frame.origin.y + lastLabel.frame.height)
    }
    
    func clip(lengthArr:[CGFloat])
    {
        //从Bundle中读取图片
        let srcImg = UIImage(named: "3满状态")!
        let width = srcImg.size.width
        let height = srcImg.size.height
        
        //开始绘制图片
        UIGraphicsBeginImageContext(srcImg.size);
        let gc = UIGraphicsGetCurrentContext();
        
        //绘制Clip区域
        let origin = CGPointMake(99, 99)
        var length:CGFloat = lengthArr[0]
        var x = origin.x - length * CGFloat(sinf(Float(M_PI * 72 * 0 / 180)))
        var y = origin.y - length * CGFloat(cosf(Float(M_PI * 72 * 0 / 180)))
        CGContextMoveToPoint(gc!, x, y);
        
        length = lengthArr[0]
        x = origin.x - length * CGFloat(sin(M_PI * 72 * Double(1) / 180)) - 4
        y = origin.y - length * CGFloat(cos(M_PI * 72 * Double(1) / 180)) + 4
        CGContextAddLineToPoint(gc!, x, y);
        
        //第二条线
        length = lengthArr[1]
        x = origin.x - length * CGFloat(sin(M_PI * 72 * Double(1) / 180)) - 3
        y = origin.y - length * CGFloat(cos(M_PI * 72 * Double(1) / 180)) + 3
        CGContextAddLineToPoint(gc!, x, y);
        
        length = lengthArr[1]
        x = origin.x - length * CGFloat(sin(M_PI * 72 * Double(2) / 180)) - 4
        y = origin.y - length * CGFloat(cos(M_PI * 72 * Double(2) / 180)) + 4
        CGContextAddLineToPoint(gc!, x, y);
        
        //第三条线
        length = lengthArr[2]
        x = origin.x - length * CGFloat(sin(M_PI * 72 * Double(2) / 180)) - 3
        y = origin.y - length * CGFloat(cos(M_PI * 72 * Double(2) / 180)) + 3
        CGContextAddLineToPoint(gc!, x, y);
        
        length = lengthArr[2]
        x = origin.x - length * CGFloat(sin(M_PI * 72 * Double(3) / 180)) - 2
        y = origin.y - length * CGFloat(cos(M_PI * 72 * Double(3) / 180)) + 2
        CGContextAddLineToPoint(gc!, x, y);
        
        //第四条线
        length = lengthArr[3]
        x = origin.x - length * CGFloat(sin(M_PI * 72 * Double(3) / 180)) - 3
        y = origin.y - length * CGFloat(cos(M_PI * 72 * Double(3) / 180)) + 3
        CGContextAddLineToPoint(gc!, x, y);
        
        length = lengthArr[3]
        x = origin.x - length * CGFloat(sin(M_PI * 72 * Double(4) / 180)) - 4
        y = origin.y - length * CGFloat(cos(M_PI * 72 * Double(4) / 180)) + 4
        CGContextAddLineToPoint(gc!, x, y);
        
        length = lengthArr[4]
        x = origin.x - length * CGFloat(sin(M_PI * 72 * Double(4) / 180))
        y = origin.y - length * CGFloat(cos(M_PI * 72 * Double(4) / 180)) + 2
        CGContextAddLineToPoint(gc!, x, y);
        
        length = lengthArr[4]
        x = origin.x - length * CGFloat(sin(M_PI * 72 * Double(0) / 180))
        y = origin.y - length * CGFloat(cos(M_PI * 72 * Double(0) / 180)) + 2
        CGContextAddLineToPoint(gc!, x, y);
        
        CGContextClosePath(gc!);
        CGContextClip(gc!);
        
        //坐标系转换
        //因为CGContextDrawImage会使用Quartz内的以左下角为(0,0)的坐标系
        CGContextTranslateCTM(gc!, 0, height);
        CGContextScaleCTM(gc!, 1, -1);
        CGContextDrawImage(gc!, CGRectMake(0, 0, width, height), srcImg.CGImage!);
        
        //结束绘画
        let destImg = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        //创建UIImageView并显示在界面上
        clipImageView.image = destImg
        
    }
    
    @IBAction func breakConnect(sender: UIButton)
    {
        switch sender.currentBackgroundImage!.accessibilityIdentifier!
        {
        case "断开":
            //断开机器人
            robotM.connect = false
            networkModel.sharedInstance.isConnectRobot = false
            
            let connectImg = UIImage(named: "连接")
            connectImg?.accessibilityIdentifier = "连接"
            breakBtn.setBackgroundImage(connectImg, forState: .Normal)
            
            connectLabel.hidden = true
            
        case "连接":
            
            let code =
                {
                    [weak self] in
                    
                    let loginM = loginModel.sharedInstance
                    let ret = RobotConnect.shareInstance().didConnRobot(loginM.token, userName: loginM.num, robotId: loginM.robotId)
                    
                    if let status = ret.firstObject as? Int where 0 == status
                    {
                        self!.robotM.connect = true
                        networkModel.sharedInstance.isConnectRobot = true
                        
                        let connectImg = UIImage(named: "断开")
                        connectImg?.accessibilityIdentifier = "断开"
                        self!.breakBtn.setBackgroundImage(connectImg, forState: .Normal)
                        
                        self!.connectLabel.hidden = false
                        self!.Alert({}, title: "连接成功", message: "")
                        
                        return
                    }
                    
                    self!.Alert({}, title: "连接失败", message: "")
            }
            
            Alert(code, title: "正在连接", message: "")
        default:
            break
        }        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        robotNameTxtFiled.resignFirstResponder()
        adminTxtField.resignFirstResponder()
        genderTxtField.resignFirstResponder()
        starTxtField.resignFirstResponder()
        birthdayTxtField.resignFirstResponder()
        oralTxtField.resignFirstResponder()
        wakeTxtField.resignFirstResponder()
        voiceTxtField.resignFirstResponder()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
