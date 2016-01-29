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
    
    // 左右边框间距
    var frameGapLeft: CGFloat {
        
        get {
            if isIPhone() {
                if resolution() == .UIDeviceResolution_iPhoneRetina4 {
                    return 20
                } else {
                    return 30
                }
            } else {
                return 45
            }
        }
    }
    
    // 大图标与上下边框间距
    let frameGapTop: CGFloat = 15
    
    var curIndexPath: NSIndexPath = NSIndexPath(forRow: 0, inSection: 0)
    var tagViewNum: Int = 0
    var cellTagViewList: Array<UIView> = Array<UIView>()
    var cellTagView = UIView()
    
    // 这个cell的tag的高度
    var tagViewsHeight: CGFloat {
        get {
            if tagRowNum > 1 {
                return (CGFloat(tagRowNum - 1) * tagRowGap) + (CGFloat(tagRowNum) * tagRowGap)
            }
            
            return 20
        }
    }
    
    // tag 行数
    var tagRowNum: Int {
        get {
            return ((tagViewNum / columnNum) + (tagViewNum % columnNum))
        }
    }
    
    // 每行之间的间隙
    var tagRowGap: CGFloat {
        
        get  {
            return 20
        }
    }
    
    // cell最小高度
    private var defaultCellHeight: Float {
        if isIPhone() {
            if resolution() == .UIDeviceResolution_iPhoneRetina4 {
                return 104
            } else {
                return 120
            }
           
        } else {
            return 150
        }
    }
    
    // tag大小
    private var tagViewSize: CGSize {
        
        if isIPhone() {
            return CGSizeMake(90, 20)
        } else {
            return CGSizeMake(100, 20)
        }
        
    }
    
    // 分类图片大小
    private var classImgViewSize: CGSize {
        if isIPhone() {
           
            if resolution() == .UIDeviceResolution_iPhoneRetina4 {
                return CGSizeMake(72, 72)
            } else {
                return CGSizeMake(90, 90)
            }
            
        } else {
            return CGSizeMake(120, 120)
        }
    }
    
    // 分类大图标url
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
            return Float((Common.screenWidth - (classImgViewSize.width + (frameGapLeft * 2) + (CGFloat(columnNum) * tagViewSize.width))) / CGFloat(columnNum))
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
            make.left.equalTo(self.contentView).offset(frameGapLeft)
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
            make.centerY.equalTo(self.contentView)
            make.height.equalTo(tagViewsHeight)
            make.right.equalTo(self.contentView).offset(-gap)
            make.left.equalTo(classImgView.snp_right).offset(gap)
        }
        
        cellTagViewList.append(view)
    }
    
    /**
    定义标签视图布局
    */
    func defineTagView(indexPath: NSIndexPath) {
        
//        var key = "\(indexPath.section)-\(indexPath.row)"
        
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
                if !isIPhone() && tagRowNum == 1 {
                    make.centerY.equalTo(tagViews)
                } else {
                    
                    if index < columnNum {
                        // 第一行的布局
                        make.top.equalTo(tagViews)
                    } else {
                        make.top.equalTo(tagViews).offset(CGFloat(index / columnNum) * (tagViewSize.height + tagRowGap))
                    }
                }
            }
            
            // 分割线布局
            if index < tagViewNum - 1 && index % columnNum != columnNum - 1 {
                
                var splitLine = UIView()
                tagViews.addSubview(splitLine)
                
                splitLine.backgroundColor = UIColor(hexString: splitLineColor)
                splitLine.snp_makeConstraints{ make  in
                    
                    make.size.equalTo(CGSize(width: 0.3, height: 14))
                    make.centerY.equalTo(tagView!)
                    var offsetVelue = Int((gap - 0.3) / Float(columnNum))

                    make.left.lessThanOrEqualTo(tagView!.snp_right).offset(offsetVelue)
                    
                }
            }
        }
        
//        // 缓存视图
//        cellTagViewCache.setObject(tagViews, forKey: key)
        
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        
        var defaultSize = CGSizeMake(Common.screenWidth, CGFloat(defaultCellHeight))
        
        if tagViewNum <= defaultTagNum {
            return defaultSize
        }
        
        return CGSizeMake(Common.screenWidth, CGFloat(tagRowNum) * tagViewSize.height + frameGapTop * 2 + CGFloat(tagRowNum - 1) * tagRowGap)
        
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
