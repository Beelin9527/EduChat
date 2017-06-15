//
//  DWDGrowUpUploadController.h
//  EduChat
//
//  Created by KKK on 16/9/22.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDGrowUpUploadController, DWDGrowUpModel, PHAsset;

@protocol DWDGrowUpUploadControllerDelegate <NSObject>

@optional
- (void)growUpUploadController:(DWDGrowUpUploadController *)controller didCompleteUploadWithRecord:(DWDGrowUpModel *)model;

@end



@interface DWDGrowUpUploadController : UIViewController

//初始化方法, 当直接进入的时候为nil
- (instancetype)initWithPhotosArray:(NSArray<PHAsset *> *)photosArray;
@property (nonatomic, strong) NSNumber *albumId;

@property (nonatomic, weak) id<DWDGrowUpUploadControllerDelegate> delegate;

@end
