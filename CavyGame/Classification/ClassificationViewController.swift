//
//  ClassificationViewController.swift
//  
//
//  Created by xuemincai on 16/1/20.
//
//

import UIKit

class ClassificationViewController: UIViewController, ClassificationCellProtocol {

    @IBOutlet weak var classTableView: UITableView!
    var classData: Array<Classification> = Array<Classification>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = UIView()
        view.backgroundColor = UIColor.clearColor()
        
        classTableView.tableFooterView = view
        classTableView.tableHeaderView = view
        MJRefreshAdapter.setupRefreshHeader(classTableView, target: self, action: "loadData")
        loadData()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /**
    加载数据
    */
    func loadData() {
        
        HttpHelper<ClassificationMsg>.getClassificationInfo { (result) -> () in
            
            if result == nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    FVCustomAlertView.shareInstance.showDefaultCustomAlertOnView(self.view, withTitle: Common.LocalizedStringForKey("net_err"), delayTime: Common.alertDelayTime)
                    self.classTableView.mj_header.endRefreshing()
                })
                return
            }
            
            self.classData = result!.data
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.classTableView.mj_header.endRefreshing()
                self.classTableView.reloadData()
            })
            
        }
        
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
}

// MARK: - tableView 代理
extension ClassificationViewController {
    
    /**
    行数
    
    - parameter tableView: table
    - parameter section:   section 索引
    
    - returns: 行数
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
 
    /**
    创建cell
    
    - parameter tableView: table
    - parameter indexPath: 索引
    
    - returns: cell
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("ClassificationCell", forIndexPath: indexPath) as! ClassificationTableViewCell
        
        cell.tagViewDelegate = self
        
        cell.setTagViewNum(classData[indexPath.section].tagArray.count, indexPath: indexPath)
        cell.classImgUrl = classData[indexPath.section].class_imgurl!
        
        return cell
    }
    
    /**
    设置cell高度
    
    - parameter tableView: table
    - parameter indexPath: 索引
    
    - returns: 高度
    */
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        return tableView.fd_heightForCellWithIdentifier("ClassificationCell", configuration: { (cell) -> Void in
            
            let classCell = cell as! ClassificationTableViewCell
            classCell.fd_enforceFrameLayout = true
            classCell.tagViewNum = self.classData[indexPath.section].tagArray.count

        })
    }
    
    /**
    设置 Header section高度
    
    - parameter tableView: table
    - parameter section:   section 索引
    
    - returns: 高度
    */
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section != 0 {
            return 8
        }
        
        return 5
    }
    
    
    /**
    设置section个数
    
    - parameter tableView: table
    
    - returns: 个数
    */
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return classData.count
    }
    
    /**
    创建Header
    
    - parameter tableView: table
    - parameter section:   索引
    
    - returns: 视图
    */
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        
        view.backgroundColor = Common.tableBackColor
        
        return view
    }
   
}

// MARK: - 标签视图代理
extension ClassificationViewController {
    
    /**
    创建标签视图
    
    - parameter tagIndex:  标签索引
    - parameter indexPath: cell 索引
    
    - returns: 标签视图
    */
    func createTagView(tagIndex: Int, indexPath: NSIndexPath) -> ClassTagView {
        
        let tagView = ClassTagView()
        
        tagView.userInteractionEnabled = true
        var tapGR = UITapGestureRecognizer(target: self, action: "onClickTagView:")
        
        tagView.tag = classData[indexPath.section].tagArray[tagIndex].tagId!
        tagView.addGestureRecognizer(tapGR)
        
        tagView.tagImgUrl = classData[indexPath.section].tagArray[tagIndex].tagImgUrl!
        tagView.tagTextLab.text = classData[indexPath.section].tagArray[tagIndex].tagName
        tagView.tagTxtLabColor = classData[indexPath.section].tagArray[tagIndex].tagTextColor!
        
        return tagView
        
    }
    
    
    /**
    标签点击事件处理
    
    - parameter sendr: sendr
    */
    func onClickTagView(sendr: UITapGestureRecognizer) {
        
        var tagClassView = ClassAllItemTbVC()
        let tagView = sendr.view! as! ClassTagView
        tagClassView.title = tagView.tagTextLab.text
        
        tagClassView.gameTagID = "\(tagView.tag)"
        self.navigationController?.pushViewController(tagClassView, animated: true)
        
    }
    
    /**
    用于消除Header section 随tableView 移动的黏性
    
    - parameter scrollView: 
    */
    func scrollViewDidScroll(scrollView: UIScrollView) {
        
        var sectionHeaderHeight: CGFloat = 5
        
        if scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0{
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0)
        } else if scrollView.contentOffset.y >= sectionHeaderHeight {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0)
        }
        
    }
    
}
