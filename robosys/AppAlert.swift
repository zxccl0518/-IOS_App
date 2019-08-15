//
//  AppAlert.swift
//  robosys
//
//  Created by Cheer on 16/7/8.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class AppAlert : UIView
{
    internal var topView:UIView!
    var isNeedTouch = false {
    
        didSet {
        
            if isNeedTouch {
                
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AppAlert.bgHandleTapGesture(_:)))
                //设置手势点击数,双击：点2下
                tapGesture.numberOfTapsRequired = 1
                bgView.addGestureRecognizer(tapGesture)
            }
        }
    }
    internal var isLogin:Bool!
    {
        didSet
        {
            if isLogin == true
            {
                bgView.removeFromSuperview()
            }
        }
    }
    private lazy var bgView:UIView =
    {
        let bg = UIView(frame: UIScreen.mainScreen().bounds)
        bg.backgroundColor =  UIColor(red: 149 / 255, green: 149 / 255, blue: 149 / 255, alpha: 0.5)
        
        if self.isNeedTouch {
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AppAlert.bgHandleTapGesture(_:)))
            //设置手势点击数,双击：点2下
            tapGesture.numberOfTapsRequired = 1
            bg.addGestureRecognizer(tapGesture)
        }
      
        return bg
    }()
    
    func bgHandleTapGesture(sender: UITapGestureRecognizer) {
        
        self.dismiss()
    }
    
    convenience init(frame: CGRect,view:UIView,currentView:UIView,autoHidden:Bool)
    {
        self.init(frame: frame)

        topView = view
        topView.center = currentView.center
        
        self.addSubview(bgView)
        self.addSubview(topView)
        
        currentView.addSubview(self)
        
        if autoHidden
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(2 * Double(NSEC_PER_SEC))),dispatch_get_main_queue())
            {
                [weak self] in
                self!.dismiss()
            }
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        if let superV = superview where superV is MotionProgramView
        {
            for v in topView.subviews
            {
                if v is UITextView || v is UITextField
                {
                    v.resignFirstResponder()
                    return
                }
                
                if v.subviews.count > 2
                {
                    for sub in v.subviews
                    {
                        if sub is UITextField
                        {
                            sub.resignFirstResponder()
                        }
                    }
                }
            }
        }
       
        return
    }
    
    func dismiss()
    {
        dispatch_async(dispatch_get_main_queue()) { 
            
            self.removeFromSuperview()

        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
    }
    required init?(coder aDecoder: NSCoder) {
       fatalError("init(coder:) has not been implemented")
    }
    deinit
    {
        print("\(classForCoder)--hello there")
    }
}
