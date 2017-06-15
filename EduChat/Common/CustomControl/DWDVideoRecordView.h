//
//  DWDVideoRecordView.h
//  EduChat
//
//  Created by apple on 16/5/5.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDVideoRecordView : UIView

//DWDSingletonH(VideoRecordView);

@property (nonatomic, copy) void(^completionHandler)(NSString *fileName, UIImage *thumbImage);
@property (nonatomic, copy) void(^dissmisBlock)(void);

- (void)showVideoRecordViewWithCompletionHandler:(void(^)(NSString *fileName, UIImage *thumbImage))handler;
- (void)dismissCamera;

@end
