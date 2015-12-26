//
//  GameImageTableViewCell.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/18.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class GameImageTableViewCell: UITableViewCell {

    @IBOutlet weak var gameImage: UIImageView!
    var oldframe : CGRect?
    var gameImagesArray : Array<GameViewimage>?
    var gameImagesUrl : Array<String>?
    @IBOutlet weak var cellTitleLabel: UILabel!
    
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        cellTitleLabel.text = Common.LocalizedStringForKey("appinfo_title2")
        gameImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "onClickImage:"))
        gameImage.userInteractionEnabled = true
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func onClickImage(tap : UITapGestureRecognizer) {
        
        showImage(gameImage)
        
    }
    
    
    /**
    全屏显示图片
    
    :param: avatarImageView
    */
    func showImage(avatarImageView : UIImageView) {
        
        var backgroundView : UIView?
        var image = avatarImageView.image
        var window = UIApplication.sharedApplication().keyWindow
        backgroundView = UIView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        oldframe = avatarImageView.convertRect(avatarImageView.bounds, toView: window)
        
        backgroundView!.backgroundColor = UIColor.blackColor()
        backgroundView!.alpha = 0
        var imageView = UIImageView(frame: oldframe!)
        imageView.image = image
        imageView.tag = 1
        backgroundView!.addSubview(imageView)
        window!.addSubview(backgroundView!)
        
        var tap = UITapGestureRecognizer(target: self, action: "hideImage:")
        backgroundView!.addGestureRecognizer(tap)
        
        if image != nil {
            
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                
                imageView.frame = CGRectMake(0, (UIScreen.mainScreen().bounds.size.height - avatarImageView.frame.size.height * UIScreen.mainScreen().bounds.size.width / avatarImageView.frame.size.width)/2, UIScreen.mainScreen().bounds.size.width, avatarImageView.frame.size.height * UIScreen.mainScreen().bounds.size.width / avatarImageView.frame.size.width)
                
                backgroundView!.alpha = 1
                
            })
        }
    }
    
    func showImageArray(avatarImageView : UIImageView) {
        
        var backgroundView : UIScrollView?
        var image = avatarImageView.image
        var window = UIApplication.sharedApplication().keyWindow
        backgroundView = UIScrollView(frame: CGRectMake(0, 0, UIScreen.mainScreen().bounds.size.width, UIScreen.mainScreen().bounds.size.height))
        oldframe = avatarImageView.convertRect(avatarImageView.bounds, toView: window)
        
        backgroundView!.backgroundColor = UIColor.blackColor()
        backgroundView!.alpha = 0
        var imageView = UIImageView(frame: oldframe!)
        imageView.frame.origin.x = UIScreen.mainScreen().bounds.size.width * CGFloat(avatarImageView.tag)
        imageView.image = image
        imageView.tag = avatarImageView.tag
        //backgroundView!.addSubview(imageView)
        
        
//        for var i = 0; i < gameImagesArray!.count; i++ {
//            
//            var gameImage = UIImageView(frame: oldframe!)
//            
//            imageView.frame.origin.x = UIScreen.mainScreen().bounds.size.width * CGFloat(i)
//            
//            gameImage.setWebImage(gameImagesArray![i].bigimage!, network: false)
//            gameImage.tag = i
//            
//            backgroundView!.addSubview(gameImage)
//        }
        
        window!.addSubview(backgroundView!)
        
        var tap = UITapGestureRecognizer(target: self, action: "hideImage:")
        backgroundView!.addGestureRecognizer(tap)
        
        backgroundView?.pagingEnabled = true
        backgroundView!.showsHorizontalScrollIndicator = false
        backgroundView!.showsVerticalScrollIndicator = false
        backgroundView!.contentSize = CGSizeMake(UIScreen.mainScreen().bounds.size.width * CGFloat(gameImagesArray!.count), imageView.frame.height)
        
  
            for var i = 0; i < gameImagesArray!.count; i++ {
                
                var gameImage = UIImageView(frame: oldframe!)
                
                imageView.frame.origin.x = UIScreen.mainScreen().bounds.size.width * CGFloat(i)
                
                //gameImage.setWebImage(gameImagesArray![i].bigimage!, network: false)
                
               // gameImage.sd_setImageWithURL(NSURL(string: gameImagesArray![i].bigimage!), options: SDWebImageOptions.allZeros, progress: nil, completed: nil)
                
                gameImage.sd_setImageWithURL(NSURL(string: gameImagesArray![i].bigimage!), usingProgressView: nil)
                gameImage.tag = i
                
                backgroundView!.addSubview(gameImage)
                
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    
                    gameImage.frame = CGRectMake(UIScreen.mainScreen().bounds.size.width * CGFloat(gameImage.tag), (UIScreen.mainScreen().bounds.size.height - avatarImageView.frame.size.height * UIScreen.mainScreen().bounds.size.width / avatarImageView.frame.size.width)/2, UIScreen.mainScreen().bounds.size.width, avatarImageView.frame.size.height * UIScreen.mainScreen().bounds.size.width / avatarImageView.frame.size.width)
                    
                    backgroundView!.alpha = 1
                    
                })
            }

        
        backgroundView?.contentOffset.x = UIScreen.mainScreen().bounds.size.width * CGFloat(avatarImageView.tag)
        
    }

    /**
    隐藏全屏图片
    
    :param: tap
    */
    func hideImage(tap : UITapGestureRecognizer) {
        
        var backgroundView = tap.view
        
        var imageView = tap.view?.viewWithTag(1) as! UIImageView
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            imageView.frame = self.oldframe!
            backgroundView?.alpha = 0
            
            }) { (finished) -> Void in
                
                backgroundView?.removeFromSuperview()
                
        }
    }
    
    /**
    添加图片组
    
    :param: gameImages
    */
    func addScrollImageView(gameImages : Array<GameViewimage>) {
        
        gameImage.hidden = true
        
        gameImagesArray = gameImages
        
        var scrollView = UIScrollView(frame: CGRectMake(15, 47, self.frame.width, 210))
        scrollView.backgroundColor = UIColor.whiteColor()
        
        for var i = 0; i < gameImages.count; i++ {
            
            var gameImageBtn = UIButton()
            
            gameImageBtn.frame.origin = CGPointMake((140 + 15) * CGFloat(i), 0)
            gameImageBtn.frame.size = CGSizeMake(140, 210)
            
//            gameImageBtn.setWebImage(gameImages[i].bigimage!, network: false, loadFinish: { () -> () in
//                
//            })
            
            gameImageBtn.sd_setImageWithURL(NSURL(string: gameImages[i].bigimage!), forState: UIControlState.allZeros, completed: { (image, error, imageCacheType, url) -> Void in
                
                if error == nil {
                    gameImageBtn.addTarget(self, action: "onClickImageBtn:", forControlEvents: UIControlEvents.TouchUpInside)

                }
                
            })
            
            gameImagesUrl?.append(gameImages[i].bigimage!)
            
            gameImageBtn.imageView?.tag = i
            
            
            
            scrollView.addSubview(gameImageBtn)
        }
        
        scrollView.contentSize = CGSizeMake(155 * CGFloat(gameImages.count) + 15, 210)
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        self.addSubview(scrollView)
    }
    
    /**
    点击图片
    
    :param: sender
    */
    func onClickImageBtn(sender: UIButton) {
        
        
//        var bigImageVc = Common.getViewControllerWithIdentifier("AppInfo", identifier: "BigImageViewController") as! BigImageViewController
//        
//        bigImageVc.gameImages = gameImagesArray
//        
//        bigImageVc.currentPageIndex = sender.tag
//        
//        Common.rootViewController.homeViewController.navigationController?.presentViewController(bigImageVc, animated: true, completion: nil)
        
        showImageArray(sender.imageView!)
//        
        
    }
    
}
