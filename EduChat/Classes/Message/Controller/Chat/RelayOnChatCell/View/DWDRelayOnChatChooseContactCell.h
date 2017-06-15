//
//  DWDRelayOnChatChooseContactCell.h
//  EduChat
//
//  Created by Superman on 16/9/7.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DWDRelayOnChatChooseContactCell : UITableViewCell

@property (nonatomic , weak) UIImageView *selectImageView;
@property (nonatomic , weak) UIImageView *iconView;
@property (nonatomic , weak) UILabel *nameLabel;

@property (nonatomic , assign , getter=isMultSelecte) BOOL multSelect;

//- (void)tapMultSelectImage;

@end
