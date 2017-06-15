//
//  DWDChatTimeCell.h
//  EduChat
//
//  Created by apple on 11/23/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDChatTimeCell : UITableViewCell

@property (strong, nonatomic) UILabel *contentLabel;

- (CGFloat)getHeight;
@property (nonatomic , strong) NSIndexPath *indexPath;
@end
