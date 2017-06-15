

#import <UIKit/UIKit.h>


UIKIT_EXTERN NSString *const DWDClassInfoBottomViewChangeBtnClick;
UIKIT_EXTERN NSString *const DWDClassInfoBottomViewAndMenuShouldHide;

UIKIT_EXTERN NSString *const DWDDWDCityNameDidSelectNotification;
UIKIT_EXTERN NSString *const DWDSearchSchoolAndClassControllerSelectSchoolNotification;


// account api keys
UIKIT_EXTERN NSString *const DWDCustId;
UIKIT_EXTERN NSString *const DWDFriendId;
UIKIT_EXTERN NSString *const DWDNickname;
UIKIT_EXTERN NSString *const DWDGroupId;
UIKIT_EXTERN NSString *const DWDApiDataKey;
UIKIT_EXTERN NSString *const DWDPhotoKey;
UIKIT_EXTERN NSString *const DWDLastModifyDate;
UIKIT_EXTERN NSString *const DWDState;
UIKIT_EXTERN NSString *const DWDAccountNo;
UIKIT_EXTERN NSString *const DWDExtensions;
UIKIT_EXTERN NSString *const DWDRemark;
UIKIT_EXTERN NSString *const DWDPhotoAuth;
UIKIT_EXTERN NSString *const DWDIsBlackList;
UIKIT_EXTERN NSString *const DWDEducation;
UIKIT_EXTERN NSString *const DWDProperty;
UIKIT_EXTERN NSString *const DWDEnterpriseId;
UIKIT_EXTERN NSString *const DWDSignature;



UIKIT_EXTERN NSString *const kDWDApiBaseUrl;
UIKIT_EXTERN NSString *const kDWDXcomBaseUrl;
UIKIT_EXTERN uint16_t const kDWDXcomPort;
UIKIT_EXTERN NSString *const kDWDErrorDomain;
UIKIT_EXTERN NSString *const kDWDDBErrorDomain;


UIKIT_EXTERN NSString *const DWDGetVerifyCodeRegisterType;
UIKIT_EXTERN NSString *const DWDGetVerifyCodeFindPwdType;

#pragma mark - 本地缓存名
UIKIT_EXTERN NSString *const DWDLoginState;                     //登录状态
UIKIT_EXTERN NSString *const DWDLoginCustIdCache;               //CustId缓存
UIKIT_EXTERN NSString *const kDWDOrignPwdCache;                 //原始密码
UIKIT_EXTERN NSString *const kDWDMD5PwdCache;                   //md5密码缓存
UIKIT_EXTERN NSString *const kDWDEncryptPwdCache;               //加密密码缓存
UIKIT_EXTERN NSString *const DWDUserNameCache;                  //帐号缓存
UIKIT_EXTERN NSString *const DWDCustInfoData;

/**
 *   登录请求信息 缓存名
 *  NSDictionary
 *  encryptToken 加密Token
 *  uid          登录时接口返回uid
 */
UIKIT_EXTERN NSString *const kDWDRequestHeaderInfoCache;


#pragma mark - 通知名
/** 执行登录 */
UIKIT_EXTERN NSString *const kDWDNotificationExecuteLogin;
/** 会话列表 加载、刷新 通知名 */
UIKIT_EXTERN NSString *const kDWDNotificationRecentChatLoad;
/** 会话列表  是否需要刷新会话列表 通知名 */
UIKIT_EXTERN NSString *const kDWDNotificationNeedRecentChatLoad;
/** 会话列表 删除行数据 通知名 */
UIKIT_EXTERN NSString *const kDWDNotificationDeleteRowRecentChat;
/** 本地库 通讯录 通知名 */
UIKIT_EXTERN NSString *const DWDNotificationContactUpdate;        //通讯录 更新
UIKIT_EXTERN NSString *const DWDNotificationContactsGet;          //获取联系人通知
/** 本地库 群组 通知名 */
UIKIT_EXTERN NSString *const DWDNotificationGroupListReload;      //群组列表 刷新
/** 本地库 班级 通知名 */
UIKIT_EXTERN NSString *const kDWDNotificationClassListReload;

/** 实时更新班级头像 通知名 */
UIKIT_EXTERN NSString *const kDWDChangeClassPhotoKeyNotification;
/** 实时更新群组头像 通知名 */
UIKIT_EXTERN NSString *const kDWDChangeGroupPhotoKeyNotification;
/** 实时更新群组昵称 通知名 */
UIKIT_EXTERN NSString *const kDWDChangeGroupNicknameNotification;
/** 实时更新联系人头像 通知名 */
UIKIT_EXTERN NSString *const kDWDChangeContactPhotoKeyNotification;
/** 实时更新联系人昵称 通知名 */
UIKIT_EXTERN NSString *const kDWDChangeContactNicknameNotification;

/** 显示小红点 通知名 */
UIKIT_EXTERN NSString *const kDWDNotificationShowRed;

/** app 将退出后台 */
UIKIT_EXTERN NSString *const kDWDAppWillResignActive;
/** app 将进入前台 */
UIKIT_EXTERN NSString *const kDWDAppWillEnterForeground;

/** 进入前台时 从数据库获取到存在未读消息 , 刷新聊天界面 */
UIKIT_EXTERN NSString *const kDWDNotificationEnterAppReloadUnreadMsg;

/** 被迫下线*/
UIKIT_EXTERN NSString *const kDWDNotificationCrowdedUserOffline;

/** 更新菜单变更 */
UIKIT_EXTERN NSString *const kDWDNotificationSmartOAMenu;
/** 更新智能办公 classModel */
UIKIT_EXTERN NSString *const kDWDNotificationClassManagerClassModel;

/** 登录者身份 */
UIKIT_EXTERN NSString *const kDWDNotificationChangeLoginIdentify;

/** 网络状态 根据状态是否显示会话列表HeaderView描述 通知名 */
UIKIT_EXTERN NSString *const kDWDNotificationNetState;

/** 需要刷新recentChat的lastContent */
UIKIT_EXTERN NSString *const DWDNotificationRecentChatLastContentNeedChange;

/** 用户资料 刷新 通知名 */
UIKIT_EXTERN NSString *const DWDNotificationPersonDataReload;

/** 在聊天界面当中 接收到系统消息有好友、群、班 对自己进行删除操作 需从当前聊天界面返回会话列表界面 通知名 */
UIKIT_EXTERN NSString *const DWDNotificationShowAlert;
/** 有聊天消息被撤回 通知名 */
UIKIT_EXTERN NSString *const DWDNotificationHaveMsgRevoked;
/** 有班级中的聊天消息被班主任删除 通知名 */
UIKIT_EXTERN NSString *const DWDNotificationClassManagerDeleteMsg;
/** 刷新聊天控制器 数据 */
UIKIT_EXTERN NSString *const DWDNotificationSystemMessageReload;


/** 当前聊天界面插入离线未读消息 */
UIKIT_EXTERN NSString *const kDWDNotificationInsertUnreadMsgToChatVC;

/** 聊天界面图片预览点击大图返回聊天界面时 , 通知聊天控制器恢复状态栏 */
UIKIT_EXTERN NSString *const kDWDNotificationChatPreViewCellImageViewTap;
UIKIT_EXTERN NSString *const kDWDNotificationChatPreViewCellDidRelayToSomeone;

/** 聊天界面转发消息 , 发通知判断是否发给当前的toUser */
UIKIT_EXTERN NSString *const kDWDNotificationChatRelayJudgeCurrentTouser;

/** 登陆状态改变时刷新咨询模块 */
UIKIT_EXTERN NSString *const kDWDNotificationRefreshInformation;

/** 聊天视频全屏时回收键盘 */
UIKIT_EXTERN NSString *const kDWDNotificationChatVideoPlay;
UIKIT_EXTERN NSString *const kDWDNotificationChatNeedInsertTimeMsg;

#pragma mark - 系统消息字段
UIKIT_EXTERN NSString *const kDWDSysmsgNewFriendverify;     //好友申请
UIKIT_EXTERN NSString *const kDWDSysmsgFriendverifyPassed;  // 拒绝我添加好友
UIKIT_EXTERN NSString *const kDWDSysmsgFriendverifyFailed;  // 通过我添加好友
UIKIT_EXTERN NSString *const kDWDSysmsgDeleteFriend;     // 删除好友

UIKIT_EXTERN NSString *const kDWDSysmsgDeleteFriendChatKey;     // 删除好友

UIKIT_EXTERN NSString *const kDWDSysmsgNewClassMemberverify;    // 加入班级验证信息
UIKIT_EXTERN NSString *const kDWDSysmsgClassMemberverifyPassed; //谁加入班级
UIKIT_EXTERN NSString *const kDWDSysmsgClassMemberverifyRefused; //谁拒绝我加入班级
UIKIT_EXTERN NSString *const kDWDSysmsgDeleteClassMember; //删除班级成员
UIKIT_EXTERN NSString *const kDWDSysmsgDeleteClass;  // 删除班级 只有班主有权操作
UIKIT_EXTERN NSString *const kDWDSysmsgMemberQuitClass; //班级成员主动退出

UIKIT_EXTERN NSString *const kDWDSysmsgAddGroupMember;      // 添加群组成员
UIKIT_EXTERN NSString *const kDWDSysmsgDeleteGroupMember;   // 删除群组成员
UIKIT_EXTERN NSString *const kDWDSysmsgDeleteGroup;         // 删除群组
UIKIT_EXTERN NSString *const kDWDSysmsgMemberQuitGroup;     // 成员主动退出群组

UIKIT_EXTERN NSString * const kDWDSysmsgContextual;         // 接送中心
UIKIT_EXTERN NSString * const kDWDSysmsgUpdateClass;        // 实时更新班级的头像
UIKIT_EXTERN NSString * const kDWDSysmsgUpdateGroup;        // 实时更新群组的头像或者昵称
UIKIT_EXTERN NSString * const kDWDSysmsgUpdateContact;
UIKIT_EXTERN NSString * const kDWDSysmsgCrowdedUserOffline; // 被迫下线
UIKIT_EXTERN NSString * const kDWDSysmsgRevokeMsg;

UIKIT_EXTERN NSString * const kDWDSysmsgMenu;  // 菜单变更系统消息

#pragma mark - 接送中心通知
UIKIT_EXTERN NSString *const DWDPickUpCenterDidUpdateTeacherGoSchool;        //教师端上学信息存入数据库
UIKIT_EXTERN NSString *const DWDPickUpCenterDidUpdateTeacherLeaveSchool;     //教师端放学信息存入数据库
UIKIT_EXTERN NSString * const DWDPickUpCenterDidUpdateChildInfomation;       //家长端更新
UIKIT_EXTERN NSString * const DWDPickUpCenterDidUpdateListInfomation;       //列表更新
UIKIT_EXTERN NSString * const DWDPickUpCenteruserDefaultPickUpCenterTodayStudentsKey;//存在userDefault的请求缓存


#pragma mark - 智能办公菜单编号
/**
 父菜单编号
 */
UIKIT_EXTERN NSString * const kDWDIntParentMenuCodeClassManagement;     //父菜单--班级管理
UIKIT_EXTERN NSString * const kDWDIntParentMenuCodeMemberManagement;     //父菜单--成员管理
UIKIT_EXTERN NSString * const kDWDIntParentMenuCodeSchoolManagement;     //父菜单--校务管理
UIKIT_EXTERN NSString * const kDWDIntParentMenuCodePersonManagement;     //父菜单--个人管理

/**
 班级管理--子菜单编号
 */
UIKIT_EXTERN NSString * const kDWDIntMenuCodeClassManagementGrowth;     //成长记录
UIKIT_EXTERN NSString * const kDWDIntMenuCodeClassManagementNotice;     //班级通知
UIKIT_EXTERN NSString * const kDWDIntMenuCodeClassManagementHomework;     //作业
UIKIT_EXTERN NSString * const kDWDIntMenuCodeClassManagementLeave;     //假条
UIKIT_EXTERN NSString * const kDWDIntMenuCodeClassManagementTransferCenter;     //接送中心
UIKIT_EXTERN NSString * const kDWDIntMenuCodeClassManagementClassSetting;     //班级设置
UIKIT_EXTERN NSString * const kDWDIntMenuCodeClassManagementLeagueManagement;     //社团管理
UIKIT_EXTERN NSString * const kDWDIntMenuCodeClassManagementMore;     //级管理期待更多

/**
 成员管理--子菜单编号
 */
UIKIT_EXTERN NSString * const kDWDIntMenuCodeMemberManagementStudentManagement;     //学生管理
UIKIT_EXTERN NSString * const kDWDIntMenuCodeMemberManagementClassMember;     //班群成员
UIKIT_EXTERN NSString * const kDWDIntMenuCodeMemberManagerMore;     //成员管理期待更多

/**
 校务管理--子菜单编号
 */
UIKIT_EXTERN NSString * const kDWDIntMenuCodeSchoolManagementContact;     //智能通讯录
UIKIT_EXTERN NSString * const kDWDIntMenuCodeSchoolManagementTeachingActivities;     //教研活动
UIKIT_EXTERN NSString * const kDWDIntMenuCodeSchoolManagementAttendance;     //考勤签到
UIKIT_EXTERN NSString * const kDWDIntMenuCodeSchoolManagementNotice;     //通知公告
UIKIT_EXTERN NSString * const kDWDIntMenuCodeSchoolManagementMeeting;     //会议情况
UIKIT_EXTERN NSString * const kDWDIntMenuCodeSchoolManagementCourseManagement;     //课表管理
UIKIT_EXTERN NSString * const kDWDIntMenuCodeSchoolManagementApply;     //审批申请
UIKIT_EXTERN NSString * const kDWDIntMenuCodeSchoolManagementVote;     //投票调研
UIKIT_EXTERN NSString * const kDWDIntMenuCodeSchoolManagementHall;     //数字展厅
UIKIT_EXTERN NSString * const kDWDIntMenuCodeSchoolManagementMore;     //期待更多
/**
 个人管理--子菜单编号
 */
UIKIT_EXTERN NSString * const kDWDIntMenuCodePersonManagementMySalary;     //我的工资
UIKIT_EXTERN NSString * const kDWDIntMenuCodePerformanceManagement;     //绩效管理

#pragma mark - 智能办公学校模板ID
UIKIT_EXTERN long long const schoolIdDefault;


#pragma mark - 强制更新标记
UIKIT_EXTERN NSString * const DWDCheckVersionForceUpdateKey;
UIKIT_EXTERN NSString * const DWDCheckVersionForceUpdateContentKey;






typedef NS_ENUM( NSUInteger, DWDChatType) {
    DWDChatTypeFace = 0,
    DWDChatTypeGroup,
    DWDChatTypeClass,
    DWDChatTypeNone = 1000
};


/** 第三方应用号 */
//友盟统计、分享
UIKIT_EXTERN NSString * const kUMAppkey;
//极光
UIKIT_EXTERN NSString * const kJPushAppkey;

#pragma mark - token
/** token 失效标识 */
UIKIT_EXTERN NSString *const kTokenOverdue;

UIKIT_EXTERN CGFloat const selectViewHeight;
