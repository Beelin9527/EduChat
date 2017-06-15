//
//  DWDSendVerifyView.h
//  EduChat
//
//  Created by Gatlin on 15/12/25.
//  Copyright © 2015年 dwd. All rights reserved.
//  发送验证码  view  高度为250

#import <UIKit/UIKit.h>

@class DWDSendVerifyView;
@protocol DWDSendVerifyViewDelegate <NSObject>
@optional
- (void)sendVerifyViewDidSelectNextButton:(DWDSendVerifyView *)sendVerifyView;

@end
@interface DWDSendVerifyView : UIView
@property (weak, nonatomic) IBOutlet UILabel *labIntrol;
@property (weak, nonatomic) IBOutlet UITextField *tfPhone;
@property (copy, nonatomic) NSString *showPhone;   //显示带*号的  如132****8866
@property (getter=isAutosend, nonatomic) BOOL autoSend;

@property (nonatomic,weak) id<DWDSendVerifyViewDelegate> delegate;

+(instancetype)sendVerifyView;
@end
