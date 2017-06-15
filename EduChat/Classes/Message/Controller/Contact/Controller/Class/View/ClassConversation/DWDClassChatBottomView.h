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
@interface DWDClassChatBottomView : UIImageView

@property (nonatomic , weak) DWDClassMenu *menu;
@property (nonatomic , strong) DWDChatController *conversationVc;

@end
