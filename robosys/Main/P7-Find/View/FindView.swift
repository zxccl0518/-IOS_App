//
//  FindView.swift
//  robosys
//
//  Created by Cheer on 16/5/26.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class FindView: AppView, UIWebViewDelegate
{
    private lazy var findWebView : UIWebView = {
       
        let find = UIWebView()
        
        find.loadRequest(NSURLRequest(URL: NSURL(string: "http://robosys.cc:6789/faxian/faxian.html")!))
        
//        find.opaque = false
        
        find.scrollView.bounces = false
        
        find.delegate = self
        return find
    }()
    
    private lazy var imgV : UIImageView = UIImageView(image: UIImage(named: "首页-背景"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        self.addSubview(imgV)
        imgV.snp_makeConstraints { (make) in
            make.edges.equalTo(self)
        }
                
        self.addSubview(findWebView)
        
        findWebView.snp_makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
//            make.top.equalTo(headView.snp_bottom).offset(5)
            make.left.right.equalTo(self)
            make.bottom.equalTo(self).offset(-60)
        }

        /*
         private lazy var topImageV : UIView = {
         
         let  headView = AppHeadView(frame: CGRectMake(0,0,UIScreen.mainScreen().bounds.width,200))
         self.view.addSubview(headView)
         
         headView.titleLabel.text = "切换网络"
         
         headView.leftBtn.setImage(UIImage(named: "返回"), forState: .Normal)
         
         return headView
         }()
         */
//        let headView = initMainHeadView("发现", imageName: "返回")
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func webViewDidStartLoad(webView: UIWebView)
    {
//        HYBProgressHUD.show("正在加载")
    }
    func webViewDidFinishLoad(webView: UIWebView)
    {
//        findWebView.scrollView.keyboardDismissMode = .OnDrag
//        HYBProgressHUD.dismiss()
    }
    
    
    
    
    func webView(webView: UIWebView, shouldStartLoadWithRequest request: NSURLRequest, navigationType: UIWebViewNavigationType) -> Bool {
        
        let urlStr = String(request.URL);
        print(urlStr);
        
        if urlStr.containsString("robosys_action") && urlStr.containsString("&") {
            
            let splitedArray = urlStr.componentsSeparatedByString("&");
            print("shouldStartLoadWithRequest=======\(splitedArray)");
            
            if splitedArray.count == 3 {
                let op_cmd = splitedArray[1];
                let op_obj = splitedArray[2];
                
                let op_cmd_v = op_cmd.componentsSeparatedByString("=");
                var op_obj_v = op_obj.componentsSeparatedByString("=");
                
                if "playTrack" == op_cmd_v[1] {
                    
                    if let connect = robotM.connect where connect
                    {
                        print("已连接");
                        
                        // if op_cmd_v[1].hasSuffix(")") {
                        //     op_obj_v[1] = control.didPlayUrl(op_obj_v[1].removeAtIndex(op_obj_v[1].endIndex));
                        // }
                        
                        op_obj_v[1] = op_obj_v[1].stringByReplacingOccurrencesOfString(")", withString: "");
                        
                        // 播放音乐
                        print("shouldStartLoadWithRequest====播放音乐====\(op_obj_v[1])");
                        
//                        dispatch_async(dispatch_get_global_queue(0, 0))
//                        {
                            let res = self.control.didPlayUrl(op_obj_v[1]);
                            self.Alert({}, title: res == 0 ? "播放成功" : "播放失败", message: "")
                           
//                        }
                    
                    } else {
                        print("未连接");
                        self.Alert({}, title: "请连接机器人", message: "")
                        return false;
                    }
                }
            }
            return false;
        }
        return true;
    }
    
}

