//
//  DWDDetailSystemMessagePhotoCell.m
//  EduChat
//
//  Created by apple on 3/1/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDDetailSystemMessagePhotoCell.h"
#import <UIImageView+WebCache.h>
#import <Masonry.h>

@interface DWDDetailSystemMessagePhotoCell ()

@property (nonatomic, weak) UIImageView *faceView;
@property (nonatomic, weak) UILabel *nameLabel;
@property (nonatomic, weak) UILabel *statusLabel;
@property (nonatomic, weak) UIImageView *genderImageView;

@end

@implementation DWDDetailSystemMessagePhotoCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    UIImageView *imageView = [UIImageView new];
    [self.contentView addSubview:imageView];
    [imageView makeConstraints:^(MASConstraintMaker *make) {
//        make.width.mas_equalTo(pxToH(120));
//        make.top.equalTo(self).offset(pxToH(20));
//        make.left.equalTo(self).offset(pxToH(20));
//        make.bottom.equalTo(self).offset(-pxToH(20));
        make.top.equalTo(self.contentView).offset(10);
        make.left.equalTo(self.contentView).offset(10);
        make.bottom.equalTo(self.contentView).offset(-10);
        make.width.height.mas_equalTo(pxToH(120));
    }];
    self.faceView = imageView;
    
    UILabel *nameLabel = [UILabel new];
    [self.contentView addSubview:nameLabel];
    [nameLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.contentView).offset(15);
        make.left.equalTo(imageView.right).offset(15);
    }];
    self.nameLabel = nameLabel;
    
    UILabel *statusLabel = [UILabel new];
    statusLabel.font = DWDFontMin;
    statusLabel.textColor = [UIColor whiteColor];
    statusLabel.backgroundColor = DWDRGBColor(5, 201, 219);
    [self.contentView addSubview:statusLabel];
    [statusLabel makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(imageView.right).offset(15);
        make.bottom.equalTo(self.contentView).offset(-15);
    }];
    self.statusLabel = statusLabel;
    
    UIImageView *genderImageView = [UIImageView new];
    [self.contentView addSubview:genderImageView];
    [genderImageView makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(statusLabel.right).offset(5);
        make.centerY.equalTo(statusLabel);
        make.width.height.mas_equalTo(30);
    }];
    self.genderImageView = genderImageView;
    
    return self;
}

- (void)setFrame:(CGRect)frame {
//    frame.size.height -= 20;
    [super setFrame:frame];
}

- (void)setName:(NSString *)name {
    _name = name;
    self.nameLabel.text = name;
    self.nameLabel.font = DWDFontBody;
}

- (void)setStatus:(NSString *)status {
    _status = status;
    self.statusLabel.text = status;
    self.statusLabel.font = DWDFontMin;
}

- (void)setPhotoKey:(NSString *)photoKey {
    _photoKey = photoKey;
    [self.faceView sd_setImageWithURL:[NSURL URLWithString:photoKey] placeholderImage:DWDDefault_MeBoyImage];
}

- (void)setGender:(NSString *)gender {
    _gender = gender;
//    self.genderImageView.text = gender;
//    self.genderImageView.font = DWDFontContent;
    if ([gender isEqualToString:@"男"]) {
        self.genderImageView.image = [UIImage imageNamed:@"ic_boy_people_nearby_normal"];
    } else {
        self.genderImageView.image = [UIImage imageNamed:@"ic_gril_people_nearby_normal"];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
