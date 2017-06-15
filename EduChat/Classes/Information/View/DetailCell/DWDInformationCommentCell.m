//
//  DWDInformationCommentCell.m
//  EduChat
//
//  Created by KKK on 16/5/26.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInformationCommentCell.h"

#import "DWDInfomationCommentModel.h"
#import "NSDate+dwd_dateCategory.h"
#import "NSDictionary+dwd_extend.h"

#import <YYLabel.h>
#import <UIImageView+WebCache.h>

@interface DWDInformationCommentCell ()
@property (weak, nonatomic) UIImageView *imgView;
//@property (weak, nonatomic) UILabel *nickNameLabel;
//@property (weak, nonatomic) UILabel *replyTxtLabel;
//@property (weak, nonatomic) UILabel *forNicknameLabel;
@property (nonatomic, weak) YYLabel *nameLabel;
@property (weak, nonatomic) UILabel *datetimeLabel;
@property (nonatomic, weak) UIView *bottomLineView;
@property (weak, nonatomic) YYLabel *commentLabel;

@property (nonatomic, strong) DWDInfomationCommentModel *model;

@end

@implementation DWDInformationCommentCell

//- (instancetype)initWithFrame:(CGRect)frame {
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    UIImageView *imgView = [UIImageView new];
    imgView.layer.masksToBounds = YES;
    imgView.layer.cornerRadius = 15;
    [self.contentView addSubview:imgView];
    _imgView = imgView;
    
//    UILabel *nicknameLabel = [UILabel new];
//    nicknameLabel.font = [UIFont systemFontOfSize:14];
//    nicknameLabel.textColor = DWDRGBColor(102, 102, 102);
//    [self.contentView addSubview:nicknameLabel];
//    _nickNameLabel = nicknameLabel;
//    
//    UILabel *replyTxtLabel = [UILabel new];
//    replyTxtLabel.font = [UIFont systemFontOfSize:14];
//    replyTxtLabel.textColor = DWDRGBColor(102, 102, 102);
//    replyTxtLabel.text = @"回复";
//    [self.contentView addSubview:replyTxtLabel];
//    _replyTxtLabel = replyTxtLabel;
//    [_replyTxtLabel sizeToFit];
//    
//    UILabel *forNicknameLabel = [UILabel new];
//    forNicknameLabel.font = [UIFont systemFontOfSize:14];
//    forNicknameLabel.textColor = DWDRGBColor(80, 125, 175);
//    [self.contentView addSubview:forNicknameLabel];
//    _forNicknameLabel = forNicknameLabel;
    YYLabel *nameLabel = [YYLabel new];
    nameLabel.numberOfLines = 2;
    nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    nameLabel.font = [UIFont systemFontOfSize:14];
    [self.contentView addSubview:nameLabel];
    _nameLabel = nameLabel;
    
    UILabel *datetimeLabel = [UILabel new];
    datetimeLabel.font = [UIFont systemFontOfSize:12];
    datetimeLabel.textColor = DWDRGBColor(153, 153, 153);
    [self.contentView addSubview:datetimeLabel];
    _datetimeLabel = datetimeLabel;
    
    YYLabel *commentLabel = [YYLabel new];
    commentLabel.displaysAsynchronously = YES; //开启异步绘制
    commentLabel.font = [UIFont systemFontOfSize:15];
    commentLabel.textColor = DWDRGBColor(51, 51, 51);
    commentLabel.preferredMaxLayoutWidth = DWDScreenW - 60;
    [self.contentView addSubview:commentLabel];
    _commentLabel = commentLabel;
    
    UIView *lineView = [UIView new];
    lineView.backgroundColor = DWDRGBColor(231, 231, 231);
    [self.contentView addSubview:lineView];
    _bottomLineView = lineView;
    
//    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] init];
//    [gesture addTarget:self action:@selector(longPressToDelete:)];
//    gesture.minimumPressDuration = 1.0f;
//    [self addGestureRecognizer:gesture];
    
       return self;
}

- (void)longPressToDelete:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        if ([DWDCustInfo shared].custId != nil && [[DWDCustInfo shared].custId isEqualToNumber:_model.custId]) {
            if (_delegate && [_delegate respondsToSelector:@selector(commentCellLongPressToDeleteComment:)]) {
                [_delegate commentCellLongPressToDeleteComment:self];
            }
        }
    }
}

- (void)layout:(DWDInfomationCommentModel *)model {
    _model = model;
    
    [_imgView sd_setImageWithURL:[NSURL URLWithString:_model.photoKey] placeholderImage:[UIImage imageNamed:@"ME_User_HP_Boy"]];
    
//    _nickNameLabel.text = _model.nickname;
//    [_nickNameLabel sizeToFit];
//    
//    if ([_model.forCustId isEqualToNumber:@0] || _model.forCustId == nil || _model.forNickname == nil || _model.forNickname.length == 0) {
//        _replyTxtLabel.hidden = YES;
//        _forNicknameLabel.text = nil;
//        _forNicknameLabel.hidden = YES;
//    } else {
//        _replyTxtLabel.hidden = NO;
//        _forNicknameLabel.text = _model.forNickname;
//        [_forNicknameLabel sizeToFit];
//        _forNicknameLabel.hidden = NO;
//    }
    
    
    static YYTextSimpleEmoticonParser *parser;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //            YYTextSimpleEmoticonParser *parser = [YYTextSimpleEmoticonParser new];
        parser = [YYTextSimpleEmoticonParser new];
        parser.emoticonMapper = [NSDictionary dwd_emotionMapperDictionary];
    });
    
    //设置咨询名字显示
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:_model.nickname attributes:@{NSForegroundColorAttributeName : DWDRGBColor(102, 102, 102),
                                NSFontAttributeName : [UIFont systemFontOfSize:14]}];
    if ([_model.forCustId isEqualToNumber:@0] || _model.forCustId == nil || _model.forNickname == nil || _model.forNickname.length == 0) {
        //这些情况发生一种表示不是回复
    } else {
        [str appendAttributedString:[[NSAttributedString alloc] initWithString:@" 回复 " attributes:@{
                                                                                                  NSForegroundColorAttributeName : DWDRGBColor(102, 102, 102),
                                                                                                  NSFontAttributeName : [UIFont systemFontOfSize:14]}]];
        //        NSUInteger length = str.length;
        //        NSRange range = NSMakeRange(length, _model.forNickname.length);
        [str appendAttributedString:[[NSAttributedString alloc] initWithString:_model.forNickname
                                                                    attributes:
                                     @{ NSForegroundColorAttributeName : DWDRGBColor(80, 125, 175),
                                        NSFontAttributeName : [UIFont systemFontOfSize:14]
                                        }]];
    }
    [parser parseText:str selectedRange:nil];
    YYTextContainer *nameContainer = [YYTextContainer containerWithSize:CGSizeMake(DWDScreenW - 60, MAXFLOAT)];
    YYTextLayout *nameLayout = [YYTextLayout layoutWithContainer:nameContainer text:str];
    _nameLabel.textParser = parser;
    _nameLabel.textLayout = nameLayout;
    
    _datetimeLabel.text = [NSString stringWithTimelineDate:[NSDate dateWithString:_model.addtime format:@"YYYY-MM-dd HH:mm"]]; //YYYY-MM-dd HH:mm:ss 2016-08-27 17:59
    [_datetimeLabel sizeToFit];

    NSMutableAttributedString *attrstr = [[NSMutableAttributedString alloc] initWithString:_model.commentTxt attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:14]}];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:6];
    [attrstr addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [_model.commentTxt length])];
    [parser parseText:attrstr selectedRange:nil];
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(DWDScreenW - 60, MAXFLOAT)];
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:attrstr];
    
   
    
//       _commentLabel.attributedText = attrstr;
    
    _commentLabel.textParser = parser;
    _commentLabel.textLayout = layout;
//    YYTextSimpleEmoticonParser *paraser = [YYTextSimpleEmoticonParser new];
//    paraser.emoticonMapper = [NSDictionary dwd_emotionMapperDictionary];
    
    
    
    [self _layout];
}

- (void)_layout {
    //    @property (weak, nonatomic) UIImageView *imgView;
    //    @property (weak, nonatomic) UILabel *nickNameLabel;
    //    @property (weak, nonatomic) UILabel *replyTxtLabel;
    //    @property (weak, nonatomic) UILabel *forNicknameLabel;
    //    @property (weak, nonatomic) UILabel *datetimeLabel;
    //    @property (weak, nonatomic) YYLabel *commentLabel;
    _imgView.frame = CGRectMake(10, 10, 30, 30);
  
    
    CGRect nameFrame = _nameLabel.textLayout.textBoundingRect;
    nameFrame.origin = CGPointMake(50, 10);
    _nameLabel.frame = nameFrame;
    
//    if (![_model.forCustId isEqualToNumber:@0] && _model.forCustId != nil && _model.forNickname != nil && _model.forNickname.length > 0) {
////        设置
//        CGRect replyFrame = _replyTxtLabel.frame;
//        replyFrame.origin = (CGPoint){CGRectGetMaxX(nicknameFrame) + 2, nicknameFrame.origin.y};
//        _replyTxtLabel.frame = replyFrame;
//        CGRect fornicknameFrame = _forNicknameLabel.frame;
//        fornicknameFrame.origin = (CGPoint){CGRectGetMaxX(replyFrame) + 2, nicknameFrame.origin.y};
//        _forNicknameLabel.frame = fornicknameFrame;
//    }
    
    CGRect datetimeFrame = _datetimeLabel.frame;
    datetimeFrame.origin = (CGPoint){nameFrame.origin.x, CGRectGetMaxY(nameFrame) + 5};
    _datetimeLabel.frame = datetimeFrame;
    
    CGRect commentFrame = CGRectZero;
    commentFrame.size = _commentLabel.textLayout.textBoundingSize;
    commentFrame.origin = (CGPoint){nameFrame.origin.x, CGRectGetMaxY(datetimeFrame) + 9};
    _commentLabel.frame = commentFrame;
    
//    _bottomLineView.frame = CGRectMake(10, 20, DWDScreenW - 20, 1);
    CGRect lineFrame = CGRectZero;
    lineFrame.origin = (CGPoint){50, CGRectGetMaxY(commentFrame) + 9};
    lineFrame.size = (CGSize){DWDScreenW - 50, 1};
    _bottomLineView.frame = lineFrame;
}

@end
