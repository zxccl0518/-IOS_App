//
//  BotmTabView.swift
//  robosys
//
//  Created by 刘渊 on 2017/4/21.
//  Copyright © 2017年 joekoe. All rights reserved.
//

import UIKit
import SnapKit


class BotmTabView: UIView {

    //重用标记
    private let tableID : String = "tableID"
    
    private lazy var headView : UIView = {
       
        let v = UIView()
        v.backgroundColor = UIColor.whiteColor()
        
        let label = UILabel()
        label.text = "编程控制"
        label.font = UIFont.systemFontOfSize(18)
        label.sizeToFit()
        
        let btn = UIButton()
        btn.sizeToFit()
        btn.setImage(UIImage(named : "Bottom_Add_file_Normal"), forState: .Normal)
        
        v.addSubview(btn)
        v.addSubview(label)
        
        
        btn.snp_makeConstraints(closure: { (make) in
            make.right.equalTo(v).offset(-10)
            make.centerY.equalTo(v)
        })
        
        label.snp_makeConstraints(closure: { (make) in
            make.left.equalTo(v).offset(10)
            make.centerY.equalTo(btn)
        })
        
        return v
        
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var botmTab : UITableView = {
       
        let tableV = UITableView(frame: CGRect.zero, style: .Grouped)
        tableV.bounces = false
        return tableV
    }()
    
    func setupUI() {
        
        botmTab.registerClass(UITableViewCell.self, forCellReuseIdentifier: tableID)
        botmTab.translatesAutoresizingMaskIntoConstraints = false
        botmTab.dataSource = self
        botmTab.delegate = self
        self.addSubview(botmTab)
        
        let leftBot = NSLayoutConstraint(item: botmTab, attribute: .Leading, relatedBy: .Equal, toItem: self, attribute: .Leading, multiplier: 1.0, constant: 0)
        let topBot = NSLayoutConstraint(item: botmTab, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 0)
        let rightBot = NSLayoutConstraint(item: botmTab, attribute: .Trailing, relatedBy: .Equal, toItem: self, attribute: .Trailing, multiplier: 1.0, constant: 0)
        let bottomBot = NSLayoutConstraint(item: botmTab, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0)
        self.addConstraints([leftBot,topBot,rightBot,bottomBot])
        
    }
}



extension BotmTabView : UITableViewDataSource,UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell : UITableViewCell = UITableViewCell(style: .Value1, reuseIdentifier: tableID)
        cell.textLabel?.text = "演示程序" + "\(indexPath.row)"
//        if indexPath.row == 0 {
//            let btn = UIButton()
//            btn.setImage(UIImage(named: "Bottom_Add_file_Normal"), forState: .Normal)
//            btn.addTarget(self, action: #selector(addClick), forControlEvents: .TouchUpInside)
//            btn.sizeToFit()
//            cell.accessoryView = btn
//        }
        
        return cell
    }
    
    func addClick() {
        
        print("点击了添加按钮")
        
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        headView.layoutIfNeeded()
        return headView
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
       //设置字体
        return "编程控制"
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return (self.frame.size.height / 4) + 10
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
            return (self.frame.size.height - 10)/3
    }
    
}



