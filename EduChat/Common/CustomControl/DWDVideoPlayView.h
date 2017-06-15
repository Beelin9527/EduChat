//
//  DWDVideoPlayView.h
//  EduChat
//
//  Created by apple on 16/5/6.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDVideoPlayView : UIView

@property (nonatomic, strong) NSURL *videoUrl;
@property (nonatomic, assign) BOOL forbidVolume;
@property (nonatomic, copy) void(^handleTapBlock)(void);

- (void)play;
- (void)stop;
- (void)pause;

@end
