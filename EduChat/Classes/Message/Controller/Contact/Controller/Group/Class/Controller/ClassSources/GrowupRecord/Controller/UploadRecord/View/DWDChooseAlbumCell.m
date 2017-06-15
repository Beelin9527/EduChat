//
//  DWDChooseAlbumCell.m
//  EduChat
//
//  Created by Superman on 16/1/6.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDChooseAlbumCell.h"

#import "DWDChooseAlbumModel.h"
#import <UIImageView+WebCache.h>

@interface DWDChooseAlbumCell()


@end

@implementation DWDChooseAlbumCell

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        UIImageView *iconView = [[UIImageView alloc] init];
        UILabel *albumNameLabel = [[UILabel alloc] init];
        albumNameLabel.font = DWDFontMin;
        albumNameLabel.textAlignment = NSTextAlignmentCenter;
        
        _iconView = iconView;
        _albumNameLabel = albumNameLabel;
        
        [self.contentView addSubview:iconView];
        [self.contentView addSubview:albumNameLabel];
        
    }
    return self;
}


- (void)setAlbums:(DWDChooseAlbumModel *)albums{
    _albums = albums;
    
    [_iconView sd_setImageWithURL:[NSURL URLWithString:albums.photoKey] placeholderImage:[UIImage imageNamed:@"AvatarMe"]];
    _iconView.frame = CGRectMake(0, 0, pxToW(120), pxToH(120));
    
    _albumNameLabel.text = albums.name;
    
    CGSize textSize = [albums.name realSizeWithfont:DWDFontContent];
    _albumNameLabel.frame = CGRectMake(0, CGRectGetMaxY(_iconView.frame) + pxToH(10), pxToW(120), textSize.height);
}

@end
