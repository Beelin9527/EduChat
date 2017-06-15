//
//  DWDChatPreViewCell.m
//  EduChat
//
//  Created by Superman on 16/9/1.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDChatPreViewCell.h"
#import "DWDChatMsgDataClient.h"

#import "DWDQRClient.h"

#import "UIView+kkk_personalAdd.h"

@interface DWDChatPreViewCell () <UIScrollViewDelegate , UIActionSheetDelegate>

@end

@implementation DWDChatPreViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    
    if (self = [super initWithFrame:frame]) {
        // 初始化
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.frame = self.bounds;
        //        scrollView.scrollEnabled = NO;
        scrollView.delegate = self;
        scrollView.maximumZoomScale = 2.0;
        scrollView.minimumZoomScale = 1.0;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        //        [scrollView setZoomScale:0.5 animated:NO];
        
        _scrollView = scrollView;
        [self.contentView addSubview:scrollView];
        
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.center = scrollView.center;
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImageView:)];
        [imageView addGestureRecognizer:tap];
        
        UILongPressGestureRecognizer *longPressGR =
        [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                      action:@selector(handleLongPress:)];
        
        [longPressGR setMinimumPressDuration:0.4];
        [imageView addGestureRecognizer:longPressGR];
        _imageView = imageView;
        [scrollView addSubview:imageView];
    }
    return self;
}

- (void)tapImageView:(UITapGestureRecognizer *)tap{
    // 还原imageview初始大小 或者退出预览
    // 退出预览
    if (self.preViewCellDelegate && [self.preViewCellDelegate respondsToSelector:@selector(preViewCellImageViewTap)]) {
        [self.preViewCellDelegate preViewCellImageViewTap];
    }
}

- (void)handleLongPress:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        
        UIAlertController *alctr = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        [alctr addAction:cancel];
        UIAlertAction *saveToAlbums = [UIAlertAction actionWithTitle:@"保存到相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            if (self.imageView.image)
            {
                UIImageWriteToSavedPhotosAlbum(self.imageView.image,self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
            }
            else
            {
                DWDMarkLog(@"image is nil");
            }
        }];
        [alctr addAction:saveToAlbums];
        NSString *qrstr = [NSString messageWithImage:self.imageView.image];
        if (qrstr != nil) {
        UIAlertAction *qrcode = [UIAlertAction actionWithTitle:@"识别二维码" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            //识别二维码
            // 通知VC 回复状态栏
//            [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationChatPreViewCellImageViewTap object:nil userInfo:nil];
            if (_preViewCellDelegate && [_preViewCellDelegate respondsToSelector:@selector(preViewCellImageViewTap)]) {
                [DWDQRClient requestAnalysisWithQRInfo:qrstr controller:[self viewController]];
                [_preViewCellDelegate preViewCellImageViewTap];
            }
        }];
            [alctr addAction:qrcode];
        }
        
//        if ([DWDCustInfo shared].isTeacher) {
        UIAlertAction *sendToFriend = [UIAlertAction actionWithTitle:@"发送给朋友" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
//            if ([DWDCustInfo shared].isTeacher) {
            // 转发给朋友
            [DWDChatMsgDataClient sharedChatMsgDataClient].relayingMsg = self.imageMsg;
            if (self.preViewCellDelegate && [self.preViewCellDelegate respondsToSelector:@selector(preViewCellImageRelayToSomeOne)]) {
                [self.preViewCellDelegate preViewCellImageRelayToSomeOne];
                //                }
            }
        }];
        [alctr addAction:sendToFriend];
        //        }
        [[self viewController] presentViewController:alctr animated:YES
                                          completion:nil];
        
        
//        if ([DWDCustInfo shared].isTeacher) {
//            UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
//                                                                delegate:self
//                                                       cancelButtonTitle:@"取消"
//                                                  destructiveButtonTitle:@"保存到相册"
//                                                       otherButtonTitles:@"发送给朋友", nil];
//            action.actionSheetStyle = UIActionSheetStyleDefault;
//            action.tag = 123456;
//            [action showInView:self];
//        }else{
//            UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
//                                                                delegate:self
//                                                       cancelButtonTitle:@"取消"
//                                                  destructiveButtonTitle:@"保存到相册"
//                                                       otherButtonTitles:nil];
//            action.actionSheetStyle = UIActionSheetStyleDefault;
//            action.tag = 123456;
//            [action showInView:self];
//        }
    }
}

#pragma mark - UIActionSheetDelegate
//- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
//{
//    if(actionSheet.tag == 123456 && buttonIndex == 0)
//    {
//        if (self.imageView.image)
//        {
//            UIImageWriteToSavedPhotosAlbum(self.imageView.image,self,@selector(image:didFinishSavingWithError:contextInfo:),nil);
//        }
//        else
//        {
//            DWDMarkLog(@"image is nil");
//        }
//    }else if (buttonIndex == 1){
//        if ([DWDCustInfo shared].isTeacher) {
//            // 转发给朋友
//            [DWDChatMsgDataClient sharedChatMsgDataClient].relayingMsg = self.imageMsg;
//            if (self.preViewCellDelegate && [self.preViewCellDelegate respondsToSelector:@selector(preViewCellImageRelayToSomeOne)]) {
//                [self.preViewCellDelegate preViewCellImageRelayToSomeOne];
//            }
//        }
//    }
//}

-(void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    if (error != NULL)
    {
        [DWDProgressHUD showText:@"图片保存失败"];
        DWDMarkLog(@"%@", error);
    }
    else
    {
        [DWDProgressHUD showText:@"图片保存成功"];
    }
}

#pragma mark - <UIScrollViewDelegate>
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    
    DWDLog(@" %@   , %@ "   , NSStringFromCGSize(scrollView.contentSize) , NSStringFromCGRect(self.imageView.frame));
    
    if (self.imageView.frame.origin.y + self.imageView.frame.size.height - [UIScreen mainScreen].bounds.size.height > 0) {
        
        [scrollView setContentSize:CGSizeMake(scrollView.contentSize.width, self.imageView.frame.origin.y + self.imageView.frame.size.height)];
    }
    
    self.scrollView.scrollEnabled = YES;
    
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?(scrollView.bounds.size.width - scrollView.contentSize.width)/2 : 0.0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?(scrollView.bounds.size.height - scrollView.contentSize.height)/2 : 0.0;
    _imageView.center = CGPointMake(scrollView.contentSize.width/2 + offsetX,scrollView.contentSize.height/2 + offsetY);
}


@end
