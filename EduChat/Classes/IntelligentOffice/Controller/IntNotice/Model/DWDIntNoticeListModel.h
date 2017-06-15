//
//  DWDIntNoticeListModel.h
//  EduChat
//
//  Created by Beelin on 17/1/5.
//  Copyright © 2017年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDIntNoticeListModel : NSObject
@property (nonatomic, strong) NSNumber *noticeId;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *orgNm;

/*
 是不是觉得creatTime错了，为何不是createTime,以下是后台同事的原话！意思就是错了就要坚持错到底！
 后台同事：按creatTime这个来吧 ，如果改后台，建圣那里都要改，太麻烦 以后我这边注意一下，等下我跟建圣说一下 如果他那边发现类似问题让他提出来
 */
@property (nonatomic, copy) NSString *creatTime;
@end


/*
 参数	类型	含义	说明
 noticeId	Long	通知id
 orgNm	String	发布人所在部门
 cNm	String	发布人
 createTime	String	发布时间	格式：YYYY-MM-DD hh:mm:ss
 title	String	通知标题
 type	Integer	通知类型	1-知道了,2-YES/NO
 readed	Integer	是否已查看	1-已阅0-未阅
 firstPhoto	String	第一张图片
 firstPicture	BasePhotoResult	相片信息
 */
