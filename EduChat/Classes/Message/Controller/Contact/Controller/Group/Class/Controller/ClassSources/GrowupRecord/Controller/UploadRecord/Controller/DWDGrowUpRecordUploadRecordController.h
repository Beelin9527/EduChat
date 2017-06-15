//
//  DWDGrowUpRecordUploadRecordController.h
//  EduChat
//
//  Created by Superman on 15/12/30.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DWDGrowUpRecordUploadRecordControllerDelegate <NSObject>
@required
- (void)DWDGrowUpRecordUploadRecordControllerRightBarBtnClickWithImages:(NSArray *)images
                                                                   text:(NSString *)text
                                                                  logId:(NSNumber *)logId;
- (void)growupRecordUploadControllerShouldRemoveImagesCache;

@end

@interface DWDGrowUpRecordUploadRecordController : UIViewController
@property (nonatomic , strong) NSMutableArray *arrSelectImgs;
@property (nonatomic , weak) id<DWDGrowUpRecordUploadRecordControllerDelegate> rightBarBtnDelegate;
@property (nonatomic , assign) long long myClassAlbumId;

@end
