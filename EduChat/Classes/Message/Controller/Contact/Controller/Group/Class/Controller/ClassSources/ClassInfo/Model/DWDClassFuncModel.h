//
//  DWDClassFuncModel.h
//  EduChat
//
//  Created by Catskiy on 2016/10/25.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDClassFuncModel : NSObject

@property (nonatomic , strong) NSNumber *plteId;
@property (nonatomic , strong) NSNumber *plteCd;
@property (nonatomic , strong) NSString *plteNm;
@property (nonatomic , strong) NSNumber *loadTyp;
@property (nonatomic , strong) NSString *ico;
@property (nonatomic , strong) NSString *url;
@property (nonatomic , assign) BOOL isStore;

@end
