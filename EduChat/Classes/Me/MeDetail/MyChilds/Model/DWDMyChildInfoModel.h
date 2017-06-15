//
//  DWDMyChildsInfoModel.h
//  EduChat
//
//  Created by Gatlin on 16/4/7.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DWDMyChildInfoModel : NSObject
/**
 参数	类型	说明
 "childCustId": 5010000010015,
 "childName": "苏轼7",
 "childEduAcct": "sushi7",
 "childPhotoKey": "edu",
 "gender": 1,
 "type": "22",
 */

@property (strong, nonatomic) NSNumber *childCustId;
@property (strong, nonatomic) NSNumber *gender;
@property (strong, nonatomic) NSNumber *type;
@property (copy, nonatomic) NSString *childEduAcct;
@property (copy, nonatomic) NSString *childName;
@property (copy, nonatomic) NSString *childPhotoKey;

@end


@interface DWDMyChildSchoolsModel : NSObject
@property (copy, nonatomic) NSString *schoolName;
@property (strong, nonatomic) NSArray *classInfo;
@end

@interface DWDMyChildClassInfoModel : NSObject
@property (copy, nonatomic) NSString *classId;
@property (copy, nonatomic) NSString *className;
@end


/*   努力让自己不要哭出来

 {
    "result": "1",
    "errorcode": "0000000000",
    "errordesc": "",
    "data": {
        "childInfo": {
            "childCustId": 5010000010015,
            "childName": "小龙龙",
            "childEduAcct": "sushi7",
            "childPhotoKey": "http://educhat.oss-cn-hangzhou.aliyuncs.com/856f4611-8c0d-49a0-931b-af8561edb612",
            "gender": 1,
            "type": "22"
        },
        "schools": [
            {
                "schoolName": "新庄艺术幼儿园",
                "classInfo": [
                    {
                        "classId": 8010000001104,
                        "className": "二(1)班"
                    }
                ]
            },
            {
                "schoolName": "广州市政府机关幼儿园北区",
                "classInfo": [
                    {
                        "classId": 8010000001188,
                        "className": "大(4)班"
                    }
                ]
            }
        ]
    }
}
 */


