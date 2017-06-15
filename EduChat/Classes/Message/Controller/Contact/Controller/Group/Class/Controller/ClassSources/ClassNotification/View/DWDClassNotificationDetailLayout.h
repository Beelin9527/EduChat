//
//  DWDClassNotificationDetailLayout.h
//  EduChat
//
//  Created by KKK on 16/5/4.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class YYTextLayout;
@class DWDClassNotificationDetailModel;

#define kContentCellPadding 10
//#define kContentCellImageWH pxToW(80)
#define kContentCellImageWH 40
//#define kContentCellTitleTopPadding pxToW(24)
#define kContentCellTitleTopPadding 12
#define kContentCellContentTopPadding 15
#define kContentCellSingleButtonHeight 40
#define kContentCellSingleButtonWidth (DWDScreenW - 37.5 * 2)
#define kContentCellDoubleButtonWidth (DWDScreenW - 37.5 * 3) * 0.5f

#define kContentCellSinglePicWidth pxToW(300)
#define kContentCellDoublePicsWidth pxToW(260)
#define kContentCellThreePicsWidth (DWDScreenW - 30) / 3.0f
#define kContentCellThreePicsMargin 5

#define kReplyCellSegmentHeight 44
#define kReplyCellLeftPadding 20
#define kReplyCellOtherPadding 21

#define kCellTitleColor DWDRGBColor(51, 51, 51)
#define kCellNameColor DWDRGBColor(153, 153, 153)
#define kCellSelectedTitleColor DWDRGBColor(90, 136, 231)
#define kCellUnSelectedTitleColor DWDRGBColor(102, 102, 102)

#define kCellTitleFont [UIFont systemFontOfSize:16]
#define kCellNameFont [UIFont systemFontOfSize:12]
#define kCellSegmentFont [UIFont systemFontOfSize:14]

@interface DWDClassNotificationDetailLayout : NSObject

@property (nonatomic, strong) YYTextLayout *contentLayout;
@property (nonatomic, assign) CGFloat contentLabelHeight;
@property (nonatomic, assign) CGFloat imagesHeight;
@property (nonatomic, assign) CGFloat contentHeight;

@property (nonatomic, assign) CGFloat completeHeight;
@property (nonatomic, assign) CGFloat uncompleteHeight;
@property (nonatomic, assign, getter=isCompleteSelected) BOOL completeSelected;

@property (nonatomic, assign, getter=isCompleteBlank) BOOL completeBlank;
@property (nonatomic, assign, getter=isUnCompleteBlank) BOOL unCompleteBlank;

@property (nonatomic, strong) DWDClassNotificationDetailModel *model;

- (instancetype)initWithModel:(DWDClassNotificationDetailModel *)model;
@end
