//
//  DWDAddNotificationSelectedCell.m
//  EduChat
//
//  Created by KKK on 16/5/9.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDAddNotificationSelectedCell.h"
#import "DWDClassNotificationSelectGroupModel.h"

@interface DWDAddNotificationSelectedCell ()

@property (nonatomic, weak) UIImageView *imgView;

@end

@implementation DWDAddNotificationSelectedCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    UIImageView *imgView = [UIImageView new];
    [self setType:CellCheckTypeNone];
    [self.contentView addSubview:imgView];
    _imgView = imgView;
    
    UILabel *contentLabel = [UILabel new];
    [self.contentView addSubview:contentLabel];
    _contentLabel = contentLabel;
    
    return self;
}

- (void)setType:(CellCheckType)type {
    _type = type;
    switch (type) {
        case CellCheckTypeNone:
            [_imgView setImage:[UIImage imageNamed:@""]];
            break;
        case CellCheckTypeSelected:
            [_imgView setImage:[UIImage imageNamed:@""]];
            break;
        case CellCheckTypeDisabled:
            [_imgView setImage:[UIImage imageNamed:@""]];
            break;
        default:
            break;
    }
}

@end
