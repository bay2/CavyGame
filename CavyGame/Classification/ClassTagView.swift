//
//  ClassTagView.swift
//  
//
//  Created by xuemincai on 16/1/20.
//
//

import UIKit

class ClassTagView: UIView {

    // 大小定义
    private let tagImgSize = CGSizeMake(16, 16)
   

    
    var tagImgUrl = "" {
        
        didSet {
            tagImgView.sd_setImageWithURL(NSURL(string: tagImgUrl))
        }
    }
    
    var tagImgView = UIImageView(color: UIColor(hexString: "#d5d5d5")!)
    var tagTextLab = UILabel()
    
    // 颜色定义
    private let tagImgBackgroundColor = "#d5d5d5"
    var tagTxtLabColor: String = "#868686" {
        
        didSet {
            tagTextLab.textColor = UIColor(hexString: tagTxtLabColor)
        }
    }
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        defineSubview()
        defineSubviewLayout()
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /**
    定义子视图
    */
    func defineSubview() {
        
        tagTextLab.textColor = UIColor(hexString: tagTxtLabColor)
        tagTextLab.numberOfLines = 1
        tagTextLab.font = UIFont.systemFontOfSize(15)
        self.addSubview(tagImgView)
        self.addSubview(tagTextLab)
        
    }
    
    /**
    定义子视图布局
    */
    func defineSubviewLayout() {
        
        tagImgView.snp_makeConstraints { (make) -> Void in
            make.centerY.left.equalTo(self)
            make.size.equalTo(tagImgSize)
        }
        
        tagTextLab.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(tagImgView.snp_right).offset(5)
            make.top.bottom.right.equalTo(self)
        }

    }

}
