//
//  DWDClassChatBottomToolBar.h
//  EduChat
//
//  Created by Superman on 15/11/19.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWDClassChatBottomToolBarDelegate <NSObject>
@required
- (void)functionBtnClick;

@end

@interface DWDClassChatBottomToolBar : UIView

@property (nonatomic , weak) id<DWDClassChatBottomToolBarDelegate> bottomToolBarDelegate;

@end
