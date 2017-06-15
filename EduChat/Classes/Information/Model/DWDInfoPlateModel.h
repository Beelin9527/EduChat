//
//  DWDInfoPlateModel.h
//  EduChat
//
//  Created by Catskiy on 16/8/12.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  资讯板块类型
 */
typedef NS_ENUM(NSUInteger, InfoPlateType) {
    /**
     *  推荐
     */
    InfoPlateTypeRecomment = 1,
    /**
     *  新闻
     */
    InfoPlateTypeNewAndPolicy,
    /**
     *  专家
     */
    InfoPlateTypeUenonExpert,
    /**
     *  订阅
     */
    InfoPlateTypeSubscribe,
};

@interface DWDInfoPlateModel : NSObject

@property (nonatomic, assign) BOOL isDefault;           // 是否默认
@property (nonatomic, assign) BOOL isStore;             // 是否缓存
@property (nonatomic, assign) InfoPlateType plateCode;  // 板块类型
@property (nonatomic, strong) NSNumber *plateId;        // 板块ID
@property (nonatomic, strong) NSString *plateName;      // 板块名称
@property (nonatomic, strong) NSNumber *style;          // 风格
@property (nonatomic, assign) BOOL showBadge;           // 是否显示小红点

@end
