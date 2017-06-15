//
//  DWDChatPreView.h
//  EduChat
//
//  Created by Superman on 16/9/1.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDImageChatMsg;
@interface DWDChatPreView : UICollectionView

+ (instancetype)showPreViewWithImageMsgs:(NSArray *)imageMsgs tapIndex:(NSUInteger)index inView:(UIView *)view;

@end
