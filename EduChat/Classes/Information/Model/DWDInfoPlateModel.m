//
//  DWDInfoPlateModel.m
//  EduChat
//
//  Created by Catskiy on 16/8/12.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDInfoPlateModel.h"
#import <YYModel.h>

@implementation DWDInfoPlateModel

- (void)encodeWithCoder:(NSCoder *)aCoder { [self yy_modelEncodeWithCoder:aCoder]; }
- (id)initWithCoder:(NSCoder *)aDecoder { return [self yy_modelInitWithCoder:aDecoder]; }
- (id)copyWithZone:(NSZone *)zone { return [self yy_modelCopy]; }
- (NSUInteger)hash { return [self yy_modelHash]; }
- (BOOL)isEqual:(id)object { return [self yy_modelIsEqual:object]; }

@end
