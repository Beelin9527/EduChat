//
//  DWDChatImageCell.m
//  EduChat
//
//  Created by apple on 11/23/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import "DWDChatImageCell.h"
#import "UIImage+Utils.h"
#import "DWDPhotoMetaModel.h"
#import "DWDImagesScrollView.h"

@interface DWDChatImageCell () {
    CGRect contentImageFrame, desFrame , backgroundImageFrame;
}

@end

@implementation DWDChatImageCell

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
        
        [self buildFrameForImageByMyself];
        
    } else {
        
        [self buildFrameForImageByOther];
        self.menuTitles = @[@"Relay" , @"Delete"];
        self.contentImageView.frame = CGRectMake(0, 0, 50, 50);
    }
    
    [self setFrames];
    
    if (self.chatType == DWDChatTypeClass || self.chatType == DWDChatTypeGroup) {
        self.contentImageView.y = 2;
    }
//    [self setImages];
    
    if (self.userType == DWDChatCellUserTypeMyself) {
        
        self.backgroundImageView.x = CGRectGetMinX(self.avatarImgView.frame) - self.contentImageView.w - 15;
        self.errorImgView.center = CGPointMake(CGRectGetMinX(self.backgroundImageView.frame) - 15, self.backgroundImageView.cenY);
        
    }else{
        self.backgroundImageView.x = CGRectGetMaxX(self.avatarImgView.frame) + 10;
        self.errorImgView.center = CGPointMake(CGRectGetMaxX(self.backgroundImageView.frame) + 10, self.backgroundImageView.cenY);
        
    }
    self.sendingIndicator.center = self.backgroundImageView.center;
}

- (CGFloat)getHeight {
    
    CGFloat result;
    
    if (self.isShowNickname) {
        result = self.imageSize.height + [self getNicknameSize].height + 2 * DWDCellPadding;
    } else {
        result = self.imageSize.height + 2 * DWDCellPadding;
    }
    return result;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return [super canPerformAction:action withSender:sender] || action == @selector(upload:);
}

- (void)UIPrepareForNormalStatus {
    [self.sendingIndicator stopAnimating];
    self.sendingIndicator.hidden = YES;
    self.desLabel.hidden = YES;
    self.errorImgView.hidden = YES;
    
    if (self.userType == DWDChatCellUserTypeMyself) {
        //班级暂时取消撤销
        if (self.chatType == DWDChatTypeClass) {
            self.menuTitles = @[@"Relay" , @"Delete"];
        }else{
           self.menuTitles = @[@"Relay" , @"Delete", @"Revoke"];
        }

        
    }else{
         self.menuTitles = @[@"Relay" , @"Delete"];
    }
   
    
    self.contentImageView.image = self.contentImageView.image;  // 修改图片的透明度重新赋值
}

- (void)UIPrepareForSendingDataStatus {  // 发送状态UI
    [self.contentView bringSubviewToFront:self.sendingIndicator];
    self.sendingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    self.sendingIndicator.hidden = NO;
    [self.sendingIndicator startAnimating];
    self.desLabel.hidden = NO;
    self.errorImgView.hidden = YES;
    
//    self.menuTitles = @[ @"Delete", @"Revoke"];
}

- (void)UIPrepareForErrorStatus {  // 错误状态UI
    
    [self.sendingIndicator stopAnimating];
    self.sendingIndicator.hidden = YES;
    self.desLabel.hidden = YES;
    self.errorImgView.hidden = NO;
    
//    self.menuTitles = @[ @"Delete", @"Revoke"];
}

#pragma mark - private methods
- (void)buildSubviews {
    
    _backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.backgroundImageView.userInteractionEnabled = YES;
    
    _contentImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _contentImageView.contentMode = UIViewContentModeScaleAspectFill;
    _contentImageView.clipsToBounds = YES;
    self.contentImageView.userInteractionEnabled = NO;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContentHandler:)];
    [self.contentImageView addGestureRecognizer:tap];
    [self.contentImageView addGestureRecognizer:self.longPress];
    
    _desLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.desLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
    
    [self.contentView addSubview:_backgroundImageView];
    [self.backgroundImageView addSubview:self.contentImageView];
    [self.contentView addSubview:self.desLabel];
    
    [self bringSubviewToFront:self.sendingIndicator];
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

// 创建frame数据
- (void)buildFrameForImageByMyself {
    
    [self buildMyselfAvatarFrame];
    
    CGSize nicknameSize = [self buildMyselfNicknameFrame];
    
    backgroundImageFrame = CGRectMake(DWDScreenW - DWDAvatarEdgeLength - 2 * DWDCellPadding - 105, DWDCellPadding + nicknameSize.height, self.imageSize.width + 12, self.imageSize.height + 4);
    
    contentImageFrame = CGRectMake(2 * DWDCellPadding + DWDAvatarEdgeLength - 58,
                                   DWDCellPadding + nicknameSize.height - 8, self.imageSize.width, self.imageSize.height);
    
    //indicator frame
    sendingFrame = CGRectMake(contentImageFrame.origin.x - DWDCellPadding - DWDErrorEdgeLength,
                              DWDCellPadding, DWDErrorEdgeLength, DWDErrorEdgeLength);
    errorFrame = sendingFrame;
    
    CGSize desSize = [self getDesSize];
    desFrame = CGRectMake(contentImageFrame.origin.x - DWDCellPadding - desSize.width, 0, desSize.width, desSize.height);
    
    }

- (void)buildFrameForImageByOther {
    
    [self buildOtherAvatarFrame];
    
    CGSize nicknameSize = [self buildOtherNicknameFrame];
    
    backgroundImageFrame = CGRectMake(DWDAvatarEdgeLength + 2 * DWDCellPadding , DWDCellPadding + nicknameSize.height, self.imageSize.width + 12, self.imageSize.height + 4);
    
    if (self.isEditing) backgroundImageFrame = CGRectMake(backgroundImageFrame.origin.x + DWDCellEditingEdgeLength + DWDCellPadding,backgroundImageFrame.origin.y, backgroundImageFrame.size.width, backgroundImageFrame.size.height);
    
    
    contentImageFrame = CGRectMake(2 * DWDCellPadding + DWDAvatarEdgeLength - 50,
                                   DWDCellPadding + nicknameSize.height - 8,
                                   self.imageSize.width, self.imageSize.height);
    if (self.isEditing) contentImageFrame = CGRectMake(contentImageFrame.origin.x + DWDCellEditingEdgeLength + DWDCellPadding, contentImageFrame.origin.y, contentImageFrame.size.width, contentImageFrame.size.height);
    
    sendingFrame  = CGRectMake(contentImageFrame.origin.x + contentImageFrame.size.width + DWDCellPadding,
                               DWDCellPadding, DWDErrorEdgeLength, DWDErrorEdgeLength);
    
    errorFrame = sendingFrame;
    
    CGSize desSize = [self getDesSize];
    desFrame = CGRectMake(contentImageFrame.origin.x + contentImageFrame.size.width + DWDCellPadding, 0, desSize.width, desSize.height);
}

- (void)setFrames {
    
    self.avatarImgView.frame = avatareFrame;
    self.editingView.frame = editingFrame;
    self.editingView.center = CGPointMake(self.editingView.center.x, self.avatarImgView.center.y);
    self.nicknameLabel.frame = nicknameFrame;
    
    self.backgroundImageView.frame = backgroundImageFrame;
    self.contentImageView.frame = contentImageFrame;
    
    self.sendingIndicator.frame = sendingFrame;
    float offset = self.userType == DWDChatCellUserTypeMyself ? -5 : 5;
    self.sendingIndicator.center = CGPointMake(self.contentImageView.center.x + offset, self.contentImageView.center.y);
    
    self.errorImgView.frame = errorFrame;
    
    self.desLabel.frame = desFrame;
    self.desLabel.center = self.sendingIndicator.center;
}

//- (void)setImages {  // 转换image 和 计算frame
//    
//    UIImage *mask;
//    
//    if (self.userType == DWDChatCellUserTypeMyself) {  // 根据发送者 使用QUARTZ2D渲染气泡
//        mask = [self.bubbleMyself renderAtSize:contentImageFrame.size];
//    } else {
//        mask = [self.bubbleOther renderAtSize:contentImageFrame.size];
//    }
//    // 在渲染气泡之前保存image , 用来预览使用
//    _originalContentImage = self.contentImageView.image;
//    self.contentImageView.image = [self.contentImageView.image maskWithImage:mask];
//}

- (void)tapContentHandler:(UITapGestureRecognizer *)sender {
    
//    DWDImagesScrollView *imagheScrollView = [[DWDImagesScrollView alloc] initWithPhotoMetaArray:@[self.photo]];
//    
//    [imagheScrollView presentViewFromImageView:self.contentImageView atIndex:0 toContainer:self];
    [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    
    if (self.imageCellDelegate && [self.imageCellDelegate respondsToSelector:@selector(imageCellTapContentToScaleWithImageCell:)]) {
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
        [self.imageCellDelegate imageCellTapContentToScaleWithImageCell:self];
    }
}



@end
