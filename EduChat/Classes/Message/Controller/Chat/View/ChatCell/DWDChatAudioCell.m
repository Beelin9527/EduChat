//
//  DWDChatAudioCell.m
//  EduChat
//
//  Created by apple on 11/23/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDChatAudioCell.h"
#import "UIImage+Utils.h"
#define DWDDurationMultiple 15

@interface DWDChatAudioCell () {
    CGRect backgroundImageFrame, desFrame , animateImageFrame;
}

@property (nonatomic , assign) CGFloat myselfBackgroundLength;
@property (nonatomic , assign) CGFloat otherBackGroundLength;


@end

@implementation DWDChatAudioCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self commitInitWithTitles];
        [self buildSubviews];
        self.menuTargetView = self.backgroundImageView;
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    
    if (self.userType == DWDChatCellUserTypeMyself) {
        
        [self buildFrameForAudioByMyself];
        [self setFrames];
        
        _redCircleView.x = CGRectGetMinX(_backgroundImageView.frame) - 8;
        
        _animateImageView.x = _myselfBackgroundLength - 40;
        
        _desLabel.x = CGRectGetMinX(_backgroundImageView.frame) - 27;  // 临时处理
        
        
    } else {
        
        [self buildFrameForAudioByOther];
        [self setFrames];
        
        _redCircleView.x = CGRectGetMaxX(_backgroundImageView.frame) + 3 ;
        
        _animateImageView.x = 15;
      
    }
    
    _animateImageView.cenY = self.avatarImgView.cenY;
    _animateImageView.size = CGSizeMake(22, 22);
    _redCircleView.y = _backgroundImageView.y + 5;
    self.avatarImgView.cenY = self.backgroundImageView.cenY;
//    [self setImages];
    
}

- (CGFloat)getHeight {
    return self.isShowNickname ? DWDAvatarEdgeLength + 2 * DWDCellPadding + [self getNicknameSize].height : DWDAvatarEdgeLength + 2 * DWDCellPadding;
}


- (void)buildSubviews {
    
    _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.backgroundImageView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(contentTapHandler:)];
    [self.backgroundImageView addGestureRecognizer:tap];
    [self.backgroundImageView addGestureRecognizer:self.longPress];
    
    _desLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.desLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    
//    UIImage *redImage = [UIImage imageWithColor:[UIColor redColor]];
    UIImage *redImage = [UIImage imageNamed:@"ic_new_information"];
    _redCircleView = [[UIImageView alloc] initWithImage:redImage];
//    _redCircleView = [[UIImageView alloc] initWithImage:[UIImage createRoundedRectImage:redImage size:CGSizeMake(5, 5)]];
    
    [self.contentView addSubview:self.backgroundImageView];
    [self.contentView addSubview:self.desLabel];
    [self.contentView addSubview:self.redCircleView];
    
    _animateImageView = [[UIImageView alloc] init];
    
  //  [self setImages];
    
    [self.backgroundImageView addSubview:_animateImageView];
    
}

- (void)UIPrepareForCreateStatus {
    [self.sendingIndicator stopAnimating];
    self.sendingIndicator.hidden = YES;
    self.errorImgView.hidden = YES;
    self.desLabel.hidden = YES;
    
    if (self.userType == DWDChatCellUserTypeMyself) {
        //班级暂时取消撤销
        if (self.chatType == DWDChatTypeClass) {
           self.menuTitles = @[@"Delete"];
        }else{
         self.menuTitles = @[@"Delete", @"Revoke"];
        }

    }else{
        self.menuTitles = @[@"Delete"];
    }
    [self startFlashing];
}

- (void)UIPrepareForNormalStatus {
    [self.sendingIndicator stopAnimating];
    self.sendingIndicator.hidden = YES;
    self.errorImgView.hidden = YES;
    self.desLabel.hidden = NO;
    
    if (self.userType == DWDChatCellUserTypeMyself) {
        //班级暂时取消撤销
        if (self.chatType == DWDChatTypeClass) {
            self.menuTitles = @[@"Delete"];
        }else{
            self.menuTitles = @[@"Delete", @"Revoke"];
        }
    }else{
        self.menuTitles = @[@"Delete"];
    }
    [self stopFlashing];
}

- (void)UIPrepareForSendingDataStatus {
    [self.contentView bringSubviewToFront:self.sendingIndicator];
    self.sendingIndicator.hidden = NO;
    [self.sendingIndicator startAnimating];
    self.errorImgView.hidden = YES;
    self.desLabel.hidden = YES;
    
    self.menuTitles = @[@"Delete"];
    [self stopFlashing];
}

- (void)UIPrepareForErrorStatus {
    [self.sendingIndicator stopAnimating];
    self.sendingIndicator.hidden = YES;
    self.errorImgView.hidden = NO;
    self.desLabel.hidden = YES;
    
    self.menuTitles = @[@"Delete"];
}

#pragma mark - private methods
- (void)buildFrameForAudioByMyself {
    
    [self buildMyselfAvatarFrame];
    
    CGSize nicknameSize = [self buildMyselfNicknameFrame];
    
    float backgroundLength = [self getAudioLength];
    _myselfBackgroundLength = backgroundLength;
    backgroundImageFrame = CGRectMake(DWDScreenW - DWDAvatarEdgeLength - 2 * DWDCellPadding - backgroundLength, DWDCellPadding + nicknameSize.height, backgroundLength, DWDAvatarEdgeLength);
    
    //indicator frame
    sendingFrame = CGRectMake(backgroundImageFrame.origin.x - DWDCellPadding - DWDErrorEdgeLength, DWDCellPadding, DWDErrorEdgeLength, DWDErrorEdgeLength);
    errorFrame = sendingFrame;
    
    CGSize desSize = [self getDesSize];
    desFrame = CGRectMake(backgroundImageFrame.origin.x - DWDCellPadding - desSize.width , 0, desSize.width + DWDCellPadding, desSize.height);
    
    animateImageFrame = CGRectMake(0, 0, 44, 44);
    
}

- (void)buildFrameForAudioByOther {
    
    [self buildOtherAvatarFrame];
    
    CGSize nicknameSize = [self buildOtherNicknameFrame];
    
    float backgroundLength = [self getAudioLength];
    _otherBackGroundLength = backgroundLength;
    //background frame
    backgroundImageFrame = CGRectMake(DWDAvatarEdgeLength + 2 * DWDCellPadding, DWDCellPadding + nicknameSize.height, backgroundLength, DWDAvatarEdgeLength);
    if (self.isEditing) backgroundImageFrame = CGRectMake(backgroundImageFrame.origin.x + DWDCellEditingEdgeLength + DWDCellPadding,backgroundImageFrame.origin.y, backgroundImageFrame.size.width, backgroundImageFrame.size.height);
    
    //indicator frame
    sendingFrame = CGRectMake(backgroundImageFrame.origin.x + backgroundImageFrame.size.width + DWDCellPadding, DWDCellPadding, DWDErrorEdgeLength, DWDErrorEdgeLength);
    errorFrame = sendingFrame;
    
   
    CGSize desSize = [self getDesSize];
    desFrame = CGRectMake(backgroundImageFrame.origin.x + backgroundImageFrame.size.width + DWDCellPadding , 0, desSize.width +DWDCellPadding, desSize.height);
    
    
    animateImageFrame = CGRectMake(0, 0, 44, 44);
}

- (CGFloat)getAudioLength {
    CGFloat length = MIN(ceil(MIN(DWDScreenW - DWDAvatarEdgeLength - 4 * DWDCellPadding - DWDIndicatorWidth, self.audioDuration * DWDDurationMultiple)), DWDScreenW - DWDAvatarEdgeLength - 4 * DWDCellPadding - DWDIndicatorWidth);
    if (length < 100) {
        length = 100;
    }else if (length > 250){
        length = 250;
    }
    return length;
}

- (CGSize)getDesSize {
    
    CGSize result = [self.desLabel.text
                     boundingRectWithSize:CGSizeMake(DWDErrorEdgeLength, DWDErrorEdgeLength)
                     options:NSStringDrawingUsesFontLeading
                     attributes:@{NSFontAttributeName:self.desLabel.font}
                     context:nil].size;
    
    result = CGSizeMake(ceil(result.width), ceil(result.height));
    
    return result;
}

- (void)setFrames {
    self.avatarImgView.frame = avatareFrame;
    self.editingView.frame = editingFrame;
    self.editingView.center = CGPointMake(self.editingView.center.x, self.avatarImgView.center.y);
    self.nicknameLabel.frame = nicknameFrame;
    self.backgroundImageView.frame = backgroundImageFrame;
    
    self.sendingIndicator.frame = sendingFrame;
    self.sendingIndicator.center = CGPointMake(self.sendingIndicator.center.x, self.backgroundImageView.center.y);
    
    self.errorImgView.frame = errorFrame;
    self.errorImgView.center = CGPointMake(self.errorImgView.center.x, self.backgroundImageView.center.y);
    
    self.desLabel.frame = desFrame;
    self.desLabel.center = self.sendingIndicator.center;
    
    self.animateImageView.frame = animateImageFrame;
    self.animateImageView.center = self.sendingIndicator.center;
}

//- (void)setImages {
//    if (self.userType == DWDChatCellUserTypeMyself) {  // size 一定要有值  才可以开启上下文来渲染图片
//        self.backgroundImageView.image = [self.bubbleMyself renderAtSize:backgroundImageFrame.size];
//    } else {
//        self.backgroundImageView.image = [self.bubbleOther renderAtSize:backgroundImageFrame.size];
//    }
//    
//}

- (void)contentTapHandler:(UITapGestureRecognizer *)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interactiveChatCellDidClickContentWithCell:)]) {
        [self.delegate interactiveChatCellDidClickContentWithCell:self];
    }
}

//  0.75秒让气泡消失
- (void)startFlashing {
    
    [UIView animateWithDuration:.75
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut |
                                UIViewAnimationOptionRepeat |
                                UIViewAnimationOptionAutoreverse |
                                UIViewAnimationOptionAllowUserInteraction
     
                     animations:^{
                         self.backgroundImageView.alpha = 0;
                         
                     } completion:nil];

}

// 0.12秒气泡出现
- (void)stopFlashing {
    [UIView animateWithDuration:0.12
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut |
                                UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.backgroundImageView.alpha = 1.0f;
                     }
                     completion:nil];
}


@end
