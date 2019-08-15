//
//  MotionProgramCell.swift
//  robosys
//
//  Created by Cheer on 16/6/16.
//  Copyright © 2016年 joekoe. All rights reserved.
//

import UIKit


class MotionProgramCell: UITableViewCell,UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,UICollectionViewDelegate
{
    typealias deleteCell=(cell:MotionProgramCell,row:Int)->Void

    private var row:Int!
    private var originX:CGFloat!
    private var tempMoveCell:UIView!
    private var originIndexPath:NSIndexPath!
    private var isChanged = false
    private var tempIndexPath:NSIndexPath!
    internal var indexArr = [Int]()
    var deleteObject = deleteCell?()
    lazy var layout = ProgramCollectionLayout()
    var backImgView : UIImageView?{
    
        didSet{
            
            if backImgView != nil {
                
                backImgView?.removeFromSuperview()
            }
                        
            self.contentView.insertSubview(self.backImgView!, atIndex: 0)
            self.contentView.layer.masksToBounds = true
        }
    }
    lazy var alertView:UIView =
    {
        let alertView = UIView(frame:CGRectMake(0,0,300,180))
        alertView.center = CGPointMake(UIScreen.mainScreen().bounds.size.width * 0.5 , UIScreen.mainScreen().bounds.size.height * 0.5)
        
        let bgImg = UIImageView(frame: CGRectMake(0, 0, 300, 180))
        bgImg.image = UIImage(named: "WiFi弹窗")
        
        let deleteBtn = UIButton(frame: CGRectMake(60,120,180,40))
        deleteBtn.setAttributedTitle(NSAttributedString(string:"删除" ,
                                                        attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
                                                        , forState: .Normal)
        deleteBtn.setBackgroundImage(UIImage(named:"小橙按钮"), forState: .Normal)
        deleteBtn.addTarget(self, action: #selector(MotionProgramCell.handleAlertClick(_:)), forControlEvents: .TouchUpInside)
        
        let copyBtn = UIButton(frame: CGRectMake(60,20,180,40))
        copyBtn.setAttributedTitle(NSAttributedString(string:"复制" ,
                                                      attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
                                                      , forState: .Normal)
        copyBtn.setBackgroundImage(UIImage(named:"小蓝按钮"), forState: .Normal)
        copyBtn.addTarget(self, action: #selector(MotionProgramCell.handleAlertClick(_:)), forControlEvents: .TouchUpInside)
        
        let modifyBtn = UIButton(frame: CGRectMake(60,70,180,40))
        modifyBtn.setAttributedTitle(NSAttributedString(string:"修改" ,
            attributes: [NSForegroundColorAttributeName:UIColor.whiteColor(),NSFontAttributeName:UIFont(name: "RTWS yueGothic Trial", size: 17)!])
            , forState: .Normal)
        modifyBtn.setBackgroundImage(UIImage(named:"小蓝按钮"), forState: .Normal)
        modifyBtn.addTarget(self, action: #selector(MotionProgramCell.handleAlertClick(_:)), forControlEvents: .TouchUpInside)
        
        alertView.addSubview(bgImg)
        alertView.addSubview(deleteBtn)
        alertView.addSubview(copyBtn)
        alertView.addSubview(modifyBtn)
        
        return alertView
        
    }()
    
    func handleAlertClick(sender:UIButton)
    {
        switch sender.titleLabel!.text!
        {
        case "删除":
            delete()
        case "复制":
            if let view = superview?.superview?.superview?.superview as? MotionProgramView
            {
                view.createCollectionCell(row, index:indexArr[tempIndexPath.row], width: frameArr[tempIndexPath.row].width, param: funcArr[tempIndexPath.row]!.1)
            }
        case "修改":
            if let view = superview?.superview?.superview?.superview as? MotionProgramView
            {
                if indexArr.count > tempIndexPath.row  {
                    
                    let index = indexArr[tempIndexPath.row]
                    alert.dismiss()
                    view.showPopView(row, index: index,bool:true)
                }
                
                return
            }
        default:
            break
        }
        alert.dismiss()
    }
    
    func delete()
    {
        if tempIndexPath.row >= funcArr.count{ print("range of Index"); return}
        funcArr.removeAtIndex(tempIndexPath.row)
        
        if tempIndexPath.row >= frameArr.count{ print("range of Index"); return}
        frameArr.removeAtIndex(tempIndexPath.row)
        
        if tempIndexPath.row >= dataArr.count{ print("range of Index"); return }
        dataArr.removeAtIndex(tempIndexPath.row)
        
        self.deleteObject!(cell: self,row: tempIndexPath.row)
        
        tempIndexPath = nil
        
        self.collect.reloadData()
        
    }
    
    private var alert:AppAlert!
    
    var frameArr = [CGRect]()
    {
        didSet
        {
            layout.frameArr = frameArr
        }
    }

    var collect:UICollectionView!
    {
        didSet
        {
            collect.backgroundColor = .clearColor()
            collect.delegate = self
            collect.dataSource = self
            collect.scrollEnabled = false
            collect.registerClass(ProgramCollectionCell.classForCoder(), forCellWithReuseIdentifier: "ProgramCollectionCell")
            collect.bounces = false   //不关回弹就会在通知时候卡顿，而且会无限偏移
            collect.showsHorizontalScrollIndicator = false
            collect.showsVerticalScrollIndicator  = false
        }
    }
    
    var dataArr:[UIImage] = []
    {
        didSet
        {
            if collect == nil
            {
                collect = UICollectionView(frame: CGRect(origin: CGPointZero, size: frame.size),collectionViewLayout:layout)
           
                addSubview(collect)
                
            }
            collect.reloadData()
            
        }
    }
    
    var funcArr:[(String,[String?],Int,Int)?] = []
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(row:Int,frameArr:[CGRect],style: UITableViewCellStyle, reuseIdentifier: String?)
    {
        self.init(style: style, reuseIdentifier: reuseIdentifier)
        
        
        self.row = row
        self.frameArr = frameArr
        layout.frameArr = frameArr

//        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MotionProgramCell.changeOffsetX(_:)), name: "changeOffsetX", object: collect)
    }
    func changeOffsetX(noti:NSNotification)
    {
        if let userInfo = noti.userInfo,let x = userInfo["OffsetX"]! as? CGFloat where collect != nil && x >= 0
        {
            collect.setContentOffset(CGPoint(x:x,y:0), animated: false)
        }
    }
    
    func handleLongGesture(gesture: UILongPressGestureRecognizer)
    {
        switch(gesture.state)
        {
            
        case .Began:
            
            guard let IndexPath = collect.indexPathForItemAtPoint(gesture.locationInView(collect)) else { return }
            
            originIndexPath = IndexPath
            
            let cell = collect.cellForItemAtIndexPath(originIndexPath)!
            cell.hidden = true
            tempMoveCell = cell.snapshotViewAfterScreenUpdates(false)
            tempMoveCell.frame = cell.frame
            
            collect.addSubview(tempMoveCell)
            
            originX = gesture.locationOfTouch(0, inView: gesture.view).x
    
        case .Changed:
            
            let t =  CGAffineTransformMakeTranslation(gesture.locationOfTouch(0, inView: gesture.view).x - originX,0)
            tempMoveCell.center.x = tempMoveCell.center.x * t.a + t.tx
            tempMoveCell.center.y = collect.center.y
            
            originX = gesture.locationOfTouch(0, inView: gesture.view).x
            
            for cell in collect.visibleCells()
            {
                if collect.indexPathForCell(cell) != originIndexPath && fabs(tempMoveCell.center.x - cell.center.x) <= tempMoveCell.frame.width * 0.5
                {
                    let moveIndexPath = collect.indexPathForCell(cell)!
                    
                    //一定要先交换width
                    (cell.frame.size.width,collect.cellForItemAtIndexPath(originIndexPath)!.frame.size.width) = (collect.cellForItemAtIndexPath(originIndexPath)!.frame.size.width,cell.frame.size.width)
 
                    //再变换
                    collect.moveItemAtIndexPath(originIndexPath, toIndexPath:moveIndexPath)
                    
                    isChanged = true
                    
                    //交换数据源
                    (dataArr[moveIndexPath.row],dataArr[originIndexPath.row]) = (dataArr[originIndexPath.row],dataArr[moveIndexPath.row])
                    
                    (funcArr[moveIndexPath.row],funcArr[originIndexPath.row]) = (funcArr[originIndexPath.row],funcArr[moveIndexPath.row])
                    
                    (cell as! ProgramCollectionCell).resetCenter()
                    
                    (collect.cellForItemAtIndexPath(moveIndexPath) as! ProgramCollectionCell).resetCenter()
                    
                    originIndexPath = moveIndexPath

                    gesture.enabled = false
                }
            }
            
        case .Cancelled,.Ended:

            gesture.enabled = true
            
            let cell = collect.cellForItemAtIndexPath(originIndexPath)!
            
            if !isChanged
            {
                var count = 0
                for i in collect.subviews
                {
                    if i.classForCoder != ProgramCollectionCell.classForCoder()
                    {
                        count += 1
                    }
                }
                //改变cell 的frame
                if originIndexPath.row == 0
                {
                    cell.frame.origin.x  = tempMoveCell.frame.origin.x < 0 ? 0 : tempMoveCell.frame.origin.x
                    
                    if let nextCell = collect.cellForItemAtIndexPath(NSIndexPath(forRow: originIndexPath.row + 1, inSection: 0))
                    {
                        if nextCell.frame.origin.x < cell.frame.origin.x + cell.frame.width
                        {
                            cell.frame.origin.x = nextCell.frame.origin.x - cell.frame.width
                        }
                    }
                }
                else if originIndexPath.row == collect.subviews.count - count - 1
                {
                    //最后一个
                    if let preCell = collect.cellForItemAtIndexPath(NSIndexPath(forRow: originIndexPath.row - 1, inSection: 0))
                    {
                        cell.frame.origin.x = fabs(tempMoveCell.center.x - preCell.center.x) > tempMoveCell.frame.width * 0.5 + preCell.frame.width * 0.5 ? tempMoveCell.frame.origin.x : preCell.frame.origin.x + preCell.frame.width
                    }
                    
                }
                else
                {
                    //中间的
                    
                    if  let preCell = collect.cellForItemAtIndexPath(NSIndexPath(forRow: originIndexPath.row - 1, inSection: 0)),
                        let  nextCell = collect.cellForItemAtIndexPath(NSIndexPath(forRow: originIndexPath.row + 1, inSection: 0))
                    {
                        if fabs(tempMoveCell.center.x - preCell.center.x) > tempMoveCell.frame.width * 0.5 + preCell.frame.width * 0.5
                        {
                            cell.frame.origin.x  = tempMoveCell.frame.origin.x
                        }
                        else
                        {
                            cell.frame.origin.x  = preCell.frame.origin.x + preCell.frame.width
                            return
                        }
                        
                        
                        if fabs(tempMoveCell.center.x - nextCell.center.x) > tempMoveCell.frame.width * 0.5 + nextCell.frame.width * 0.5
                        {
                            cell.frame.origin.x  = tempMoveCell.frame.origin.x
                        }
                        else
                        {
                            cell.frame.origin.x  = nextCell.frame.origin.x - cell.frame.width
                        }
                    }
                }
            }

            frameArr[originIndexPath.row] = cell.frame
            
            collect.userInteractionEnabled = false
            
            cell.hidden = false
            
            tempMoveCell.removeFromSuperview()
            
            collect.userInteractionEnabled = true
            
            isChanged = false
     
        default : break
        }
    }
    
    //设置分区个数
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    //设置每个分区元素个数
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return  dataArr.count
    }
    //设置元素内容
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        //这里创建cell
        let cell =  collectionView.dequeueReusableCellWithReuseIdentifier("ProgramCollectionCell", forIndexPath: indexPath) as! ProgramCollectionCell

        let imageV = UIImageView(frame: CGRectMake(0, 0, frameArr[indexPath.row].size.width, frameArr[indexPath.row].size.height))
        imageV.contentMode = .ScaleAspectFit
        imageV.image = dataArr[indexPath.row]
        cell.imageView = imageV
        

        cell.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(MotionProgramCell.handleLongGesture(_:))))

        cell.backgroundColor = UIColor(white: 0.7, alpha: 0.7)
        
        return cell
    }
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
         tempIndexPath = indexPath
        
        //弹窗
        if let view = superview?.superview?.superview?.superview as? MotionProgramView
        {
            alert = AppAlert(frame: UIScreen.mainScreen().bounds, view: alertView, currentView: view, autoHidden: false)
            alert.isNeedTouch = true
        }
    }

    //设置size
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {

        return frameArr[indexPath.row].size
    }

    deinit
    {        
        print("\(classForCoder)--hello there")
    }
}



class ProgramCollectionCell: UICollectionViewCell
{
    var imageView:UIImageView!
    {
        willSet
        {
            if imageView != nil {
                
                imageView.removeFromSuperview()
            }
            
        }
        didSet
        {
            insertSubview(imageView, atIndex: 0)
        }
    }
    
    func resetCenter()
    {
        for view in subviews
        {
            if view.classForCoder == UIImageView.classForCoder()
            {
                view.center.x = frame.width * 0.5
            }
        }
    }
    
}




class ProgramCollectionLayout: UICollectionViewFlowLayout
{
    var frameArr:[CGRect]!
    {
        didSet
        {
            collectionViewContentSize()
        }
    }
    
    override func prepareLayout() {
        super.prepareLayout()
        
        scrollDirection = .Horizontal
        minimumLineSpacing = 0.1
        
    }
    // 这个方法返回每个单元格的位置和大小
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath)
        -> UICollectionViewLayoutAttributes?
    {
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        
        if frameArr == nil { return attributes }
        
        attributes.frame = frameArr[indexPath.row]

        return attributes
    }
    
    // 返回内容区域总大小，不是可见区域
    override func collectionViewContentSize() -> CGSize
    {
        return frameArr.last != nil ?  CGSize(width: (frameArr.last!.origin.x  + frameArr.last!.width), height: frameArr.last!.height) : CGSize(width: 0, height: 0)
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool
    {
        return true
    }
    // 返回所有单元格位置属性(重用的时候调用，添加的时候调用)
    override func layoutAttributesForElementsInRect(rect: CGRect)
        -> [UICollectionViewLayoutAttributes]? {
            
            var attributes = [UICollectionViewLayoutAttributes]()
            
            for row in 0..<collectionView!.numberOfItemsInSection(0)
            {
                let indexPath = NSIndexPath(forRow: row, inSection: 0)
                attributes.append(layoutAttributesForItemAtIndexPath(indexPath)!)
            }
           
        return attributes
    }
}
