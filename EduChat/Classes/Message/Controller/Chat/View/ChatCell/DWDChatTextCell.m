//
//  DWDChatTextCell.m
//  EduChat
//
//  Created by apple on 11/23/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDChatTextCell.h"
#import "UIImage+Utils.h"
#import "NSDictionary+dwd_extend.h"
@interface DWDChatTextCell () {
    CGRect backgroundFrame, contentFrame;
}

@property (strong, nonatomic) UIImageView *backgroundImgView;

@end

@implementation DWDChatTextCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self commitInitWithTitles];
        [self buildSubviews];
        self.menuTargetView = self.backgroundImgView;
    }
    return self;
}

- (CGFloat)getHeight {
    
    CGFloat result;
    
    if (self.isShowNickname) {  // 返回大于或等于参数的  最小整数
         result = ceil(MAX([self getContentSize].height + [self getNicknameSize].height + 2 * DWDCellPadding + 2 * DWDContentUpDownPadding, DWDAvatarEdgeLength + 2 * DWDCellPadding));
    } else {
         result = ceil(MAX([self getContentSize].height + 2 * DWDCellPadding + 2 * DWDContentUpDownPadding, DWDAvatarEdgeLength + 2 * DWDCellPadding));
    }
   
    return result;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    if (self.userType == DWDChatCellUserTypeMyself) {
        
        [self buildFrameForTextByMyself];
        
    } else {
        
        [self buildFrameForTextByOther];
        
    }
    
    [self setFrames];
    [self setImages];
    
//    self.avatarImgView.cenY = self.backgroundImgView.cenY;
}

- (void)UIPrepareForNormalStatus {
    [self.sendingIndicator stopAnimating];
    self.sendingIndicator.hidden = YES;
    self.errorImgView.hidden = YES;
    
    if (self.userType == DWDChatCellUserTypeMyself) {
        //班级暂时取消撤销
        if (self.chatType == DWDChatTypeClass) {
            self.menuTitles = @[@"Copy" , @"Relay" , @"Delete"];
        }else{
             self.menuTitles = @[@"Copy" , @"Relay" , @"Delete" , @"Revoke"];
        }
        
    }else{
         self.menuTitles = @[@"Copy" , @"Relay" , @"Delete"];
    }
    
}

- (void)UIPrepareForSendingDataStatus {
    self.sendingIndicator.hidden = NO;
    [self.sendingIndicator startAnimating];
    self.errorImgView.hidden = YES;
    
    self.menuTitles = @[@"Copy" , @"Delete"];
}

- (void)UIPrepareForErrorStatus {
    [self.sendingIndicator stopAnimating];
    self.sendingIndicator.hidden = YES;
    self.errorImgView.hidden = NO;
    
    self.menuTitles = @[@"Copy" , @"Delete"];
}


#pragma mark - private methods

- (CGSize)getContentSize {
    // 改成YYTextLayout 已适配iOS10
//    CGSize result = [self.contentLabel sizeThatFits:CGSizeMake(DWDScreenW - DWDAvatarEdgeLength - 4 * DWDCellPadding - DWDIndicatorWidth - DWDContentLeftRightPaddingMax - DWDContentLeftRightPaddingMin, MAXFLOAT)];
    
    YYTextContainer *container = [YYTextContainer containerWithSize:CGSizeMake(DWDScreenW - DWDAvatarEdgeLength - 4 * DWDCellPadding - DWDIndicatorWidth - DWDContentLeftRightPaddingMax - DWDContentLeftRightPaddingMin , MAXFLOAT) insets:UIEdgeInsetsMake(5, 1, 5, 0)];
    
    YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:self.contentLabel.attributedText];
    
    CGSize result = layout.textBoundingSize;
    
//    float height = ceilf(MAX(result.height, DWDAvatarEdgeLength - 2 * DWDContentUpDownPadding));
//    
//    result = CGSizeMake(ceilf(result.width), height);
    
    return result;
}

- (void)buildFrameForTextByMyself {
    
    [self buildMyselfAvatarFrame];
    
    CGSize nicknameSize = [self buildMyselfNicknameFrame];
    
    //content frame
    CGSize contentSize =  [self getContentSize];
    contentFrame = CGRectMake(DWDScreenW - DWDAvatarEdgeLength - 2 * DWDCellPadding - DWDContentLeftRightPaddingMax - contentSize.width,
                              DWDCellPadding + nicknameSize.height + DWDContentUpDownPadding, contentSize.width, contentSize.height);
    
    //background frame
    backgroundFrame = CGRectMake(contentFrame.origin.x - DWDContentLeftRightPaddingMin,
                                 DWDCellPadding + nicknameSize.height,
                                 contentSize.width + DWDContentLeftRightPaddingMax + DWDContentLeftRightPaddingMin,
                                 contentSize.height + 2 * DWDContentUpDownPadding);
    
    //indicator frame
    sendingFrame = CGRectMake(backgroundFrame.origin.x - DWDCellPadding - DWDErrorEdgeLength, DWDCellPadding, DWDErrorEdgeLength, DWDErrorEdgeLength);
    errorFrame = sendingFrame;
    
    
}

- (void)buildFrameForTextByOther {
    
    [self buildOtherAvatarFrame];
    
    CGSize nicknameSize = [self buildOtherNicknameFrame];
    
    //content frame
    CGSize contentSize = [self getContentSize];
    contentFrame = CGRectMake(DWDAvatarEdgeLength + 2 * DWDCellPadding + DWDContentLeftRightPaddingMax,
                              DWDCellPadding + nicknameSize.height + DWDContentUpDownPadding, contentSize.width, contentSize.height);
    
    if (self.isEditing) contentFrame = CGRectMake(contentFrame.origin.x + DWDCellEditingEdgeLength + DWDCellPadding, contentFrame.origin.y, contentFrame.size.width, contentFrame.size.height);
    
    //background frame
    backgroundFrame = CGRectMake(contentFrame.origin.x - DWDContentLeftRightPaddingMax,
                                 DWDCellPadding + nicknameSize.height, contentSize.width +
                                 DWDContentLeftRightPaddingMax + DWDContentLeftRightPaddingMin,
                                 contentSize.height + 2 * DWDContentUpDownPadding);
    
    //indicator frame
    sendingFrame = CGRectMake(backgroundFrame.origin.x + backgroundFrame.size.width + DWDCellPadding, DWDCellPadding, DWDErrorEdgeLength, DWDErrorEdgeLength);
    errorFrame = sendingFrame;
    
    
}

- (void)buildSubviews {
    
    //this subclass has a long press recognizer, so make supcalss's nil
//    self.longPress = nil;
    
    _backgroundImgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _backgroundImgView.userInteractionEnabled = YES;
    
    _contentLabel = [YYLabel new];
    [_contentLabel addGestureRecognizer:self.longPress];
    
//    WEAKSELF;
//    _contentLabel.textLongPressAction = ^(UIView *containerView, NSAttributedString *text, NSRange range, CGRect rect){
//        [weakSelf longPressHandler:nil];
//    };
    
    YYTextSimpleEmoticonParser *parser = [YYTextSimpleEmoticonParser new];
    parser.emoticonMapper = [NSDictionary dwd_emotionMapperDictionary];
    _contentLabel.textParser = parser;
    
    //self.contentLabel.delegate = self;
    self.contentLabel.font = DWDFontBody;
    self.contentLabel.textColor = DWDColorContent;
    self.contentLabel.numberOfLines = 0;
   // self.contentLabel.linkAttributes = @{NSForegroundColorAttributeName:DWDColorMain};
    
    [self.contentView addSubview:self.backgroundImgView];
    [self.contentView addSubview:self.contentLabel];
}

- (void)setFrames {
    
    self.avatarImgView.frame = avatareFrame;
    self.editingView.frame = editingFrame;
    self.editingView.center = CGPointMake(self.editingView.center.x, self.avatarImgView.center.y);
    self.nicknameLabel.frame = nicknameFrame;
    self.backgroundImgView.frame = backgroundFrame;
    self.contentLabel.frame = contentFrame;
    
    self.sendingIndicator.frame = sendingFrame;
    self.sendingIndicator.center = CGPointMake(self.sendingIndicator.center.x, self.backgroundImgView.center.y);

    self.errorImgView.frame = errorFrame;
    self.errorImgView.center = CGPointMake(self.errorImgView.center.x, self.backgroundImgView.center.y);
}

- (void)setImages {
    if (self.userType == DWDChatCellUserTypeMyself) {
        self.backgroundImgView.image = [self.bubbleMyself renderAtSize:backgroundFrame.size];
    } else {
        self.backgroundImgView.image = [self.bubbleOther renderAtSize:backgroundFrame.size];
    }
}

@end
