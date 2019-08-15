//
//  PersonalInformationView.swift
//  robosys
//
//  Created by Cheer on 16/5/27.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class PersonalInformationView: AppView
{
 
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var userNameBtn: UIButton!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var pickerBtn: UIButton!
    @IBOutlet weak var createTimeLabel: UILabel!
    @IBOutlet weak var passwordView: UIView!
    
    private var alert:AppAlert!
    private var tempBtn:UIButton!
    
    private lazy var tempTxtField = UITextField()
    internal lazy var isUpdate = false

    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        initMainHeadView("个人信息", imageName: "返回")
        
        maleBtn.setImage(UIImage(named: "性别选择"), forState: .Selected)
        femaleBtn.setImage(UIImage(named: "性别选择"), forState: .Selected)
 
        accountLabel.text = loginM.num
        createTimeLabel.text = registM.createTime
        
        userNameBtn.setTitle(registM.name, forState: .Normal)
       
        if (registM.birthday != nil)  {
            
            print("\(registM.birthday)")
            
            if let title = (registM.birthday as NSString).componentsSeparatedByString(" ").first
            {
                pickerBtn.setTitle(title, forState: .Normal)
            }
        }
    
        registM.isMale ? maleBtn.selected = true : (femaleBtn.selected = true)
        tempBtn = maleBtn
        
        addBorder(passwordView)
    }

    @IBAction func clickName(sender: UIButton)
    {
        let view = UIView(frame: CGRectMake(0,0,260,180))
        
        let bgImg = UIImageView(frame: CGRectMake(0, 0, 260, 180))
        bgImg.image = UIImage(named: "WiFi弹窗")
        view.addSubview(bgImg)
        
        let titleLabel = UILabel(frame: CGRectMake(0, 10, 260, 20))
        titleLabel.textAlignment = .Center
        titleLabel.attributedText = NSAttributedString(string:"请输入新昵称" ,attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])

        view.addSubview(titleLabel)
        
        tempTxtField = UITextField(frame: CGRectMake(30,50,200,40))
        tempTxtField.center.x = view.frame.width * 0.5
        tempTxtField.textColor = .whiteColor()
        tempTxtField.delegate = self
        addBorder(tempTxtField)
        view.addSubview(tempTxtField)
        
        let btn = UIButton(frame: CGRectMake(40,110,180,30))
        btn.setBackgroundImage(UIImage(named: "小蓝按钮"), forState: .Normal)
        btn.center.x = view.frame.width * 0.5
        btn.setTitle("确定", forState: .Normal)
        btn.addTarget(self, action: #selector(PersonalInformationView.clickEnsure), forControlEvents: .TouchUpInside)
        view.addSubview(btn)
        
        alert = AppAlert(frame: UIScreen.mainScreen().bounds, view: view, currentView: self, autoHidden: false)
        alert.isNeedTouch = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        tempTxtField.resignFirstResponder()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        
        return true
    }
    
    func clickEnsure()
    {
        if !tempTxtField.text!.isEmpty
        {
            userNameBtn.setTitle(tempTxtField.text, forState: .Normal)
            isUpdate = true
            registM.name = tempTxtField.text
            dispatch_async(dispatch_get_global_queue(0, 0), {
                
                RobotConnect.shareInstance().didSetUserInfo(self.loginM.num, token: self.loginM.token, nickName: self.registM.name)
            })
            
        }
        
        alert.dismiss()
    }
    

    @IBAction func clickDate(sender: UIButton)
    {         
        let datepicker =  UINib(nibName: "APPDatePicker", bundle: nil).instantiateWithOwner(nil, options: nil).first as! APPDatePicker
        datepicker.lastView = self
        
        self.alert = AppAlert(frame: UIScreen.mainScreen().bounds, view: datepicker, currentView: self, autoHidden: false)
        
        isUpdate = true
    }
    
    @IBAction func changeGender(sender: UIButton)
    {
        if sender.selected
        {
            return
        }
        
        maleBtn.selected = !maleBtn.selected
        femaleBtn.selected = !femaleBtn.selected
        isUpdate = true
        
        registModel.sharedInstance.isMale = maleBtn.selected
        
        dispatch_async(dispatch_get_global_queue(0, 0), {
            
            RobotConnect.shareInstance().didSetUserInfo(self.loginM.num, token: self.loginM.token, sex: registModel.sharedInstance.isMale ? 0 : 1)
        })
        
    }
    
    
    @IBAction func changePsw(sender: UIButton)
    {
        jump2AnyController(ChangePasswordViewController(nibName: "ChangePasswordView",bundle: nil))
    }
    deinit
    {
        print("\(classForCoder)--hello there")
    }
}
