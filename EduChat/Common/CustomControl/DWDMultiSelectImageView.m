//
//  DWDMultiSelectImageView.m
//  EduChat
//
//  Created by Gatlin on 15/12/29.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDMultiSelectImageView.h"

#define KColumn 4
#define KButtonWidth  70 *  DWDScreenW/320
#define KImgSize CGSizeMake(KButtonWidth,KButtonWidth)
#define KImgPadding  (DWDScreenW - KColumn * KButtonWidth)/(KColumn +1)
@interface DWDMultiSelectImageView()

@end
@implementation DWDMultiSelectImageView

+ (instancetype)multiSelectImageView
{
    DWDMultiSelectImageView *multiSelectImageView = [[DWDMultiSelectImageView alloc]init];
    return multiSelectImageView;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.arrImages = [NSMutableArray array];
        
        }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {

        self.backgroundColor = [UIColor clearColor];
        
        self.arrImages = [NSMutableArray array];
    }
    return self;
}

- (void)setArrImages:(NSMutableArray *)arrImages
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UILabel *lab = [[UILabel alloc]init];
    lab.text = @"添加图片";
    lab.textColor = DWDColorContent;
//    lab.font = DWDFontBody;
    lab.font = [UIFont systemFontOfSize:14];
    lab.frame = CGRectMake(10, 10, 100, 25);
    [self addSubview:lab];

    
    if (arrImages.count < 9) {
        [arrImages addObject:[UIImage imageNamed:@"btn_add_image_new_record_normal"]];
    }
    _arrImages = arrImages;
    
    int col = 0;
    int row = 0;
    int paddingx = KImgPadding;
    int paddingOY = 40;
    int paddingY = 10;
    int btnX = 0;
    int btnY = 0;
    
    for (int i = 0; i < arrImages.count; i ++) {
        
        col = i % KColumn;
        row = i / KColumn;
        
        btnX = (col + 1) * paddingx + col * (KImgSize.width);
        btnY = paddingOY + row * (KImgSize.height) +  row * paddingY;
        
        UIButton *btn = [[UIButton alloc] init];
        btn.contentMode = UIViewContentModeScaleAspectFill;
        btn.frame = CGRectMake(btnX, btnY, KImgSize.width, KImgSize.height);
        
        [btn setBackgroundImage:arrImages[i] forState:UIControlStateNormal];
        [self addSubview:btn];
        
        //if button is addButton
        if ((i == arrImages.count-1) && (arrImages.count < 10)) {
            [btn addTarget:self action:@selector(openPhoto) forControlEvents:UIControlEventTouchDown];
        }
    }
    
    //setup self frame
    int num =  arrImages.count % KColumn == 0 ? (int)(arrImages.count / KColumn) : (int)(arrImages.count / KColumn + 1);
    [self setH: paddingOY + num * (KImgSize.height) +  num * paddingY];

}

- (void)openPhoto
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(multiSelectImageViewDidSelectAddButton:)]) {
        [self.delegate multiSelectImageViewDidSelectAddButton:self];
    }
    
    /*
     * please in delegate method write this code
     
     #import "JFImagePickerController.h"
     
     <JFImagePickerDelegate>
     
    JFImagePickerController *picker = [[JFImagePickerController alloc] initWithRootViewController:nil];
    picker.pickerDelegate = self;
    
    [self.delegate presentViewController:picker animated:YES completion:nil];
     */
}
@end
