//
//  DWDGrowUpBodyLabel.h
//  EduChat
//
//  Created by apple on 2/24/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDGrowUpBodyLabel : UILabel

@property (nonatomic, assign) BOOL expandState;


- (void)expandLabel;
- (void)contractLabel;
@end
