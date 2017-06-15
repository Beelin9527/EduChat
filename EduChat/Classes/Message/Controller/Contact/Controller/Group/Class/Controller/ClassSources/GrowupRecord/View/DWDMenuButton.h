//
//  DWDMenuButton.h
//  EduChat
//
//  Created by Superman on 15/12/30.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDMenuButton;

@protocol DWDMenuButtonDelegate <NSObject>

@required
- (void)menuButtonDidClickZanButton:(DWDMenuButton *)menuBtn;
- (void)menuButtonDidclickCommitButton:(DWDMenuButton *)menuBtn;
@end

@interface DWDMenuButton : UIButton
@property (nonatomic, weak) id<DWDMenuButtonDelegate> delegate;

- (void)menuButtonDidClick;

- (void)menuButtonClick:(DWDMenuButton *)button;


@end
