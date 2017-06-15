//
//  DWDImageChatMsg.h
//  EduChat
//
//  Created by apple on 1/12/16.
//  Copyright © 2016 dwd. All rights reserved.
//

#import "DWDFileChatMsg.h"

@interface DWDImageChatMsg : DWDFileChatMsg

@property (nonatomic, strong) DWDPhotoMetaModel *photo;

@property (nonatomic , assign) BOOL receiving;

@end
