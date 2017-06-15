//
//  DWDLocalizedIndexedCollation.m
//  EduChat
//
//  Created by Gatlin on 16/2/3.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDLocalizedIndexedCollation.h"
#import <YYModel/YYModel.h>
@interface DWDLocalizedIndexedCollation()

@end

@implementation DWDLocalizedIndexedCollation

+ (instancetype)currentCollation
{
    DWDLocalizedIndexedCollation *collation = [[DWDLocalizedIndexedCollation alloc] init];
    return collation;
}

- (instancetype)init
{
    if (self = [super init]) {
        _localizedIndexedCollation = [UILocalizedIndexedCollation currentCollation];
    }
    return self;
}
#pragma mark - Setter
- (void)setArrDataSource:(NSArray *)arrDataSource
{
    _arrDataSource = arrDataSource;
    
    //英文和中文、是27区。  “A、B、C.....#" 26字母加#号、27区
    NSInteger sectionTitlesCount = [[self.localizedIndexedCollation sectionTitles] count];
    
    //初始化一个数据、空间大小27组
    NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    
    _arrSectionsArray = newSectionsArray;
    
    //初始化27个空数组加入newSectionsArray
    for (NSInteger index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [newSectionsArray addObject:array];
    }
    
    //将每个人按name分到某个section下
    for (id model in arrDataSource) {
       
       NSMutableDictionary *dict = [model yy_modelToJSONObject];
        //判断是否有备注，无则用nickname;
        NSString *str =  [[[DWDPersonDataBiz alloc] init] checkoutExistRemarkName:dict[@"remarkName"] nickname:dict[@"nickname"]];
        //获取name属性的值所在的位置，比如"林丹"，首字母是L，在A~Z中排第11（第一位是0），sectionNumber就为11
        if ([str isEqualToString:@""] || !str) {
            continue;
        }
        NSInteger sectionNumber = [self.localizedIndexedCollation sectionForObject:str collationStringSelector:@selector(uppercaseString)];
        //加入newSectionsArray中
        NSMutableArray *sectionNames = newSectionsArray[sectionNumber];
        [sectionNames addObject:dict];
    }
}
@end
