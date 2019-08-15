//
//  ForgotPasswordView.swift
//  robosys
//
//  Created by Cheer on 16/5/23.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class ForgotPasswordView: registAndForgotView
{
    //-MARK:属性
    @IBOutlet weak var userNameTxtField: UITextField!
    @IBOutlet weak var captchaTxtField: UITextField!
    @IBOutlet weak var enterBtn: UIButton!
    @IBOutlet weak var captchaBtn: UIButton!
    @IBOutlet weak var ensurePswTxtField: UITextField!
    @IBOutlet weak var pswTxtField: UITextField!

    private lazy var code = {}
    
    //-MARK:生命周期
    override func awakeFromNib()
    {
        super.awakeFromNib()

        setUp()
    }
    
    //-MARK:初始化
    func setUp()
    {
        initHeadView("找回密码", imageName: "返回")
        
        initTxtField(userNameTxtField,string: "用户名",type: "text")
        initTxtField(captchaTxtField,string: "验证码",type: "text")
        initTxtField(pswTxtField,string: "密码",type: "text")
        initTxtField(ensurePswTxtField,string: "确认密码",type: "text")

        userNameTxtField.delegate = self
        captchaTxtField.delegate = self
        ensurePswTxtField.delegate = self
        pswTxtField.delegate = self
    }
    //-MARK:点击方法
    ///获取验证码
    @IBAction func getCaptcha(sender: AnyObject)
    {
        isClickCaptcha = true 
        
        guard networkM.state == true else
        {
            Alert({}, title:"手机网络连接不可用", message: "")
            return
        }
        
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
    ///UITextField状态
    @IBAction func TxtFieldStatus(sender: UITextField)
    {
        switch sender
        {
        case captchaTxtField,userNameTxtField: sender.keyboardType = .NumberPad
        default:break
        }
        enterBtn.enabled = !userNameTxtField.text!.isEmpty && !captchaTxtField.text!.isEmpty && !pswTxtField.text!.isEmpty && !ensurePswTxtField.text!.isEmpty ? true : false
    }
    @IBAction func Commit(sender: UIButton)
    {
        code =
            {
                [unowned self] in
                self.ensurePswTxtField.text = ""
                self.pswTxtField.text = ""
        }
        guard networkM.state == true else
        {
            Alert({}, title:"手机网络连接不可用", message: "")
            return
        }
        guard isClickCaptcha == true else
        {
            captchaTxtField.text = ""
            Alert({
                }, title:"请获取正确的验证码", message: "")
            return
        }
        if !pswTxtField.text!.checkMatch(const.pswPatten)
        {
            Alert(code, title:"密码格式错误，请设置为6-16任意组合", message: "")
        }
        else if pswTxtField.text != ensurePswTxtField.text
        {
            Alert(code, title:"两次密码输入不一致，请重新输入", message: "")
        }
        else
        {
            code =
            {
                    [unowned self] in
                    (self.getCurrentVC() as! UINavigationController).popToRootViewControllerAnimated(true)
            }
            //此处服务器更新密码？
            
            let status = connect.didResetPass(ensurePswTxtField.text!.md5, userName:userNameTxtField.text, verifyCode: captchaTxtField.text)
            if 0 == status
            {
                KeychainWrapper.defaultKeychainWrapper().setString(pswTxtField.text!, forKey: "robosys_password")
                
                Alert(code, title:"密码更新成功，请登录", message: "")
            }
            else if 300 == status
            {
                Alert(code, title:"用户不存在", message: "")
            }
            else if 402 == status
            {
                Alert(code, title:"验证码错误", message: "")
            }
            else
            {
                Alert({}, title:"更新失败,请检查重试", message: "")
            }
        }
    }
    deinit
    {
        print("\(classForCoder)--hello there")
    }
}
