//
//  DWDSearchResultViewController.h
//  EduChat
//
//  Created by Gatlin on 16/2/16.
//  Copyright © 2016年 dwd. All rights reserved.
//  搜索结果 ViewController

#import <UIKit/UIKit.h>

/** 搜索类型 */
typedef NS_ENUM(NSInteger,DWDSearchType) {
    DWDSearchTypeSession,   //聊天会话搜索
    DWDSearchTypeContact,   //联系人搜索
    DWDSearchTypeGroup,     //群组搜索
    DWDSearchTypeGrade      //班级搜索
};
@interface DWDSearchResultViewController : UITableViewController
@property (assign, nonatomic) DWDSearchType searchType;
@property (strong, nonatomic) NSArray *dataSource;
@property (strong, nonatomic) UISearchBar *searchBar;
@end
