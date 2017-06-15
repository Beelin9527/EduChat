//
//  DWDClassChatBottomView.h
//  EduChat
//
//  Created by Superman on 15/11/19.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDChatController;
@class DWDClassMenu;
@class DWDClassModel;
@interface DWDClassChatBottomView : UIImageView

@property (nonatomic , weak) DWDClassMenu *menu;
@property (nonatomic , weak) DWDChatController *conversationVc;
@property (nonatomic, strong) DWDClassModel *myClass;

@property (nonatomic , weak) UIButton *changeBtn;

@end
