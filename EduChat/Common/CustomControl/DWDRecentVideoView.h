//
//  DWDRecentVideoView.h
//  EduChat
//
//  Created by apple on 16/5/11.
//  Copyright © 2016年 dwd. All rights reserved.
//  最近视频

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger ,DWDRecentVideoViewHandleType) {
    DWDRecentVideoViewHandleTypeDismiss,
    DWDRecentVideoViewHandleTypeSendVideo,
    DWDRecentVideoViewHandleTypeTransfrom
};

typedef NS_ENUM(NSInteger, DWDRecentVideoViewStatus) {
    DWDRecentVideoViewStatusNomal,
    DWDRecentVideoViewStatusEdit,
    DWDRecentVideoViewStatusSend
};

typedef void(^recentVideoViewBlock)(DWDRecentVideoViewHandleType handleType, NSString *mp4FileName, UIImage *thumbImage);


@interface DWDRecentVideoView : UIView

@property (nonatomic, strong)recentVideoViewBlock block;

- (void)showRecentVideo;

@end
