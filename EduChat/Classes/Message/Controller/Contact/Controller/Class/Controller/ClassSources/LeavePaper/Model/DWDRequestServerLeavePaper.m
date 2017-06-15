//
//  DWDRequestServerLeavePaper.m
//  EduChat
//
//  Created by Bharal on 15/12/30.
//  Copyright © 2015年 dwd. All rights reserved.
//

#import "DWDRequestServerLeavePaper.h"

#import "DWDAuthorEntity.h"
#import "DWDNoteEntity.h"
#import "DWDNoteDetailEntity.h"

#import "DWDProgressHUD.h"
@implementation DWDRequestServerLeavePaper

DWDSingletonM(DWDRequestServerLeavePaper);

- (void)requestGetListCustId:(NSNumber *)custId
                     classId:(NSNumber *)classId
                        type:(NSNumber *)type
                   pageIndex:(NSNumber *)pageIndex
                   pageCount:(NSNumber *)pageCount
                     success:(void (^)(id responseObject))success
                     failure:(void (^)(NSError *error))failure
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = NSLocalizedString(@"loading", nil);
    hud.labelColor = [UIColor whiteColor];

    
    [[HttpClient sharedClient] getApi:@"NoteRestService/getList" params:@{DWDCustId:custId,@"classId":classId,@"type":type,@"pageIndex":pageIndex,@"pageCount":pageCount} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hide:YES];
        
        NSMutableArray *arrAuthor = [NSMutableArray array];
        NSMutableArray *arrNote = [NSMutableArray array];

        NSArray *arrNotes = responseObject[DWDApiDataKey][@"notes"];
        for (NSDictionary *dict in arrNotes) {
            
           [arrAuthor addObject:dict[@"author"]];
            [arrNote addObject:dict[@"note"]];
        }
        
        NSArray *arrAuthorEntity = [DWDAuthorEntity initWithArray:arrAuthor];
        NSArray *arrNoteEntity = [DWDNoteEntity initWithArray:arrNote];

        NSDictionary *dictResult = @{@"author":arrAuthorEntity,@"note":arrNoteEntity};
       
        success(dictResult);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        hud.labelText = error.localizedFailureReason;
        [hud hide:YES afterDelay:1.5];
        
        failure(error);
        
    }];

}

- (void)requestGetEntityCustId:(NSNumber *)custId
                       classId:(NSNumber *)classId
                        noteId:(NSNumber *)noteId
                       success:(void (^)(id responseObject))success
                       failure:(void (^)(NSError *error))failure
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = NSLocalizedString(@"loading", nil);
    hud.labelColor = [UIColor whiteColor];
    
    
    [[HttpClient sharedClient] getApi:@"NoteRestService/getEntity" params:@{DWDCustId:custId,@"classId":classId,@"noteId":noteId} success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hide:YES];
        
        DWDNoteDetailEntity *entity = [[DWDNoteDetailEntity alloc]initWithDict:responseObject[DWDApiDataKey]];
        
        success(entity);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        hud.labelText = error.localizedFailureReason;
        [hud hide:YES afterDelay:1.5];
        
        failure(error);
        
    }];

}


- (void)requestApproveNoteCustId:(NSNumber *)custId
                         classId:(NSNumber *)classId
                          noteId:(NSNumber *)noteId
                           state:(NSNumber *)state
                         opinion:(NSString *)opinion
                         success:(void (^)(id responseObject))success
                         failure:(void (^)(NSError *error))failure
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    hud.labelText = NSLocalizedString(@"loading", nil);
    hud.labelColor = [UIColor whiteColor];
    
    /*
    state		int	审批状态
    1-同意
    2-不同意
   
     opinion		String	审批意见
     不同意时必须填写
     */
    NSDictionary *dictParams = @{DWDCustId:custId,@"classId":classId,@"noteId":noteId,@"state":state,@"opinion":opinion};
    
    [[HttpClient sharedClient] postApi:@"NoteRestService/approveNote" params:dictParams success:^(NSURLSessionDataTask *task, id responseObject) {
        
        [hud hide:YES];
        
        success(responseObject[DWDApiDataKey]);
        
    } failure:^(NSURLSessionDataTask *task, NSError *error) {
        
        hud.labelText = error.localizedFailureReason;
        [hud hide:YES afterDelay:1.5];
        
        failure(error);
        
    }];

}
@end
