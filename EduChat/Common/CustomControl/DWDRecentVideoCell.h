//
//  DWDRecentVideoCell.h
//  EduChat
//
//  Created by apple on 16/5/11.
//  Copyright © 2016年 dwd. All rights reserved.
//  最近视频

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const NOTI_EDITRECENTVIDEO;
UIKIT_EXTERN NSString *const NOTI_CANCELEDITRECENTVIDEO;

@interface DWDRecentVideoCell : UICollectionViewCell

@property (nonatomic, weak) UIImageView *thumbImageV;
@property (nonatomic, assign) BOOL isLastCell;
@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, copy) void(^deleteBlock)(NSURL *videoUrl);

- (void)thumbImgVScaleAnimate;

@end
