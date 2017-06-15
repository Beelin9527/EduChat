//
//  DWDVersionUpdateView.h
//  EduChat
//
//  Created by KKK on 16/9/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDVersionUpdateView;
@protocol DWDVersionUpdateViewDelegate <NSObject>

@required
- (void)versionUpdateViewDidClickUpdateButton:(DWDVersionUpdateView *)view;
- (void)versionUpdateView:(DWDVersionUpdateView *)view didClickCancelButtonWithVersion:(NSString *)version;

@end

@interface DWDVersionUpdateView : UIView

@property (nonatomic, weak) id<DWDVersionUpdateViewDelegate> delegate;

- (instancetype)initWithVersion:(NSString *)version
                        content:(NSString *)content
                    forceUpdate:(BOOL)forceUpdate;

- (void)refreshWithVersion:(NSString *)version
                   content:(NSString *)content;

@end
