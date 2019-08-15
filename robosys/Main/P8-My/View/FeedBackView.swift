//
//  FeedBackView.swift
//  robosys
//
//  Created by Cheer on 16/7/15.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class FeedBackView: AppView,UITextViewDelegate
{
    @IBOutlet weak var ensureBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    override func awakeFromNib()
    {
        super.awakeFromNib()
        
        initMainHeadView("意见反馈", imageName: "返回")
        
        textView.attributedText =  NSAttributedString(string:"您的意见就是对我们最大的鼓励..",attributes: [NSForegroundColorAttributeName:UIColor(red: 186 / 255, green: 249 / 255, blue: 1, alpha: 1),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 14)!])
        textView.delegate = self
        
        addBorder(textView)
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool
    {
        return true
    }
    func textViewDidBeginEditing(textView: UITextView)
    {
        textView.becomeFirstResponder()
        
        textView.attributedText = NSAttributedString(string:"",attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 14)!])
    }
    func textViewDidChangeSelection(textView: UITextView)
    {
        textView.textColor = .whiteColor()
    }
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?)
    {
        textView.resignFirstResponder()
        
        code()
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        textField.resignFirstResponder()
        
        code()
        
        return true
    }
    func code()
    {
        if textView.attributedText.length == 0
        {
            textView.attributedText =  NSAttributedString(string:"您的意见就是对我们最大的鼓励..",attributes: [NSForegroundColorAttributeName:UIColor(red: 186 / 255, green: 249 / 255, blue: 1, alpha: 1),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 14)!])
            
            ensureBtn.enabled = false
        }
        else
        {
            ensureBtn.enabled = true
        }
    }
    
    @IBAction func btnClick(sender: AnyObject) {
        
        let lgModel : loginModel = loginModel.sharedInstance
        
        let num = lgModel.num
        let token = lgModel.token
        let contentStr = textView.text
        
        let codeNumberArry = connect.didUserFeedback(num, token: token, contentStr: contentStr) as NSMutableArray
        let codeNumber = codeNumberArry.firstObject as! NSNumber

        if 0 ==  codeNumber.intValue
        {
            Alert({
                [unowned self] in
                
                self.textView.text = ""
                }, title: "提交成功", message: "")
        }
        else
        {
            Alert({}, title: "提交失败", message: "")
        }
    }
}
