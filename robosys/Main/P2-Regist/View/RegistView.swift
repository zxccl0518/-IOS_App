//
//  RegistView.swift
//  robosys
//
//  Created by Cheer on 16/5/23.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class RegistView : registAndForgotView
{
    @IBOutlet weak var chooseBtn: UIButton!
    @IBOutlet weak var registBtn: UIButton!
    @IBOutlet weak var userNameTxtField: UITextField!
    @IBOutlet weak var captchaTxtField: UITextField!
    @IBOutlet weak var pswTxtField: UITextField!
    @IBOutlet weak var ensurePswTxtField: UITextField!
    @IBOutlet weak var captchaBtn: UIButton!

    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        setUp()
    }
    
    func setUp()
    {
        chooseBtn.setBackgroundImage(UIImage(named: "选择框"), forState: .Normal)
        chooseBtn.setBackgroundImage(UIImage(named: "选择框2"), forState: .Selected)
        
        
        initHeadView("注册", imageName: "返回")
        
        initTxtField(userNameTxtField,string: "用户名",type: "text")
        initTxtField(captchaTxtField,string: "验证码",type: "text")
        initTxtField(pswTxtField,string: " 密 码",type: "text")
        initTxtField(ensurePswTxtField,string: "确认密码",type: "text")
        
        userNameTxtField.delegate = self
        captchaTxtField.delegate = self
        pswTxtField.delegate = self
        ensurePswTxtField.delegate = self
    }
    
    //-MARK:点击方法
    ///点击协议
    @IBAction func showProtocol(sender: UIButton)
    {
        jump2AnyController(ProtocolViewController())
    }
    ///获取验证码
    @IBAction func getCaptcha(sender: AnyObject)
    {
        guard networkM.state == true else
        {
            Alert({}, title: "手机网络连接不可用", message: "")
            return
        }
        
        isClickCaptcha = true
        
        if userNameTxtField.text!.isEmpty
        {
            Alert({}, title:"请输入手机号", message: "")
        }
        else if !userNameTxtField.text!.checkMatch(const.telPatten)
        {
            Alert({}, title:"手机号格式不正确，请输入11位数字", message: "")
        }
        else
        {
            phoneNum = userNameTxtField.text!
            
            dispatch_async(dispatch_get_global_queue(0, 0), { 
                let res = self.connect.didGetVerifyCode(self.userNameTxtField.text, type: 0)
 
                   dispatch_async(dispatch_get_main_queue(), {
                       res == 0 ? self.getCap(self.captchaBtn) : self.Alert({}, title: "发送失败，请重试", message: "")
                   })
            })
        }
    }
    ///点击注册
    @IBAction func regist(sender: UIButton)
    {
        guard networkM.state == true else
        {
            Alert({}, title: "手机网络连接不可用", message: "")
            return
        }
        guard userNameTxtField.text!.checkMatch(const.telPatten) else
        {
            Alert({}, title:"手机号格式不正确，请输入11位数字", message: "")
            return
        }
        guard pswTxtField.text!.checkMatch(const.pswPatten) && pswTxtField.text == ensurePswTxtField.text else
        {
            Alert({
                [unowned self] in
                self.ensurePswTxtField.text = ""
                self.pswTxtField.text = ""
                }, title:"密码不正确,请检查", message: "")
            return
        }
        guard isClickCaptcha == true else
        {
            captchaTxtField.text = ""
            Alert({
                }, title:"请获取正确的验证码", message: "")
            return
        }
        
        let status = connect.didRegister(userNameTxtField.text, psw: pswTxtField.text!.md5, verifyCode: captchaTxtField.text)
//         let status = connect.didRegister("13478639583", psw: "13478639583", verifyCode: "1234")
        if 0 == status
        {
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "yyyy年MM月dd日 HH:mm"
            registM.createTime = dateFormatter.stringFromDate(NSDate())
            
            Alert({
                [unowned self] in
 
                self.jump2AnyController(SettingViewController(nibName:"SettingView",bundle:nil))
                
                }, title:"恭喜您，注册成功！还差一步哦..", message: "")
        }
        else if 200 == status
        {
            Alert({}, title: "用户已存在", message: "")
        }
        else if 402 == status
        {
            Alert({}, title: "验证码错误", message: "")
        }
        else
        {
            Alert({}, title:"注册失败，请重试", message: "")
        }
        
        isClickCaptcha = false
    }
    ///点击勾选按钮
    @IBAction func changeImg(sender: UIButton)
    {
        sender.selected = !sender.selected
        JudgeEnabled()
    }
    ///UITextField状态
    @IBAction func TxtFieldStatus(sender: UITextField)
    {
        switch sender
        {
        case captchaTxtField,userNameTxtField: sender.keyboardType = .NumberPad
        case ensurePswTxtField,pswTxtField: sender.keyboardType = .Default
        default:break
        }
        JudgeEnabled()
    }
    func JudgeEnabled()
    {
        registBtn.enabled = !userNameTxtField.text!.isEmpty && !captchaTxtField.text!.isEmpty && !pswTxtField.text!.isEmpty && !ensurePswTxtField.text!.isEmpty && !chooseBtn.selected ? true : false
    }
    deinit
    {
        print("\(classForCoder)--hello there")
    }

}
