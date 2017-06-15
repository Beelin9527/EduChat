//
//  DWDGrowUpCellContentView.m
//  EduChat
//
//  Created by apple on 3/3/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDGrowUpCellContentView.h"
#import "DWDGrowUpRecord.h"
#import "DWDGrowUpBodyLabel.h"
#import "TTTAttributedLabel.h"


#import <Masonry.h>

@interface DWDGrowUpCellContentView ()
@property (nonatomic, weak) UIImageView *startContentImageView;
@property (nonatomic, weak) DWDGrowUpBodyLabel *contentLabel;
@property (nonatomic, weak) UIButton *expandButton;
@end

@implementation DWDGrowUpCellContentView

//@property (nonatomic , copy) NSString *address; //
//@property (nonatomic , strong) NSNumber *albumId; //
//@property (nonatomic , copy) NSString *content; // 正文
//@property (nonatomic , strong) NSNumber *logId; //
//@property (nonatomic , strong) NSNumber *albumsType;  // 相册类型

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self setConstraints];
    
    
    return self;
}

#pragma mark - private method
- (void)setConstraints {
    
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIImageView *startContentImageView = [UIImageView new];
    [self addSubview:startContentImageView];
    
    DWDGrowUpBodyLabel *contentLabel = [DWDGrowUpBodyLabel new];
    contentLabel.font = DWDFontContent;
    [self addSubview:contentLabel];
    
    UIButton *expandButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [expandButton setTitle:@"全文" forState:UIControlStateNormal];
    [expandButton setTitleColor:DWDRGBColor(90, 136, 231) forState:UIControlStateNormal];
    [expandButton.titleLabel setFont:DWDFontContent];
    [expandButton addTarget:self action:@selector(expandButtonDidClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:expandButton];
    
    
    self.startContentImageView = startContentImageView;
    self.contentLabel = contentLabel;
    self.expandButton = expandButton;
    
    [startContentImageView makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.width.mas_equalTo(pxToW(44));
        make.height.mas_equalTo(pxToW(44));
    }];
    
    [contentLabel makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(pxToW(5));
        make.left.equalTo(startContentImageView.right).offset(pxToW(8));
        make.right.equalTo(self);
    }];
}

- (void)setExpandButton {
    
    //计算label 处理至3行时的height
    UILabel *testLabel = [[UILabel alloc] init];
    testLabel.text = self.record.content;
    testLabel.font = DWDFontContent;
    CGRect bounds = CGRectMake(0, 0, DWDScreenW - pxToW(20) - pxToW(57), MAXFLOAT);
    CGRect labelRect = [self.contentLabel textRectForBounds:bounds limitedToNumberOfLines:3];
    CGSize bodySize = labelRect.size;
    //完整内容
    NSDictionary *attr = @{NSFontAttributeName : DWDFontContent};
    CGSize allBodySize = [self.contentLabel.text boundingRectWithSize:CGSizeMake(DWDScreenW - pxToW(20) - pxToW(57), MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attr context:nil].size;
    BOOL bol = allBodySize.height > bodySize.height;
    DWDMarkLog(@"all:%@\nbody:%@", NSStringFromCGSize(allBodySize), NSStringFromCGSize(bodySize));
    if (bol) {
        self.expandButton.hidden = NO;
        [self.contentLabel remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(pxToW(5));
            make.left.equalTo(self.startContentImageView.right).offset(pxToW(8));
            make.right.equalTo(self);
            make.bottom.equalTo(self.expandButton.top).offset(-pxToW(20));
        }];
        [self.expandButton remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self);
            make.bottom.equalTo(self);
        }];
    } else {
        self.expandButton.hidden = YES;
        [self.contentLabel remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(pxToW(5));
            make.left.equalTo(self.startContentImageView.right).offset(pxToW(8));
            make.right.equalTo(self);
            make.bottom.equalTo(self);
        }];
    }
    [super updateConstraints];
}

#pragma mark - event response
- (void)expandButtonDidClick {
    if (self.contentLabel.expandState == YES) {
        [self.expandButton setTitle:@"全文" forState:UIControlStateNormal];
        [self.contentLabel contractLabel];
        self.contentLabel.expandState = NO;
    } else {
        [self.expandButton setTitle:@"收起" forState:UIControlStateNormal];
        [self.contentLabel expandLabel];
        self.contentLabel.expandState = YES;
    }
    [super updateConstraints];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GrowUpTableViewReloadData" object:nil];
}

#pragma mark - setter / getter
- (void)setRecord:(DWDGrowUpRecord *)record {
    _record = record;
    
    self.startContentImageView.image = [UIImage imageNamed:@"ic_description_recording_normal"];
    self.contentLabel.text = record.content;
    
    //设置是否有展开按钮
    [self setExpandButton];
    
    
//    CGFloat height = CGRectGetMaxY(self.expandButton.frame);
//    DWDMarkLog(@"buttonheight:%f", height);
//    [self updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(height);
//    }];
    [super updateConstraints];
}

@end
