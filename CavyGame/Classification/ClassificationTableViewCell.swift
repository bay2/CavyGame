//
//  ClassificationTableViewCell.swift
//  
//
//  Created by xuemincai on 16/1/20.
//
//

import UIKit

class ClassificationTableViewCell: UITableViewCell {

    var classImgView = UIImageView()
    var tagViewDelegate: ClassificationCellProtocol?
    let splitLineColor = "#868686"
    let frameGap: CGFloat = 24
    var curIndexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    var tagViewNum: Int = 0
    var cellTagViewList: Array<UIView> = Array<UIView>()
    var cellTagView = UIView()
    var cellTagViewCache = NSCache()
    
    var classImgUrl: String = "" {
        
        didSet {
            classImgView.sd_setImageWithURL(NSURL(string: classImgUrl), placeholderImage: UIImage(named: "icon_game"))
            classImgView.layer.masksToBounds = true
            classImgView.layer.cornerRadius = Common.iconCornerRadius
        }
    }
    
    // 间隙
    var gap : Float {
        
        get {
            return Float(Common.screenWidth - (80 * 3 + frameGap * 2)) / 2
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        defineSubview()
        defineSubvieLayer()
        
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    /**
    定义子视图
    */
    func defineSubview() {
        
        classImgView.backgroundColor = UIColor(hexString: "#dedede")
        self.contentView.addSubview(classImgView)
        
        
    }
    
    /**
    定义子视图布局
    */
    func defineSubvieLayer() {
        
        classImgView.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(CGSize(width: 80, height: 80))
            make.centerY.equalTo(self.contentView)
            make.left.equalTo(self.contentView).offset(frameGap)
        }
        

        
    }
    
    /**
    设置标签视图个数
    
    - parameter viewNum:   个数
    - parameter indexPath: 索引
    */
    func setTagViewNum(viewNum: Int, indexPath: NSIndexPath) {
        curIndexPath = indexPath
        tagViewNum = viewNum
        defineTagView(indexPath)
    }
    
    func deleteCellView() {
        
        for view in cellTagViewList {
            view.removeFromSuperview()
        }
        
    }
    
    func addCellTabView(view: UIView) {
        
        self.contentView.addSubview(view)
        
        view.snp_makeConstraints { (make) -> Void in
            make.top.bottom.right.equalTo(self.contentView).offset(frameGap)
            make.left.equalTo(classImgView.snp_right).offset(gap)
        }
        
        cellTagViewList.append(view)
    }
    
    /**
    定义标签视图布局
    */
    func defineTagView(indexPath: NSIndexPath) {
        
        var key = "\(indexPath.section)-\(indexPath.row)"
        
        deleteCellView()
        
        if let tagViews = cellTagViewCache.objectForKey(key) as? UIView {
            
            addCellTabView(tagViews)
            return
        }
        
        let tagViews = UIView()
        addCellTabView(tagViews)
        
        
        for index in 0 ..< tagViewNum {
            
            let tagView = tagViewDelegate?.createTagView(index, indexPath: indexPath)
            
            tagViews.addSubview(tagView!)
            
            if tagView == nil {
                continue
            }
            
            tagView!.snp_makeConstraints{ (make) -> Void in
                
                make.size.equalTo(CGSize(width: 80, height: 40))
                
                if index < 2 {
                    // 第一行的布局
                    make.top.equalTo(tagViews)
                } else {
                    make.top.equalTo(tagViews).offset(CGFloat((index/2) * 40))
                }
                
                if index % 2 == 0 {
                    // 第一列的布局
                    make.left.equalTo(tagViews)
                } else {
                    make.left.equalTo(tagViews).offset(80 + gap)
                }
            }
            
            // 分割线布局
            if index % 2 == 0 && index < tagViewNum - 1 {
                
                var splitLine = UIView()
                tagViews.addSubview(splitLine)
                
                splitLine.backgroundColor = UIColor(hexString: splitLineColor)
                splitLine.snp_makeConstraints{ make  in
                    
                    make.size.equalTo(CGSize(width: 0.3, height: 14))
                    make.centerY.equalTo(tagView!)
                    make.left.equalTo(tagView!.snp_right).offset((gap - 0.3) / 2)
                    
                }
            }
        }
        
        cellTagViewCache.setObject(tagViews, forKey: key)
        
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        
        let defaultHeight: CGFloat = 128
        var defaultSize = CGSizeMake(Common.screenWidth, defaultHeight)
        
        if tagViewNum < 4 {
            return defaultSize
        }
        
        let rowNum = (tagViewNum / 2) + (tagViewNum % 2)
        
        return CGSizeMake(Common.screenWidth, CGFloat(rowNum * 40 + 24 * 2))
        
    }

}

protocol ClassificationCellProtocol {
    
   
    /**
    创建标签视图
    
    - parameter tagIndex:  视图索引
    - parameter indexPath: cell 索引
    
    - returns: 标签视图
    */
    func createTagView(tagIndex: Int, indexPath: NSIndexPath) -> ClassTagView
    
}
