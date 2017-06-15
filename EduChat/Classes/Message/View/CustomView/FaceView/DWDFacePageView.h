//
//  DWDFacePageView.h
//  EduChat
//
//  Created by Gatlin on 16/1/13.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DWDFacePageView;
@protocol DWDFacePageViewDelegate <NSObject>

@optional
- (void)facePageView:(DWDFacePageView *)facePageView didSelectPace:(NSString *)paceName;    //选中表情
- (void)facePageViewDidSelectDelete:(DWDFacePageView *)facePageView;                        //删除
@end


@interface DWDFacePageView :UIScrollView
- (instancetype)initWithArrayFace:(NSArray *)arrayFace;
@property (nonatomic, weak) id<DWDFacePageViewDelegate> delegateFace;
@end
