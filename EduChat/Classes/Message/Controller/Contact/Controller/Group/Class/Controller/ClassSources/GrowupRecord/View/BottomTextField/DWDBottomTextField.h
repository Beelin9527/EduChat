//
//  DWDBottomTextField.h
//  EduChat
//
//  Created by Superman on 16/1/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWDGrowUpRecordModel.h"

@class DWDBottomTextField;
@protocol DWDBottomTextFieldDelegate <NSObject>

@optional

/**
 *  评论输入完毕回调发送请求
 */
- (void)bottomTextFieldDidEndEditing:(DWDBottomTextField *)bottomTextField;

/**
 *  点击表情按钮回调
 */
- (void)bottomTextFieldDidClickEmotionButton:(DWDBottomTextField *)bottomTextField;

@end

@interface DWDBottomTextField : UIView
@property (weak, nonatomic) IBOutlet UITextField *Field;

@property (weak, nonatomic) IBOutlet UIButton *emotionBtn;

#warning Not Use
@property (nonatomic, strong) DWDGrowUpRecordModel *recordModel;

@property (nonatomic, copy) NSString *type;
@property (nonatomic, strong) NSNumber *forCustId;
@property (nonatomic, copy) NSString *forNickname;

@property (nonatomic, weak) id<DWDBottomTextFieldDelegate> delegate;


@end
