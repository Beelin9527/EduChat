//
//  DWDNotificationDetailContentCell.m
//  EduChat
//
//  Created by Gatlin on 15/12/10.
//  Copyright © 2015年 dwd. All rights reserved.
//

#define kMaxRow 3
#define kMaxCol 3

#import "DWDNotificationDetailContentCell.h"
#import "UIImage+Utils.h"
#import "DWDImageContentView.h"
#import "DWDGrowUpTouchImageView.h"

#import "UIImage+Utils.h"
#import "UIView+kkk_personalAdd.h"
#import <YYModel.h>
#import <UIImageView+WebCache.h>
#import <Masonry/Masonry.h>

@interface DWDNotificationDetailContentCell ()

@property (weak, nonatomic) IBOutlet UIImageView *imgHeader;
@property (weak, nonatomic) IBOutlet UILabel *labAuthorld;
@property (weak, nonatomic) IBOutlet UILabel *labAddTime;

@property (weak, nonatomic) UIButton *btnIknow;
@property (weak, nonatomic) UIButton *btnYES;
@property (weak, nonatomic) UIButton *btnNO;

@property (weak, nonatomic) UILabel *labContent;
@property (nonatomic, weak) DWDImageContentView *imageContent;
@property (weak, nonatomic) UIImageView *img;
@property (weak, nonatomic) UIView *line;

//图片数组
@property (nonatomic, strong) NSMutableArray *imageArray;
@end
@implementation DWDNotificationDetailContentCell

- (void)awakeFromNib {
    
    
    //设置线条
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(DWDScreenW/2-100,150, 200, DWDLineH)];
    self.line = line;
    line.backgroundColor = DWDColorSeparator;
    [self.contentView addSubview:line];
    
    //设置通知内容
    UILabel *labContent = [[UILabel alloc]init];
    self.labContent = labContent;
    labContent.textColor = DWDColorContent;
    labContent.font = DWDFontContent;
    labContent.numberOfLines = 0;
//    [labContent sizeToFit];
    [self.contentView addSubview:labContent];
 
    
    //设置按钮
    UIButton *btn = [self createButtonTitle:@"我知道了"];
    [btn addTarget:self action:@selector(buttonKnowClick:) forControlEvents:UIControlEventTouchUpInside];
    _btnIknow = btn;
    
    UIButton *btnYES = [self createButtonTitle:@"YES"];
    [btnYES addTarget:self action:@selector(buttonYESClick:) forControlEvents:UIControlEventTouchUpInside];
    _btnYES = btnYES;
    
    UIButton *btnNO = [self createButtonTitle:@"NO"];
    [btnNO addTarget:self action:@selector(buttonNOClick:) forControlEvents:UIControlEventTouchUpInside];
    _btnNO = btnNO;
    
    
    //设置图片
    UIImageView *img = [[UIImageView alloc]init];
    self.img = img;
    img.image = [UIImage imageNamed:@"bg_notice_notification_details"];
    [self.contentView addSubview:img];
    
    DWDImageContentView *imageContent = [[DWDImageContentView alloc] init];
    self.imageContent = imageContent;
    [self.contentView addSubview:imageContent];
}

#pragma mark - private method
- (BOOL)postRequstWithState:(int)state {
    NSDictionary *params = @{@"custId": [DWDCustInfo shared].custId,
                             @"classId": self.classId,
                             @"noticeId": self.noticeId,
                             @"item": [NSNumber numberWithInt:state]};
//    - (void)buttonKnowClick:(UIButton *)button {
//        if ([self postRequstWithState:2]) {
//            [self setButtonUserInteractionDisabled:button];
//        }
//    }
//    - (void)buttonYESClick:(UIButton *)button {
//        if ([self postRequstWithState:1]) {
//            [self setButtonUserInteractionDisabled:_btnYES];
//            [self setButtonUserInteractionDisabled:_btnNO];
//        }
//    }
//    
//    - (void)buttonNOClick:(UIButton *)button {
//        if ([self postRequstWithState:0]) {
//            [self setButtonUserInteractionDisabled:_btnYES];
//            [self setButtonUserInteractionDisabled:_btnNO];
//        }
//    }
    
    UIViewController *vc = [self viewController];
    
//    MBProgressHUD *hud = [[MBProgressHUD alloc] initWithView:vc.view];
    MBProgressHUD *hud =[MBProgressHUD showHUDAddedTo:vc.view animated:YES];
    hud.labelText = @"请稍候";
    dispatch_async(dispatch_get_main_queue(), ^{
        [hud show:YES];
    });
    WEAKSELF;
    [[HttpClient sharedClient] postUpdateClassNotificationReplyState:params success:^(NSURLSessionDataTask *task, id responseObject) {
        
        switch (state) {
            case 2:
                [weakSelf setButtonUserInteractionDisabled:weakSelf.btnIknow];
                break;
                
            default:
                [weakSelf setButtonUserInteractionDisabled:weakSelf.btnYES];
                [weakSelf setButtonUserInteractionDisabled:weakSelf.btnNO];
                break;
        }
        
        NSMutableArray *commitAr;
        NSMutableArray *originAr;
        NSDictionary *selfInfo = @{
                                   @"custId" : [DWDCustInfo shared].custId,
                                   @"name" : [DWDCustInfo shared].custNickname,
                                   @"photoKey" : [DWDCustInfo shared].custOrignPhotoKey,
                                   };
        NSMutableDictionary *dict = [weakSelf.dictDataSource mutableCopy];
        NSMutableDictionary *replyDict = [dict[@"replys"] mutableCopy];
        if (state == 0) {
            //添加到NO
            commitAr = [(NSArray *)weakSelf.dictDataSource[@"replys"][@"unjoins"] mutableCopy];
            [commitAr addObject:selfInfo];
//            weakSelf.dictDataSource[@"replys"][@"unjoins"] = commitAr;
            [replyDict setObject:commitAr forKey:@"unjoins"];
        } else if (state == 1) {
            //添加到YES
            commitAr = [(NSArray *)weakSelf.dictDataSource[@"replys"][@"joins"] mutableCopy];
            [commitAr addObject:selfInfo];
//            weakSelf.dictDataSource[@"replys"][@"joins"] = commitAr;
//            [weakSelf.dictDataSource[@"replys"] setValue:commitAr forKeyPath:@"joins"];
            [replyDict setObject:commitAr forKey:@"joins"];
        } else if (state == 2) {
            //添加到已读
            commitAr = [(NSArray *)weakSelf.dictDataSource[@"replys"][@"readeds"] mutableCopy];
            originAr = [(NSArray *)weakSelf.dictDataSource[@"replys"][@"unreads"] mutableCopy];
            [commitAr addObject:selfInfo];
            NSInteger index = -1;
            for (id obj in originAr) {
                if ([obj[@"custId"] isEqualToNumber:[DWDCustInfo shared].custId]) {
                    index = [originAr indexOfObject:obj];
                    break;
                }
            }
            
            if (index != -1) {
                [originAr removeObjectAtIndex:index];
            }
            [replyDict setObject:commitAr forKey:@"readeds"];
            [replyDict setObject:originAr forKey:@"unreads"];
        }
        [dict setObject:replyDict forKey:@"replys"];
//        NSMutableDictionary *noteDict = dict[@"notice"];
//        [noteDict setObject:@0 forKey:@"type"];
//        [dict setObject:noteDict forKey:@"notice"];
        weakSelf.dictDataSource = dict;

        if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(cell:shouldReloadDataWithDataSource:)]) {
            [weakSelf.delegate cell:weakSelf shouldReloadDataWithDataSource:weakSelf.dictDataSource];
        }
        DWDMarkLog(@"response:%@", responseObject);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
        });
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        DWDMarkLog(@"error:%@", error);
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hide:YES];
        });
    }];
    
    return YES;
}

- (void)setButtonUserInteractionDisabled:(UIButton *)button {
    button.userInteractionEnabled = NO;
    [button setBackgroundImage:[UIImage imageWithColor:DWDRGBColor(221, 221, 221)] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button setNeedsDisplay];
}


- (void)setAvailableButton:(UIButton *)button {
    button.userInteractionEnabled = YES;
    [button setBackgroundImage:[UIImage imageWithColor:DWDColorMain] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageWithColor:DWDColorContent] forState:UIControlStateSelected];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)setDisabledButton:(UIButton *)button {
    [self setButtonUserInteractionDisabled:button];
}


#pragma mark - event response

//event response and set button cannot click
- (void)buttonKnowClick:(UIButton *)button {
//    if ([self postRequstWithState:2]) {
//        [self setButtonUserInteractionDisabled:button];
//    }
    [self postRequstWithState:2];
}
- (void)buttonYESClick:(UIButton *)button {
//    if ([self postRequstWithState:1]) {
//        [self setButtonUserInteractionDisabled:_btnYES];
//        [self setButtonUserInteractionDisabled:_btnNO];
//    }
    [self postRequstWithState:1];
}

- (void)buttonNOClick:(UIButton *)button {
//    if ([self postRequstWithState:0]) {
//        [self setButtonUserInteractionDisabled:_btnYES];
//        [self setButtonUserInteractionDisabled:_btnNO];
//    }
    [self postRequstWithState:0];
}

- (void)setDictDataSource:(NSDictionary *)dictDataSource
{
    _dictDataSource = dictDataSource;
    [_imgHeader sd_setImageWithURL:[NSURL URLWithString:dictDataSource[@"author"][@"photoKey"]] placeholderImage:[UIImage imageNamed:@"AvatarMe"]];
    _labAuthorld.text = dictDataSource[@"author"][@"name"];
    _labAddTime.text = dictDataSource[@"author"][@"addTime"];
    _labContent.text = dictDataSource[@"notice"][@"content"];
    CGSize labContentSize = [_labContent.text boundingRectWithfont:_labContent.font sizeMakeWidth:(DWDScreenW - pxToW(20)*4)];
    _labContent.frame = CGRectMake(pxToW(20), CGRectGetMaxY(self.line.frame)+15, labContentSize.width, labContentSize.height);
    DWDLog(@"%@",NSStringFromCGRect(_labContent.frame));
    
    _imageContent.frame = _labContent.frame;
    //图片内容
    NSMutableArray *photoArray = [NSMutableArray array];
    for (NSDictionary *dict in dictDataSource[@"notice"][@"photos"]) {
        [photoArray addObject:[DWDPhotoMetaModel yy_modelWithDictionary:dict[@"photo"]]];
    }
    
    if (photoArray != nil && photoArray.count != 0) {
        
        //获取图片地址 保存图片
        //数组中每个都有两个字典:(id:xx, photoKey:xx)
        self.imageArray = [NSMutableArray new];
        for (int i = 0; i < photoArray.count; i ++) {
            DWDPhotoMetaModel *photo = photoArray[i];
            
            DWDGrowUpTouchImageView *imageView = [DWDGrowUpTouchImageView new];
            imageView.contentMode = UIViewContentModeScaleAspectFill;
            WEAKSELF;
            __weak DWDGrowUpTouchImageView *weakImageView = imageView;
            imageView.tapBlock = ^(UITapGestureRecognizer *tapGestureRecognizer) {
                if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(cell:didClickImageView:AtIndex:)]) {
                    [weakSelf.delegate cell:weakSelf didClickImageView:weakImageView AtIndex:i];
                }
            };
            [imageView sd_setImageWithURL:[NSURL URLWithString:[photo thumbPhotoKey]] placeholderImage:DWDDefault_MeBoyImage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                if (image) {
                    imageView.userInteractionEnabled = YES;
                }
            }];
            [self.imageArray addObject:imageView];
        }
        
        
        CGFloat imageWidth = (DWDScreenW - pxToW(20) * 4 - pxToW(10) * 3) / 3.0;
        CGFloat imageHeight = imageWidth;
        CGRect imageFrame = CGRectZero;
        CGRect lastRect = CGRectZero;
        for (int row = 0; row < self.imageArray.count / kMaxCol + 1; row ++) {
            for (int col = 0; col < (self.imageArray.count - row * kMaxCol) && col < kMaxCol; col ++) {
                UIImageView *currentImageView = [UIImageView new];
                currentImageView = self.imageArray[row * 3 + col];
                imageFrame.size = CGSizeMake(imageWidth, imageHeight);
                imageFrame.origin.x = col * (pxToW(10) + imageWidth);
                imageFrame.origin.y = row * (pxToH(10) + imageHeight);
                currentImageView.frame = imageFrame;
                lastRect = imageFrame;
                [self.imageContent addSubview:currentImageView];
            }
        }
        
        
        CGFloat imageContentHeight = CGRectGetMaxY(lastRect);
        self.imageContent.frame = CGRectMake(pxToW(20), CGRectGetMaxY(_labContent.frame)+pxToH(40), self.contentView.size.width - pxToW(20) * 2, imageContentHeight);
    }
    
    
    UIButton *btn ;
    
    self.type = dictDataSource[@"notice"][@"type"];
    
    
//    if ([type isEqual:@1] && ![[DWDCustInfo shared].custId isEqual:self.dictDataSource[@"author"][@"authorId"]]) {
//        //available
//        [self setAvailableButton:btn];
//    } else {
//        //disabled
//        [self setDisabledButton:btn];
//    }
    
    
    
    if ([self.type isEqualToNumber:@1]) {
        
        _btnIknow.frame = CGRectMake(DWDScreenW/2-DWDPadding*5-10, CGRectGetMaxY(_imageContent.frame) + 20,100, DWDPadding*4);
        _btnIknow.layer.masksToBounds = YES;
        _btnIknow.layer.cornerRadius = self.btnIknow.frame.size.height/2;
        
        btn = self.btnIknow;
        
        if ([self.readed isEqual:@0]) {
            [self setAvailableButton:_btnIknow];
        } else {
            [self setDisabledButton:_btnIknow];
        }
    }else{
        _btnYES.frame = CGRectMake(DWDScreenW/4-DWDPadding*5-10, CGRectGetMaxY(_imageContent.frame) + 20,100, DWDPadding*4);
        _btnYES.layer.masksToBounds = YES;
        _btnYES.layer.cornerRadius = self.btnYES.frame.size.height/2;
        
        _btnNO.frame = CGRectMake(DWDScreenW/4*3-DWDPadding*5-10, CGRectGetMaxY(_imageContent.frame) + 20,100, DWDPadding*4);
        _btnNO.layer.masksToBounds = YES;
        _btnNO.layer.cornerRadius = self.btnNO.frame.size.height/2;
        
        if ([self.readed isEqual:@0]) {
            [self setAvailableButton:_btnYES];
            [self setAvailableButton:_btnNO];
        } else {
            [self setDisabledButton:_btnYES];
            [self setDisabledButton:_btnNO];
        }
        
        btn = self.btnYES;
    }
    
    [_img makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.centerX);
        make.height.equalTo(@5);
        make.width.equalTo(@355);
        make.top.equalTo(@(CGRectGetMaxY(btn.frame)+20));
        
    }];


    //cell height
     _notiDetailContentHight = CGRectGetMaxY(btn.frame)+25;
}


// create btn
- (UIButton *)createButtonTitle:(NSString *)title
{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setTitle:title forState:UIControlStateNormal];
    [self.contentView addSubview:btn];
    
    return btn;

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setFrame:(CGRect)frame
{
    CGRect F = frame;
    F.origin.x += 10;
    F.size.width -= 20;
    F.origin.y -= 10;
    [super setFrame:F];
}
@end
