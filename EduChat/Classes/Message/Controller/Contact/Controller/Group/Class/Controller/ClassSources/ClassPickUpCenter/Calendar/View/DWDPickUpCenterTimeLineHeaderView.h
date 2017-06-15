//
//  DWDPickUpCenterTimeLineHeaderView.h
//  EduChat
//
//  Created by KKK on 16/4/13.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDPickUpCenterTimeLineHeaderView : UIView

- (void)setLabelsTextWithTime:(NSString *)time
                         type:(NSInteger)type
                 succeedCount:(NSInteger)succeedCount
                  vacateCount:(NSInteger)vacateCount
             notCompleteCount:(NSInteger)notComplete;

@end
