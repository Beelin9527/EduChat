//
//  DWDPageView.h
//  06-UIScrollView的分页
//
//  Created by apple on 15/6/24.
//  Copyright (c) 2015年 DWD. All rights reserved.
//

#import <UIKit/UIKit.h>
@class DWDInfoBannerModel;
@protocol DWDPageViewDelegate <NSObject>

@required
- (void)bannerViewDidSeleted:(DWDInfoBannerModel *)model;

@end

@interface DWDBannerView : UIView

@property (weak, nonatomic) id<DWDPageViewDelegate> delegate;

@property (nonatomic, copy) NSArray *dataSource;

@end
