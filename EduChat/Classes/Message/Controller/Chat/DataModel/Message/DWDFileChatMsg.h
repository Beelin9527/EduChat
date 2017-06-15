//
//  DWDFileChatMsg.h
//  EduChat
//
//  Created by apple on 1/12/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDBaseChatMsg.h"

@interface DWDFileChatMsg : DWDBaseChatMsg

@property (copy, nonatomic) NSString *fileKey;  // url.
@property (copy, nonatomic) NSString *fileName;  //  本地文件的名称
@property (copy, nonatomic) NSString *fileSuffix;  // 文件后缀

@end
