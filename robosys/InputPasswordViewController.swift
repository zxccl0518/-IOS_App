//
//  InputPasswordViewController.swift
//  robosys
//
//  Created by max.liu on 2017/5/15.
//  Copyright © 2017年 joekoe. All rights reserved.
//  如果点击的是正在连接的wifi  跳转到详情界面  如果用户进行了修改 那么重新发送指令给机器人   否则 可以交互

import UIKit

class InputPasswordViewController: UIViewController,UITextFieldDelegate {
    
    //定义了闭包
    var callBack:((String?,String?)->())?
    
    private lazy var imageV : UIImageView = UIImageView(image: UIImage(named: "首页-背景"))
    
    private lazy var topImageV : UIView = {
        
        let  headView = AppHeadView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,150))
        self.view.addSubview(headView)
        
        headView.titleLabel.text = "切换网络"
//        headView.titleLabel.font = UIFont(name: "RTWS yueGothic Trial", size: 17)
        
        headView.leftBtn.setImage(UIImage(named: "返回"), forState: .Normal)
        
        return headView
    }()
    
    
     lazy var inPutName : UITextField = {
       
        let inName = UITextField()
        inName.tintColor = UIColor.whiteColor()
        inName.backgroundColor = UIColor.init(red: 149/255.0, green: 149/255.0, blue: 149/255.0, alpha: 1)
        inName.addTarget(self, action: #selector(self.textFieldChanged(_:)), forControlEvents: .EditingChanged)
        inName.placeholder = "请输入wifi名称"
        inName.rightViewMode = .WhileEditing
        inName.borderStyle = UITextBorderStyle.RoundedRect
        inName.text = ""
        inName.backgroundColor = UIColor.clearColor()
        inName.textColor = UIColor.whiteColor()
        inName.background = UIImage(named: "输入框")
        inName.layer.borderColor = UIColor(red: 30/255, green: 144/255, blue: 1, alpha: 1).CGColor//	30	144	255
        inName.layer.borderWidth = 1.0
        inName.layer.cornerRadius = 5.0

        return inName
    }()
    
    
    
     lazy var inPutPassWord : UITextField = {
        
        let inName = UITextField()
        inName.tintColor = UIColor.whiteColor()
        inName.backgroundColor = UIColor.init(red: 149/255.0, green: 149/255.0, blue: 149/255.0, alpha: 1)
        inName.placeholder = "请输入密码"
        inName.textColor = UIColor.whiteColor()
        inName.rightViewMode = .WhileEditing
        inName.addTarget(self, action: #selector(self.textFieldChanged(_:)), forControlEvents: .EditingChanged)
        inName.addTarget(self, action: #selector(self.textFieldBegin(_:)), forControlEvents: .EditingDidBegin)
         inName.borderStyle = UITextBorderStyle.RoundedRect
        inName.backgroundColor = UIColor.clearColor()
        inName.background = UIImage(named: "输入框")
        inName.layer.borderColor = UIColor(red: 30/255, green: 144/255, blue: 1, alpha: 1).CGColor//	30	144	255
        inName.layer.borderWidth = 1.0
        inName.layer.cornerRadius = 5.0

        return inName
    }()
    
    private lazy var ensureBtn : UIButton = {
       
        let btn = UIButton()
        btn.setTitle("确认", forState: UIControlState.Normal)
        btn.setBackgroundImage(UIImage(named:"圆角矩形-1"), forState: UIControlState.Normal)
        btn.addTarget(self, action: #selector(self.ensureBtnClick), forControlEvents: UIControlEvents.TouchUpInside)
        btn.enabled = false
        btn.sizeToFit()
        return btn
    }()
    
    func textFieldBegin(textField:UITextField){
        if textField.text?.characters.count >= 8 {
            ensureBtn.enabled = true
        }else{
            ensureBtn.enabled = false
        }
    }
    
    func textFieldChanged(textField:UITextField){
        
        if textField == self.inPutPassWord {
            
            if textField.text?.characters.count >= 8 && textField.text?.characters.count <= 64{
                textField.text = self.inPutPassWord.text
                ensureBtn.enabled = true
            }else{
                ensureBtn.enabled = false
            }
        }else{
            
            if textField.text?.isEmpty == true {
                ensureBtn.enabled = false
            }else{
                ensureBtn.enabled = true
            }
        }
    }
    
    
    
    func ensureBtnClick() {
        
        inPutName.resignFirstResponder()
        inPutPassWord.resignFirstResponder()
        callBack?(inPutName.text,inPutPassWord.text)
        self.navigationController?.popViewControllerAnimated(false)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    
    
    func setupUI() {
        
        inPutName.delegate = self
        inPutPassWord.delegate = self
        view.addSubview(imageV)
        view.addSubview(topImageV)
        view.addSubview(inPutName)
        view.addSubview(inPutPassWord)
        view.addSubview(ensureBtn)
        
        topImageV.snp_makeConstraints { (make) in
            make.left.right.top.equalTo(self.view)
            make.height.equalTo(150)
        }
        
        imageV.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        inPutName.snp_makeConstraints { (make) in
            
            make.left.equalTo(self.view).offset(20)
            make.right.equalTo(self.view).offset(-20)
            make.top.equalTo(topImageV.snp_bottom).offset(80)
            make.height.equalTo(30)
        }
        
        inPutPassWord.snp_makeConstraints { (make) in
           make.left.right.equalTo(inPutName)
            make.top.equalTo(inPutName.snp_bottom).offset(20)
            make.height.equalTo(30)
        }
        
        ensureBtn.snp_makeConstraints { (make) in
            
            make.centerX.equalTo(self.view)
            make.top.equalTo(inPutPassWord.snp_bottom).offset(50)
        }
        
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        inPutName.resignFirstResponder()
        inPutPassWord.resignFirstResponder()
    
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
