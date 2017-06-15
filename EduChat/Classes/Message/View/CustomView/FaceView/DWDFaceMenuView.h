//
//  DWDFaceMenuView.h
//  EduChat
//
//  Created by Gatlin on 16/1/13.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDFaceMenuView;
@protocol DWDFaceMenuViewDelegate <NSObject>

@optional
- (void)faceMenuViewSendData:(DWDFaceMenuView *)faceMenuView;

@end


@interface DWDFaceMenuView : UIView

@property (weak, nonatomic) id <DWDFaceMenuViewDelegate> delegate;
@end
