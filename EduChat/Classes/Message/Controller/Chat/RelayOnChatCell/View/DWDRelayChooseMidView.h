//
//  DWDRelayChooseMidView.h
//  EduChat
//
//  Created by Superman on 16/9/7.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDRelayChooseMidView;

@protocol DWDRelayChooseMidViewDelegate <NSObject>
@required
- (void)tapMidView:(DWDRelayChooseMidView *)midView;
@end

@interface DWDRelayChooseMidView : UIView

@property (nonatomic , weak) UILabel *label;
@property (nonatomic , weak) id<DWDRelayChooseMidViewDelegate> delegate;

@end
