//
//  Constants.h
//  CavyGame
//
//  Created by York on 7/7/15.
//  Copyright (c) 2015 York. All rights reserved.
//

#ifndef CavyGame_Constants_h
#define CavyGame_Constants_h

#define NavigationBar_HEIGHT 44 // defult 44
#define StatusBar_HEIGHT 20

#define IS_IOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8)

//屏幕大小 bounds Frame
#define CAG_MainScreenFrame [[UIScreen mainScreen] bounds]
//屏幕大小 application Frame
#define CAG_ApplicationFrame [[UIScreen mainScreen] applicationFrame]
//屏幕宽度
#define CAG_MainScreenWidth CAG_MainScreenFrame.size.width
//屏幕高度
#define CAG_MainScreenHeight CAG_MainScreenFrame.size.height

#define CAG_ios7 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7 ? YES : NO)
#define cloneStr(_str) [NSString stringWithFormat:@"%@",_str]
#define localizedString(msg)       NSLocalizedString(msg,@"")
#define colorWithRGB(r,g,b,a) [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:a]
#define color_title_text colorWithRGB(0,0,0,1)
#define color_button_text colorWithRGB(21,125,251,1)
#define color_button_text_disable colorWithRGB(147,147,147,1)
#define color_app_head_title_bg colorWithHexStr(@"#42bcfa")

#define colorWithHexStr(s) [EUtils colorWithHexString:s]
#define color_download_progress_bar colorWithHexStr(@"#a6a6a6")
#define color_download_progress_track colorWithHexStr(@"#e6e6e6")
#define color_download_finshed_label colorWithHexStr(@"#808080")
#define color_download_btn colorWithHexStr(@"#e6e6e6")
#define color_loading colorWithHexStr(@"#92d358")


#define  HOME_PAGE_URL @"http://game.tunshu.com/mobile/appMain"
#define  M_SIZE  1048576

#define download_cell_height  196
#define download_cell_left_x  17
#define download_cell_icon_size  68
#define download_cell_icon_spacing 13
#define download_cell_name_label_height  26
#define download_cell_name_label_font_size  15
#define download_cell_length_label_wight  160
#define download_cell_loadinglength_label_wight  43
#define download_cell_length_label_height  30
#define download_cell_finshed_label_wight 250
#define download_cell_finshed_label_height 30
#define download_cell_length_font_size  10
#define download_cell_margin  5
#define download_cell_download_button_width  77
#define download_cell_download_button_height 32

#define HEIGHTHEADER_INSECTION 18
//54.0/2

#define PX_TO_PT(px) (px*1.0/96)*72


#endif
