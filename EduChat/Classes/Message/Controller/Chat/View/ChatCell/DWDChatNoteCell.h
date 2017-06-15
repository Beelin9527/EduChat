//
//  DWDChatNoteCell.h
//  EduChat
//
//  Created by Superman on 16/3/8.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDChatNoteCell : UITableViewCell
@property (strong, nonatomic) UILabel *contentLabel;

- (CGFloat)getHeight;
@property (nonatomic , strong) NSIndexPath *indexPath;

@end
