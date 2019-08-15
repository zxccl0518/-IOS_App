//
//  ChangePasswordView.swift
//  robosys
//
//  Created by Cheer on 16/5/30.
//  Copyright © 2016年 joekoe. All rights reserved.
//
import UIKit

class ChangePasswordView: registAndForgotView
{
    @IBOutlet weak var chooseBtn: UIButton!
    @IBOutlet weak var captChaBtn: UIButton!
    @IBOutlet weak var ensureBtn: UIButton!
    
    @IBOutlet weak var ensurePswTxtField: UITextField!
    @IBOutlet weak var pswTxtField: UITextField!
    @IBOutlet weak var captchaTxtField: UITextField!
    
    private lazy var code  = {}
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        initMainHeadView("更改密码", imageName: "返回")
        
        chooseBtn.setBackgroundImage(UIImage(named: "选择框"), forState: .Normal)
        chooseBtn.setBackgroundImage(UIImage(named: "选择框2"), forState: .Selected)

        initTxtField(captchaTxtField,string: "验证码",type: "text")
        initTxtField(pswTxtField,string: " 新密码",type: "text")
        initTxtField(ensurePswTxtField,string: "确认密码",type: "text")
    }
    @IBAction func TxtFieldStatus(sender: UITextField)
    {
        switch sender
        {
        case captchaTxtField: sender.keyboardType = .NumberPad
        case pswTxtField: sender.keyboardType = .Default
        case ensurePswTxtField: sender.keyboardType = .Default
        default:break
        }
        
        ensureBtn.enabled =  !captchaTxtField.text!.isEmpty && !pswTxtField.text!.isEmpty && !ensurePswTxtField.text!.isEmpty ? true : false
    }
    @IBAction func getCaptcha(sender: UIButton)
    {
        isClickCaptcha = true
        
        guard networkM.state == true else
        {
            Alert({}, title:"手机网络连接不可用", message: "")
            return
        }
        phoneNum = loginM.num
        
        0 == connect.didGetVerifyCode(loginM.num, type: 1) ? getCap(sender) : Alert({}, title: "发送失败，请重试", message: "")

    }
    @IBAction func changeImg(sender: UIButton)
    {
        sender.selected = !sender.selected
        ensurePswTxtField.secureTextEntry = sender.selected
        pswTxtField.secureTextEntry = sender.selected
    }
    @IBAction func clickEnsure(sender: UIButton)
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
            Alert(code, title:"密码格式错误，请设置为6~32位字母数字组合", message: "")
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
            let status = connect.didResetPass(ensurePswTxtField.text!.md5, userName:loginM.num, verifyCode: captchaTxtField.text)
            
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
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        ensurePswTxtField.resignFirstResponder()
        pswTxtField.resignFirstResponder()
        captchaTxtField.resignFirstResponder()
    }
}
