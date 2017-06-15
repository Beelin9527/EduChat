//
//  DWDClassMenu.h
//  EduChat
//
//  Created by Superman on 15/11/23.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDChatController;
@class DWDClassModel;
@interface DWDClassMenu : UIView

@property (nonatomic , strong) NSArray *titles;
@property (nonatomic , strong) UIButton *btn;
@property (nonatomic , weak) DWDChatController *conversationVc;

@property (nonatomic, strong) DWDClassModel *myClass;

- (void)showFormView:(CGRect)fromRect;
- (void)dismiss;
@end
