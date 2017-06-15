//
//  DWDContactSelectAddViewController.h
//  EduChat
//
//  Created by Gatlin on 15/12/17.
//  Copyright © 2015年 dwd. All rights reserved.
//  通讯录选择添加好友ViewController、创建群、班级

#import <UIKit/UIKit.h>
#import "DWDContactCell.h"
typedef NS_ENUM(NSInteger,DWDSelectContactType) {
    DWDSelectContactTypeAddEntity,
    DWDSelectContactTypeDeleteEntity
};

@protocol DWDContactSelectViewControllerDelegate <NSObject>

@required
- (void)contactSelectViewControllerDidSelectContactsForIds:(NSArray *)contactsIds selectContactType:(DWDSelectContactType)type;

@end






@interface DWDContactSelectViewController : UIViewController<UITableViewDataSource,UITableViewDelegate, DWDContactCellDelegate>

@property (nonatomic, strong) UITableView *tableView;

@property (strong, nonatomic) NSArray *dataSource;                  //数据源
@property (strong, nonatomic) NSMutableDictionary *selectContacts;  //选择人容器
@property (strong, nonatomic) NSArray *contactsGroupData;           //序列化的数据源

@property (assign, nonatomic) DWDSelectContactType type;

@property (weak, nonatomic) id<DWDContactSelectViewControllerDelegate> delegate;

@end
