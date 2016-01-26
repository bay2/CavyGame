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
//    var cellTagViewCache = NSCache()
    
    var tagRowNum: Int {
        get {
            return ((tagViewNum / columnNum) + (tagViewNum % columnNum))
        }
    }
    
    var tagRowGap: CGFloat {
        
        get  {
            if isIPhone() {
                return 0
            } else {
                return 20
            }
        }
    }
    
    private var defaultCellHeight: Float {
        if isIPhone() {
            return 128
        } else {
            return 144
        }
    }
    
    private var tagViewSize: CGSize {
        
        if isIPhone() {
            return CGSizeMake(80, 40)
        } else {
            return CGSizeMake(100, 40)
        }
        
    }
    
    // 分类图片大小
    private var classImgViewSize: CGSize {
        if isIPhone() {
            return CGSizeMake(80, 80)
        } else {
            return CGSizeMake(92, 92)
        }
    }
    
    var classImgUrl: String = "" {
        
        didSet {
            classImgView.sd_setImageWithURL(NSURL(string: classImgUrl), placeholderImage: UIImage(named: "icon_game"))
            classImgView.layer.masksToBounds = true
            classImgView.layer.cornerRadius = Common.iconCornerRadius
        }
    }
    
    // 默认标签数
    var defaultTagNum: Int {
        
        get {
            if isIPhone() {
                return 4
            } else {
                return 16
            }
        }
        
    }
    
    // 间隙
    var gap : Float {
        
        get {
            return Float((Common.screenWidth - (classImgViewSize.width + (frameGap * 2) + (CGFloat(columnNum) * tagViewSize.width))) / CGFloat(columnNum))
        }
    }
    
    // 列数
    var columnNum: Int {
        
        get {
            if isIPhone() {
                return 2
            } else {
                return 4
            }
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
        
        self.contentView.addSubview(classImgView)
        
        
    }
    
    /**
    定义子视图布局
    */
    func defineSubvieLayer() {
        
        classImgView.snp_makeConstraints { (make) -> Void in
            make.size.equalTo(classImgViewSize)
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
    
    /**
    删除标签大视图
    */
    func deleteCellView() {
        
        for view in cellTagViewList {
            view.removeFromSuperview()
        }
        
    }
    
    /**
    添加标签大视图
    
    - parameter view: 视图
    */
    func addCellTabView(view: UIView) {
        
        self.contentView.addSubview(view)
        
        view.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(self.contentView).offset(frameGap)
            make.bottom.right.equalTo(self.contentView).offset(-frameGap)
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
        
//        // 读取视图缓存
//        if let tagViews = cellTagViewCache.objectForKey(key) as? UIView {
//            
//            addCellTabView(tagViews)
//            return
//        }
        
        let tagViews = UIView()
        addCellTabView(tagViews)
        
        for index in 0 ..< tagViewNum {
            
            let tagView = tagViewDelegate?.createTagView(index, indexPath: indexPath)
            
            tagViews.addSubview(tagView!)
            
            if tagView == nil {
                continue
            }
            
            tagView!.snp_makeConstraints{ (make) -> Void in
                
                make.size.equalTo(tagViewSize)
                
                var curColumnIndex = index % columnNum
                
                if curColumnIndex == 0 {
                    // 第一列的布局
                    make.left.equalTo(tagViews)
                } else {
                    make.left.equalTo(tagViews).offset((CGFloat(gap) + tagViewSize.width) * CGFloat(curColumnIndex))
                }
                
                // pad 一行的情况居中对齐
                if !isIPhone() && tagViewNum <= columnNum {
                    make.centerY.equalTo(tagViews)
                    return
                }
                
                if index < columnNum {
                    // 第一行的布局
                    make.top.equalTo(tagViews)
                } else {
                    make.top.equalTo(tagViews).offset(CGFloat(index / columnNum) * (tagViewSize.height + tagRowGap))
                }
            }
            
            // 分割线布局
            if index % columnNum == 0 && index < tagViewNum - 1 {
                
                var splitLine = UIView()
                tagViews.addSubview(splitLine)
                
                splitLine.backgroundColor = UIColor(hexString: splitLineColor)
                splitLine.snp_makeConstraints{ make  in
                    
                    make.size.equalTo(CGSize(width: 0.3, height: 14))
                    make.centerY.equalTo(tagView!)
                    make.left.equalTo(tagView!.snp_right).offset((gap - 0.3) / Float(columnNum))
                    
                }
            }
        }
        
//        // 缓存视图
//        cellTagViewCache.setObject(tagViews, forKey: key)
        
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        
        var defaultSize = CGSizeMake(Common.screenWidth, CGFloat(defaultCellHeight))
        
        if tagViewNum < defaultTagNum {
            return defaultSize
        }
        
        return CGSizeMake(Common.screenWidth, CGFloat(tagRowNum) * tagViewSize.height + frameGap * 2)
        
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
