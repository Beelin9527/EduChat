//
//  UIActionSheet+camera.m
//  EduChat
//
//  Created by Gatlin on 16/5/12.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "UIActionSheet+camera.h"
#import <objc/runtime.h>

@implementation UIActionSheet (camera)

//关联属性，给分类添加属性
- (void)setTarger:(id)targer
{
    objc_setAssociatedObject(self, @selector(targer), targer, OBJC_ASSOCIATION_ASSIGN);
}

- (id)targer
{
    return objc_getAssociatedObject(self, @selector(targer));
}


+ (instancetype)showCameraActionSheet
{
    //在这里呼出下方菜单按钮项
    UIActionSheet *cameraActionSheet = [[UIActionSheet alloc]
                                    initWithTitle:nil
                                    delegate:nil
                                    cancelButtonTitle:@"取消"
                                    destructiveButtonTitle:nil
                                    otherButtonTitles: @"打开照相机", @"从手机相册获取",nil];
    
    cameraActionSheet.delegate = cameraActionSheet;
    return cameraActionSheet;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    
    //呼出的菜单按钮点击后的响应
    if (buttonIndex == actionSheet.cancelButtonIndex)
    {
        DWDLog(@"取消");
    }
    
    switch (buttonIndex)
    {
        case 0:  //打开照相机拍照
            [self takePhoto];
            break;
            
        case 1:  //打开本地相册
            [self LocalPhoto];
            break;
    }
}


//开始拍照
-(void)takePhoto
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self.targer;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        
        [self.targer presentViewController:picker animated:YES completion:nil];
        
    }else
    {
        DWDLog(@"模拟其中无法打开照相机,请在真机中使用");
    }
}

//打开本地相册
-(void)LocalPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self.targer;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    
    [self.targer presentViewController:picker animated:YES completion:nil];
}


@end
