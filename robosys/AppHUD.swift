//
//  AppHUD.swift
//  robosys
//
//  Created by Cheer on 16/7/22.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

///
/// @brief 样式
enum HYBProgressHUDStyle {
    case BlackHUDStyle /// 黑色风格
    case WhiteHUDStyle /// 白色风格
}

///
/// @brief 定制显示通知的视图HUD
class HYBProgressHUD: UIView {
    var hud: UIToolbar?
    var spinner: UIActivityIndicatorView?
    var imageView: UIImageView?
    var titleLabel: UILabel?
    
    ///
    /// private 属性
    ///
    private let statusFont = UIFont.boldSystemFontOfSize(16.0)
    private var statusColor: UIColor!
    private var spinnerColor: UIColor!
    private var bgColor: UIColor!
    private var successImage: UIImage!
    private var errorImage: UIImage!
    private  static var isRotate = false
    
    ///
    /// @brief 单例方法，只允许内部调用
    private class func sharedInstance() ->HYBProgressHUD {
        struct Instance {
            static var onceToken: dispatch_once_t = 0
            static var instance: HYBProgressHUD?
        }
        
        dispatch_once(&Instance.onceToken, { () -> Void in
            Instance.instance = HYBProgressHUD(frame: UIScreen.mainScreen().bounds)
            Instance.instance?.setStyle(HYBProgressHUDStyle.WhiteHUDStyle)
        })
        
        return Instance.instance!
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        hud = nil
        spinner = nil
        imageView = nil
        titleLabel = nil
        self.alpha = 0.0
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///
    /// 公开方法
    ///
    
    /// 显示信息
    class func show(status: String) {
        sharedInstance().configureHUD(status, image: nil, isSpin: true, isHide: false)
    }
    
    /// 显示成功信息
    class func showSuccess(status: String) {
        sharedInstance().configureHUD(status, image: sharedInstance().successImage, isSpin: false, isHide: true)
    }
    
    
    
    /// 显示出错信息
    class func showError(status: String,rotate:Bool = false) {
        
        HYBProgressHUD.isRotate  = rotate
        sharedInstance().configureHUD(status, image: sharedInstance().errorImage, isSpin: false, isHide: true)
    }
    
    /// 隐藏
    class func dismiss() {
        sharedInstance().hideHUD()
    }
    
    ///
    /// 私有方法
    ///
    
    ///
    /// @brief 创建并配置HUD
    private func configureHUD(status: String?, image: UIImage?, isSpin: Bool, isHide: Bool) {
        configureProgressHUD()
        
        /// 标题
        if status == nil {
            titleLabel!.hidden = true
        } else {
            titleLabel!.text = status!
            titleLabel!.hidden = false
        }
        // 图片
        if image == nil {
            imageView?.hidden = true
        } else {
            imageView?.hidden = false
            imageView?.image = image
        }
        
        // spin
        if isSpin {
            spinner?.startAnimating()
        } else {
            spinner?.stopAnimating()
        }
        
        
        if isHide
        {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW,Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                self.destroyProgressHUD()
            })
        }
        rotate(nil)
        addjustSize()
        showHUD()
        
    }
    
    ///
    /// @brief 设置风格样式，默认使用的是黑色的风格，如果需要改成白色的风格，请在内部修改样式
    private func setStyle(style: HYBProgressHUDStyle) {
        switch style {
        case .BlackHUDStyle:
            statusColor = UIColor.whiteColor()
            spinnerColor = UIColor.whiteColor()
            bgColor = UIColor(white: 0, alpha: 0.8)
            successImage = UIImage(named: "ProgressHUD.bundle/success-white.png")
            errorImage = UIImage(named: "ProgressHUD.bundle/error-white.png")
            break
        case .WhiteHUDStyle:
            statusColor = UIColor.whiteColor()
            spinnerColor = UIColor.whiteColor()
            bgColor = UIColor(red: 192.0 / 255.0, green: 37.0 / 255.0, blue: 62.0 / 255.0, alpha: 1.0)
            successImage = UIImage(named: "ProgressHUD.bundle/success-white.png")
            errorImage = UIImage(named: "ProgressHUD.bundle/error-white.png")
            break
        }
    }
    
    ///
    /// @brief 获取窗口window
    private func getWindow() ->UIWindow {
        if let delegate: UIApplicationDelegate = UIApplication.sharedApplication().delegate {
            if let window = delegate.window {
                return window!
            }
        }
        
        return UIApplication.sharedApplication().keyWindow!
    }
    
    ///
    /// @brief 创建HUD
    private func configureProgressHUD() {
        if hud == nil {
            hud = UIToolbar(frame: CGRectZero)
            hud?.barTintColor = bgColor
            hud?.translucent = true
            hud?.layer.cornerRadius = 10
            hud?.layer.masksToBounds = true
            
            /// 监听设置方向变化
            NSNotificationCenter.defaultCenter().addObserver(self,
                                                             selector: #selector(HYBProgressHUD.rotate(_:)),
                                                             name: UIDeviceOrientationDidChangeNotification,
                                                             object: nil)
        }
        
        if hud!.superview == nil {
            getWindow().addSubview(hud!)
        }
        
        if spinner == nil {
            spinner = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
            spinner!.color = spinnerColor
            spinner!.hidesWhenStopped = true
        }
        
        if spinner!.superview == nil {
            hud!.addSubview(spinner!)
        }
        
        if imageView == nil {
            imageView = UIImageView(frame: CGRectMake(0, 0, 28, 28))
        }
        
        if imageView!.superview == nil {
            hud!.addSubview(imageView!)
        }
        
        if titleLabel == nil {
            titleLabel = UILabel(frame: CGRectZero)
            titleLabel?.backgroundColor = UIColor.clearColor()
            titleLabel?.font = statusFont
            titleLabel?.textColor = statusColor
            titleLabel?.baselineAdjustment = UIBaselineAdjustment.AlignCenters
            titleLabel?.numberOfLines = 0
            titleLabel?.textAlignment = NSTextAlignment.Center
            titleLabel?.adjustsFontSizeToFitWidth = false
        }
        
        if titleLabel!.superview == nil {
            hud!.addSubview(titleLabel!)
        }
    }
    
    ///
    /// @brief 释放资源
    private func destroyProgressHUD() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIDeviceOrientationDidChangeNotification, object: nil)
        
        titleLabel?.removeFromSuperview()
        titleLabel = nil
        
        spinner?.removeFromSuperview()
        spinner = nil
        
        imageView?.removeFromSuperview()
        imageView = nil
        
        hud?.removeFromSuperview()
        hud = nil
    }
    
    ///
    /// @brief 设置方向变化通知处理
    func rotate(sender: NSNotification?) {
        var rotation: CGFloat = 0.0
        switch UIApplication.sharedApplication().statusBarOrientation {
        case UIInterfaceOrientation.Portrait:
            rotation = 0.0
            break
        case .PortraitUpsideDown:
            rotation = CGFloat(M_PI)
            break
        case .LandscapeLeft:
            rotation = -CGFloat(M_PI_2)
            break
        case .LandscapeRight:
            rotation = CGFloat(M_PI_2)
            break
        default:
            break
        }
        
        hud?.transform = CGAffineTransformMakeRotation(rotation)
    }
    
    ///
    /// @brief 调整大小
    private func addjustSize() {
        var rect = CGRectZero
        var width: CGFloat = 100.0
        var height: CGFloat = 100.0
        
        /// 计算文本大小
        if titleLabel!.text != nil {
            let style = NSMutableParagraphStyle()
            style.lineBreakMode = NSLineBreakMode.ByCharWrapping
            let attributes = [NSFontAttributeName: statusFont, NSParagraphStyleAttributeName: style.copy()]
            let option = NSStringDrawingOptions.UsesLineFragmentOrigin
            let text: NSString = NSString(CString: titleLabel!.text!.cStringUsingEncoding(NSUTF8StringEncoding)!,
                                          encoding: NSUTF8StringEncoding)!
            rect = text.boundingRectWithSize(CGSizeMake(160, 260), options: option, attributes: attributes, context: nil)
            rect.origin.x = 12
            rect.origin.y = 66
            
            width = rect.size.width + 24
            height = rect.size.height + 80
            
            if width < 100 {
                width = 100
                rect.origin.x = 0
                rect.size.width = 100
            }
        }
        
        hud!.center = CGPointMake(UIScreen.mainScreen().bounds.width / 2, UIScreen.mainScreen().bounds.height / 2)
        hud!.bounds = CGRectMake(0, 0, width, height)
        
        let h = titleLabel!.text == nil ? height / 2 : 36
        imageView!.center = CGPointMake(width / 2, h)
        spinner!.center = CGPointMake(width / 2, h)
        
        titleLabel!.frame = rect
    }
    
    ///
    /// @brief 显示
    private func showHUD() {
        if self.alpha == 0.0 {
            self.alpha = 1.0
            
            hud!.alpha  = 0.0
            self.hud!.transform = CGAffineTransformScale(self.hud!.transform, 1.4, 1.4)
            if HYBProgressHUD.isRotate
            {
                self.hud?.transform = CGAffineTransformMakeRotation(0)
            }
            UIView.animateKeyframesWithDuration(0.15,
                                                delay: 0.0,
                                                options: UIViewKeyframeAnimationOptions.AllowUserInteraction,
                                                animations: { () -> Void in
                                                    self.hud!.transform = CGAffineTransformScale(self.hud!.transform, 1.0 / 1.4, 1.0 / 1.4)
                                                    self.hud!.alpha = 1.0
                }, completion: { (isFinished) -> Void in
            })
        }
    }
    
    ///
    /// @brief 隐藏
    private func hideHUD() {
        if self.alpha == 1.0 {
            UIView.animateKeyframesWithDuration(0.2,
                                                delay: 0.0,
                                                options: UIViewKeyframeAnimationOptions.AllowUserInteraction,
                                                animations: { () -> Void in
                                                    self.hud!.transform = CGAffineTransformScale(self.hud!.transform, 0.35, 0.35)
                                                    self.hud!.alpha = 0.0
                }, completion: { (isFinished) -> Void in
                    self.destroyProgressHUD()
                    self.alpha = 0.0
            })
        }
    }
}
