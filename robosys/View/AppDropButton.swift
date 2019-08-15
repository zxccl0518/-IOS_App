//
//  AppDropButton.swift
//  robosys
//
//  Created by Cheer on 16/6/6.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit

class AppDropButton: UIButton,UITableViewDelegate,UITableViewDataSource
{

    var tableV: UITableView!
    
    var dataArr:NSArray!
    {
        didSet
        {
            tableV.reloadData()
        }
    }
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        addTarget(self, action: #selector(AppDropButton.click(_:)), forControlEvents: .TouchUpInside)
        backgroundColor = .greenColor()
        
        tableV = UITableView(frame: CGRectMake(0, frame.size.height, frame.size.width, 300))
        tableV.showsVerticalScrollIndicator = false
        tableV.showsHorizontalScrollIndicator = false
        tableV.separatorStyle = .None
        tableV.hidden = true
        tableV.delegate = self
        tableV.dataSource = self
        addSubview(tableV)
        
        let imgV = UIImageView(frame: tableV.frame)
        imgV.image = UIImage(named: "下拉气泡框")
        addSubview(imgV)
    }
    
    func click(btn:UIButton)
    {
        btn.selected = !btn.selected
        tableV.hidden =  btn.selected ? false : true
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataArr == nil ? 3 : dataArr.count
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell  = UITableViewCell(frame: CGRectMake(0, 0, frame.size.width,20))
//        let btn = UIButton(frame: CGRectMake(0,0,0,0))
//        btn.setTitle(dataArr[indexPath.row] as? String, forState: .Normal)
        let label = UILabel(frame: CGRectMake(0, 0, frame.size.width,20))
        label.text = dataArr[indexPath.row] as? String
        label.textColor = .redColor()
        cell.addSubview(label)
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
