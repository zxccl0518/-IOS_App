//
//  LearnViewController.swift
//  robosys
//
//  Created by Cheer on 16/5/26.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit
import SnapKit
import WebKit
class LearnViewController: UIViewController,WKNavigationDelegate {
    
    private lazy var imageVM : UIImageView = UIImageView(image: UIImage(named: "首页-背景"))
    private lazy var learnWebView:WKWebView = WKWebView()
    private lazy var networkM = networkModel.sharedInstance
    
//    private lazy var bgBtn:UIButton = {
//       
//        let btn = UIButton()
//        btn.hidden = true
//        btn.setTitle("加载失败,点击重新加载", forState: UIControlState())
//        btn.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
//        btn.backgroundColor = UIColor.clearColor()
//        btn.addTarget(self, action: #selector(reLoad), forControlEvents: .TouchUpInside)
//        return btn
//    }()
    
     var isHome = true {
        
        didSet{
            
            if isHome {
                
                learnWebView.scrollView.bounces = false
                    headView.hidden = false
                    learnWebView.snp_remakeConstraints(closure: { (make) in
                        make.top.equalTo(self.headView.snp_bottom)
                        make.left.right.equalTo(self.view)
                        make.bottom.equalTo(self.view).offset(-60)
                    })
            }else{
                learnWebView.scrollView.bounces = false
                    headView.hidden = true
                    learnWebView.snp_remakeConstraints(closure: { (make) in
                        make.top.equalTo(20)
                        make.left.right.equalTo(self.view)
                        make.bottom.equalTo(self.view).offset(-60)
                    })
            }
        }
    }
    
    
    private var headView : MainHeadView = {
       
        let headV = MainHeadView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.size.width, 64))
        headV.imageV.hidden = true
        headV.titleLabel.text = "学习"
        headV.leftBtn.snp_remakeConstraints(closure: { (make) in
            make.left.equalTo(18)
            make.width.equalTo(40)
            make.top.equalTo(headV).offset(30)
        })
        
        headV.titleLabel.snp_remakeConstraints(closure: { (make) in
            make.centerX.equalTo(headV)
            make.centerY.equalTo(headV.leftBtn)
            make.height.equalTo(20.5)
        })
        
        headV.leftBtn.setImage(UIImage(named: "菜单"), forState: .Normal)
        return headV
        
    }()
    
    
    lazy var control = RobotControl.shareInstance()
    
    lazy var loginM = loginModel.sharedInstance
    
//    func reLoad(){
//     
//        bgBtn.hidden = true
//        
//        let str : String = "http://robosys.cc:6789/faxian/study/index.html?username="
//        
//        let url = (str as String) + loginM.num + "&" + "token=\(loginM.token)" + "&" + "robot=\(loginM.robotId)"
//        
//        learnWebView.loadRequest(NSURLRequest(URL: NSURL(string: url as String)!))
//    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        NSURLCache.sharedURLCache().removeAllCachedResponses()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(imageVM)
        imageVM.snp_makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        learnWebView.navigationDelegate = self
        
        self.view.addSubview(learnWebView)
        self.view.addSubview(headView)
//        self.view.addSubview(bgBtn)
        
//        bgBtn.snp_makeConstraints { (make) in
//            make.top.equalTo(self.headView.snp_bottom)
//            make.left.right.equalTo(self.view)
//            make.bottom.equalTo(self.view).offset(-60)
//        }
        
        headView.hidden = false
        
        //http://192.168.0.111/faxian/study/index.html?username=手机号&token=token值&robot=机器人sn号码
//        let str : String = "http://192.168.0.111/faxian/study/index.html?username="
        let str : String = "http://robosys.cc:6789/faxian/study/index.html?username="
        
        let url = (str as String) + loginM.num + "&" + "token=\(loginM.token)" + "&" + "robot=\(loginM.robotId)"
        
        learnWebView.loadRequest(NSURLRequest(URL: NSURL(string: url as String)!))
        

    }
    
    //开始加载的时候调用
    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        let str1 = String(webView.URL)
        print("str1 +++++++++++    \(str1)")
        
        if str1.containsString("http://robosys.cc:6789/faxian/study/index.html?username=") {
            self.isHome = true
        }else{
            self.isHome = false
        }
        
        
        let urlStr = str1.stringByReplacingPercentEscapesUsingEncoding(NSUTF8StringEncoding)

        if urlStr!.containsString("robosys_action") && urlStr!.containsString("&&&&") {

            let spliteArray = urlStr!.componentsSeparatedByString("&&&&")

            var str = spliteArray[5]
            str = str.stringByReplacingOccurrencesOfString(")", withString: "")

            if spliteArray.count == 6 {

                if let connect = robotModel.sharedInstance.connect where connect {

                    print("播放成功")
                    dispatch_async(dispatch_get_global_queue(0, 0), { [unowned self] in
                        self.control.didStudy(spliteArray[2],coursetitle: spliteArray[3],coursepath: spliteArray[4],stop: str)
                    })

                }else{
                    print("未连接");
                    self.Alert({}, title: "请连接机器人", message: "")
                }
                
            }
        }
    }
    
    
    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
        
        let str2 = String(webView.URL)
        
        if str2.containsString("robosys_action") && str2.containsString("&&&&") {
            decisionHandler(WKNavigationResponsePolicy.Cancel)
        }else{
            decisionHandler(WKNavigationResponsePolicy.Allow)
        }        
    }
}




