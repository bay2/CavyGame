//
//  BigImageViewController.swift
//  CavyGame
//
//  Created by xuemincai on 15/8/20.
//  Copyright (c) 2015年 com.lvwenhan. All rights reserved.
//

import UIKit

class BigImageViewController: UIViewController {
    
    var srcollView : UIScrollView?
    var gameImages : Array<GameViewimage>?
    var pageControl = UIPageControl()
    var lastVelocityScrollView = CGPoint(x: 0, y: 0)
    var currentPageIndex = 0
    var numberOfCell = 0
    var cellSize = CGSize()
    var padding : CGFloat = 10

    override func viewDidLoad() {
        super.viewDidLoad()
        
        srcollView = UIScrollView(frame: CGRectMake(0, 0 + 50, self.view.frame.size.width, self.view.frame.size.height))
        
        if (nil != gameImages) {
            
            numberOfCell = gameImages!.count
            
            var startX : CGFloat = 20
            
            for var i = 0; i < gameImages?.count; i++ {
                
                var gameImagesView = UIImageView()
                
                cellSize.width = self.view.frame.size.width - 40
                cellSize.height = self.view.frame.size.height - 90
                
                gameImagesView.frame.size = CGSizeMake(cellSize.width, cellSize.height)
                
                gameImagesView.frame.origin = CGPointMake(startX, 10)
                
                startX = startX + cellSize.width + padding
                
                gameImagesView.sd_setHighlightedImageWithURL(NSURL(string: gameImages![i].bigimage!))
                
                srcollView!.addSubview(gameImagesView)
                
                let heightPageControl = 15
                
                pageControl.frame = CGRectMake(0, srcollView!.frame.size.height - 18, self.view.frame.size.width, CGFloat(heightPageControl))

                pageControl.pageIndicatorTintColor = UIColor.grayColor()
                pageControl.currentPageIndicatorTintColor = UIColor.blueColor()
                pageControl.userInteractionEnabled = false
                pageControl.numberOfPages = gameImages!.count
                pageControl.currentPage = 0
                
                self.view.addSubview(pageControl)
                
            }
            
            srcollView!.contentSize.width =  (cellSize.width +  padding) * CGFloat(numberOfCell)
            srcollView!.showsHorizontalScrollIndicator = false
            srcollView!.showsVerticalScrollIndicator = false
            srcollView!.delegate = self
            
            self.view.addSubview(srcollView!)
            
            scrollToPage(currentPageIndex, animation: false)
            
        }
        
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onClickDone(sender: UIBarButtonItem) {
        
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
}

extension BigImageViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var indexPage = Int(scrollView.contentOffset.x / scrollView.frame.size.width)

    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        
        lastVelocityScrollView = CGPointMake(0, 0)
    }
    
    func scrollViewWillBeginDecelerating(scrollView: UIScrollView) {
        
        scrollView.setContentOffset(scrollView.contentOffset, animated: false)
        var temp = abs(lastVelocityScrollView.x)
        
        if (temp > 0.5) {
            
            // next
            if (lastVelocityScrollView.x > 0.5) {
                
                if currentPageIndex + 1 < numberOfCell {
                    
                    currentPageIndex++
                    
                }
            }
            // prev
            else {
                
                if currentPageIndex - 1 >= 0 {
                    
                    currentPageIndex--
                    
                }
            }
        }
        
        scrollToPage(currentPageIndex, animation: true)
        
    }
    
    func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        lastVelocityScrollView = velocity
        
    }
    
    func scrollToPage(pageNumber : Int, animation : Bool) {
        
        var changeOffset:CGFloat = 0
        
        if (0 != pageNumber) {
            
            changeOffset = cellSize.width * CGFloat(pageNumber) + padding *  CGFloat(pageNumber)
            
            if (changeOffset >= self.srcollView!.contentSize.width) {
                return
            }
        }
        
        if (changeOffset == self.srcollView!.contentOffset.x) {
            return
        }
        
        if animation {
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.srcollView!.contentOffset = CGPointMake(changeOffset, 0)
            })
            
        } else {
            
            self.srcollView!.contentOffset = CGPointMake(changeOffset, 0)
        }
        
        pageControl.currentPage = pageNumber
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if !decelerate {
            scrollToPage(currentPageIndex, animation: true)
        }
    }

}
