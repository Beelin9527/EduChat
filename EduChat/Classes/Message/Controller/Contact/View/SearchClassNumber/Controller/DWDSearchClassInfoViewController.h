//
//  DWDSearchClassInfoViewController.h
//  EduChat
//
//  Created by Superman on 16/2/22.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, DWDSacnClassResultType) {
    DWDSacnClassResultTypeApply,DWDSacnClassResultTypeJionChat
};
@class DWDClassModel;
@interface DWDSearchClassInfoViewController : UITableViewController
@property (nonatomic , strong) DWDClassModel *classModel;
@property (getter=isHideButton ,nonatomic) BOOL hideButton;
@property (nonatomic , assign) DWDSacnClassResultType type;
@end
