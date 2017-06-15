//
//  DWDFaceView.h
//  EduChat
//
//  Created by Gatlin on 16/1/12.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DWDFaceMenuView.h"
#import "DWDFacePageView.h"

@class DWDFaceView;
@protocol DWDFaceViewDelegate <NSObject>

@optional
- (void)faceView:(DWDFaceView *)faceView didSelectPace:(NSString *)paceName;
- (void)faceViewDidSelectDelete:(DWDFaceView *)faceView;
- (void)faceViewDidSelectSend:(DWDFaceView *)faceView;
@end

@interface DWDFaceView : UIView<DWDFacePageViewDelegate,DWDFaceMenuViewDelegate>

@property (nonatomic,weak) id<DWDFaceViewDelegate> delegate;
@end
