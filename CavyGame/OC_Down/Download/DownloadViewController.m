//
//  DownloadViewController.m
//  CavyGame
//
//  Created by longjining on 15/7/23.
//  Copyright (c) 2015年 York. All rights reserved.
//

#import "DownloadViewController.h"
#import "DownloadItem.h"
#import "DownloadCell.h"
#import "DownloadManager.h"
#import "Constants.h"
#import "EUtils.h"
#import "SqliteManager.h"

@interface DownloadViewController ()
{
    int _numberOfSections;
}
@end

@implementation DownloadViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = localizedString(@"download_title");

    _emptydownLb.font =  [UIFont fontWithName:@"Helvetica" size:16];
    [_emptydownLb setText:localizedString(@"downlist_empty")];
    
    [_emptydownLb setTextAlignment:NSTextAlignmentCenter];
    
    //cell分割线左移动
//    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
//    {
//        self.downloadTable.layoutMargins = UIEdgeInsetsZero;
//    }
//    [self.downloadTable setSeparatorInset:UIEdgeInsetsZero];
    self.downloadTable.backgroundColor = colorWithHexStr(@"#eeeeee");
    self.downloadTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.downloadTable.tableFooterView = [[UIView alloc] init];
    
    
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(doBack:)];
    backItem.imageInsets =  UIEdgeInsetsMake(0, -5, 0, -5);
    self.navigationItem.leftBarButtonItem = backItem;
    
    [self.downloadTable reloadData];
    self.downloadTable.sectionFooterHeight=0;
    [self showEmptyLable];
}

-(void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)showEmptyLable{
    
    if ([DownloadManager getInstance].items.count == 0 && [DownloadManager getInstance].finishedItems.count == 0) {
        _emptydownLb.hidden = NO;
    }else{
        _emptydownLb.hidden = YES;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated
{
    [DownloadManager getInstance].tableView = _downloadTable;
}

-(void)viewWillDisappear:(BOOL)animated
{
    [_downloadTable removeFromSuperview];
    [DownloadManager getInstance].tableView  = nil;
    
     for (DownloadItem *it in [DownloadManager getInstance].items){
         
         it.delegate = nil;
     }

}


#pragma mark - TableView DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    int sections = 0;
    
    if ([DownloadManager getInstance].items.count > 0) {
        sections += 1;
    }
    
    if ([DownloadManager getInstance].finishedItems.count > 0) {
        sections += 1;
    }
    _numberOfSections = sections;
    
    return sections;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    
//    return HEIGHTHEADER_INSECTION;
//}

/**
 *  修改cell高度
 *
 *  @param tableView <#tableView description#>
 *  @param indexPath <#indexPath description#>
 *
 *  @return 返回cell高度
 */
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat height = size.height;
    
    if (height == 568.0) {
        if (indexPath.section == 0 && indexPath.row == 0){
            return IOS5_CELL_HIGHT - 2;
        }
        return IOS5_CELL_HIGHT;
    }
    // 高度不一样是因为开始的y不一样，一个为7，一个为9
    if (indexPath.section == 0 && indexPath.row == 0){
        return 106;
    }

    return 108;
    //return download_cell_height/2;
}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView* myView = [[UIView alloc] initWithFrame:CGRectMake(10, 0, CAG_MainScreenWidth, HEIGHTHEADER_INSECTION)];
//    myView.backgroundColor = colorWithHexStr(@"#d9d9d9");
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, CAG_MainScreenWidth,HEIGHTHEADER_INSECTION)];
//    titleLabel.textColor=[UIColor blackColor];
//    titleLabel.backgroundColor = colorWithHexStr(@"#d9d9d9");
//    titleLabel.font = [UIFont fontWithName:@"Heiti SC" size:15];
//    
//    if (_numberOfSections == 2) {
//        if(section ==0)
//        {
//            titleLabel.text=localizedString(@"item_loading");
//        }else{
//            titleLabel.text=localizedString(@"item_loadCompleted");
//        }
//    }else{
//        
//        if ([DownloadManager getInstance].items.count > 0) {
//            titleLabel.text=localizedString(@"item_loading");
//        }else{
//            titleLabel.text=localizedString(@"item_loadCompleted");
//        }
//    }
//    
//    [myView addSubview:titleLabel];
//    return myView;
//}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_numberOfSections == 2) {
        if(section ==0)
        {
            return [[DownloadManager getInstance].items count];
        }else{
            return [[DownloadManager getInstance].finishedItems count];
        }
    }else{
        if ([DownloadManager getInstance].items.count > 0) {
            return [[DownloadManager getInstance].items count];
        }else{
            return [[DownloadManager getInstance].finishedItems count];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"downloadListCell";
    DownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if(cell==nil){
        cell = [[DownloadCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        
//        //cell分割线左移动
//        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
//        {
//            cell.layoutMargins = UIEdgeInsetsZero;
//        }
    }
    
//    if (indexPath.section == 0 && indexPath.row == 0){
//        cell.baskView.frame = CGRectMake(0, 7, CAG_MainScreenWidth, 98);
//    }else{
//        cell.baskView.frame = CGRectMake(0, 9, CAG_MainScreenWidth, 98);
//    }
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat height = size.height;
    
    if (height == 568.0) {
        
        if (indexPath.section == 0 && indexPath.row == 0){
            cell.baskView.frame = CGRectMake(0, 7, CAG_MainScreenWidth, 83.5);
        }else{
            cell.baskView.frame = CGRectMake(0, 9, CAG_MainScreenWidth, 83.5);
        }
        

    } else {
        
        if (indexPath.section == 0 && indexPath.row == 0){
            cell.baskView.frame = CGRectMake(0, 7, CAG_MainScreenWidth, 98);
        }else{
            cell.baskView.frame = CGRectMake(0, 9, CAG_MainScreenWidth, 98);
        }
    }
    
    DownloadItem *item = nil;
    
    if (_numberOfSections == 2) {
        
        if (indexPath.section ==0) {
            item = (DownloadItem*)[[DownloadManager getInstance].items objectAtIndex:indexPath.row];
        }else{
            item = (DownloadItem*)[[DownloadManager getInstance].finishedItems objectAtIndex:indexPath.row];
        }
    }else{
        if ([DownloadManager getInstance].items.count > 0) {
            item = (DownloadItem*)[[DownloadManager getInstance].items objectAtIndex:indexPath.row];
        }else{
            item = (DownloadItem*)[[DownloadManager getInstance].finishedItems objectAtIndex:indexPath.row];
        }
    }
    
    [cell setDownloadItem:item];
    item.delegate = cell;
    [cell updateView];
    
    return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath      //当在Cell上滑动时会调用此函数

{
    return  UITableViewCellEditingStyleDelete;
    
}

-(NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexpath{
    
    if (!IS_IOS8) {
        return @"       ";
    }
    // 把文字加长  为了使cell左移更多 以便把icon全部隐藏
    NSString* deleteText = localizedString(@"deleteText");
    
    if (deleteText.length <= 4) {
        
        return [[NSString alloc]initWithFormat:@" %@  ", deleteText];
    }else{
        return [[NSString alloc]initWithFormat:@" %@ ", deleteText];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        DownloadItem *it=nil;
        if (_numberOfSections == 2) {
            
            if (indexPath.section ==0) {
                it = [[DownloadManager getInstance].items objectAtIndex:indexPath.row];
                it.downloadStatus = CAGDownloadDeleting;
                [it.operation cancel];
                [[DownloadManager getInstance].items removeObjectAtIndex:indexPath.row];
            }else{
                it = [[DownloadManager getInstance].finishedItems objectAtIndex:indexPath.row];
                it.downloadStatus = CAGDownloadDeleting;
                [[DownloadManager getInstance].finishedItems removeObjectAtIndex:indexPath.row];
            }
        }else{
            if ([DownloadManager getInstance].items.count > 0) {
                it = [[DownloadManager getInstance].items objectAtIndex:indexPath.row];
                it.downloadStatus = CAGDownloadDeleting;
                [it.operation cancel];
                [[DownloadManager getInstance].items removeObjectAtIndex:indexPath.row];
            }else{
                it = [[DownloadManager getInstance].finishedItems objectAtIndex:indexPath.row];
                it.downloadStatus = CAGDownloadDeleting;
                [[DownloadManager getInstance].finishedItems removeObjectAtIndex:indexPath.row];
            }
        }
                
        NSString *filePath = [NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(),
                              [it.downurl lastPathComponent]];
        NSFileManager *manager = [NSFileManager defaultManager];
        [manager removeItemAtPath:filePath error:nil];
        
        [tableView reloadData];
        
        [[SqliteManager sharedInstance] deleteData:it.gameid];
        
        [self showEmptyLable];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:[NSString stringWithFormat:@"Delete_%@", it.gameid] object:nil];

    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
