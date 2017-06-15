//
//  DWDInfoExpertModel.m
//  EduChat
//
//  Created by Catskiy on 16/8/12.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInfoExpertModel.h"

@implementation DWDInfoExpTagModel


@end

@implementation DWDInfoExpLastArtModel


@end

@implementation DWDInfoExpertModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{ @"tags" : [DWDInfoExpTagModel class],
              @"articles" : [DWDArticleModel class]};
}

@end
