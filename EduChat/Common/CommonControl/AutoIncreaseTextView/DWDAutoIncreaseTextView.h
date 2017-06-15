//
//  DWDAutoIncreaseTextView.h
//  EduChat
//
//  Created by KKK on 16/6/3.
//  Copyright © 2016年 dwd. All rights reserved.
//

/**
 0.自增高textview,最大高度默认150(pm没给,给了直接改)
 1.表情按钮可切换表情键盘
 
 
 自增高textView带表情带表情键盘,基本逻辑已经处理
 只需设置代理,处理textView位置等即可使用
 只有一个结束编辑的回调,returnKey类型是"完成",如果没有任何字符点击完成只会推出键盘不会调用代理
 
 */

#import <UIKit/UIKit.h>
#import <YYText.h>
@class DWDAutoIncreaseTextView;

@protocol DWDAutoIncreaseTextViewDelegate <NSObject>
@optional
/**
 完成输入,无需resign first responder
 textView的状态记录,对结果进行处理
 */
- (void)autoIncreaseTextViewDidEndEditing:(DWDAutoIncreaseTextView *)textView;
@end

@interface DWDAutoIncreaseTextView : UIView

/**
 textView 获取属性文字等
 */
@property (nonatomic, weak) YYTextView *textView;

/**
 用户自定义内容,配合type获取不同的附加内容
 */
@property (nonatomic, strong) NSMutableDictionary *userInfo;

/**
 自定义当前输入的状态类型
 type配合userInfo,根据不同的type获取不同的内容
 */
@property (nonatomic, copy) NSString *type;

@property (nonatomic, weak) id<DWDAutoIncreaseTextViewDelegate> delegate;
@end
