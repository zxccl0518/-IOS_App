//
//  SettingView.swift
//  robosys
//
//  Created by Cheer on 16/5/23.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class SettingView : AppView
{
    @IBOutlet weak var usernameTxtField: UITextField!
    @IBOutlet weak var maleBtn: UIButton!
    @IBOutlet weak var femaleBtn: UIButton!
    @IBOutlet weak var pickerBtn: UIButton!
    @IBOutlet weak var enterBtn: UIButton!
    
    
    lazy var date: NSDate =
    {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy年MM月dd日"
        let date = dateFormatter.dateFromString("1990年01月01日")!
        return date
    }()
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        initHeadView("设置", imageName: "")
        initTxtField(usernameTxtField, string: " 昵 称", type: "text")
        
        initBtn(femaleBtn)
        initBtn(maleBtn)
        
        usernameTxtField.delegate = self
    }
    @IBAction func clickEnter(sender: UIButton)
    {
        (registM.isMale,registM.name,registM.birthday)  = (maleBtn.selected,usernameTxtField.text!, pickerBtn.titleLabel?.text!)
        
        //服务器更新
        connect.didSetUserInfo(loginM.num, token: loginM.token, nickName:registM.name, birthday: registM.birthday, sex: registM.isMale ? 0 : 1)

        (getCurrentVC() as! UINavigationController).popToRootViewControllerAnimated(true)
    }
    @IBAction func clickPicker(sender: UIButton)
    {
        let datepicker =  UINib(nibName: "APPDatePicker", bundle: nil).instantiateWithOwner(nil, options: nil).first as! APPDatePicker
        datepicker.lastView = self
        _ = AppAlert(frame: UIScreen.mainScreen().bounds, view: datepicker, currentView: self, autoHidden: false)
    }
    @IBAction func txtFieldStatus(sender: UITextField)
    {
        enterBtn.enabled = usernameTxtField.text != ""
    }
    @IBAction func clickGender(sender: UIButton)
    {
        guard sender.selected else
        {
            maleBtn.selected = !maleBtn.selected
            femaleBtn.selected = !femaleBtn.selected
 
            return
        }
    }
    func initBtn(button:UIButton)
    {
        button.setImage(UIImage(named: "性别选择底"), forState: .Normal)
        button.setImage(UIImage(named: "性别选择"), forState: .Selected)
    }
    deinit
    {
        print("\(classForCoder)--hello there")
    }
}
