
#import <UIKit/UIKit.h>


NSString *const DWDClassInfoBottomViewChangeBtnClick = @"DWDClassInfoBottomViewChangeBtnClick";
NSString *const DWDClassInfoBottomViewAndMenuShouldHide = @"DWDClassInfoBottomViewAndMenuShouldHide";

NSString *const DWDDWDCityNameDidSelectNotification = @"DWDCityNameDidSelectNotification";
NSString *const DWDSearchSchoolAndClassControllerSelectSchoolNotification = @"DWDSearchSchoolAndClassControllerSelectSchoolNotification";



// account api keys
NSString *const DWDCustId = @"custId";
NSString *const DWDFriendId = @"friendCustId";
NSString *const DWDNickname = @"nickName";
NSString *const DWDGroupId = @"groupId";
NSString *const DWDApiDataKey = @"data";
NSString *const DWDPhotoKey = @"photoKey";
NSString *const DWDLastModifyDate = @"date";
NSString *const DWDState = @"state";
NSString *const DWDAccountNo = @"account";
NSString *const DWDExtensions = @"extensions";
NSString *const DWDRemark = @"friendRemarkName";
NSString *const DWDPhotoAuth = @"lookPhoto";
NSString *const DWDIsBlackList = @"blackList";
NSString *const DWDEducation = @"education";
NSString *const DWDProperty = @"property";
NSString *const DWDEnterpriseId = @"enterpriseId";
NSString *const DWDSignature = @"signature";



#ifdef DEBUG

// ===================  内网 开发 ========================
//NSString *const kDWDApiBaseUrl = @"http://192.168.10.52:8080/EduChatWebService/services/";
//NSString *const kDWDXcomBaseUrl = @"192.168.10.52";
//uint16_t const kDWDXcomPort = 10888;

//// ===================  内网 测试  ========================
//NSString *const kDWDApiBaseUrl = @"http://192.168.10.52:8081/EduChatWebService/services/";
//NSString *const kDWDXcomBaseUrl = @"192.168.10.52";
//uint16_t const kDWDXcomPort = 10889;
//
//// ===================  外网 测试 ========================
NSString *const kDWDApiBaseUrl = @"https://tservice.dwd-sj.com:8086/";
NSString *const kDWDXcomBaseUrl = @"tservice.dwd-sj.com";
uint16_t const kDWDXcomPort = 10887;
//
//// ===================  外网 正式 ========================
//NSString *const kDWDApiBaseUrl = @"https://service.dwd-sj.com:8085/";
//NSString *const kDWDXcomBaseUrl = @"service.dwd-sj.com";
//uint16_t const kDWDXcomPort = 10889;

//NSString *const kDWDApiBaseUrl = @"http://192.168.10.72:8085/EduChatWebService/services/";
//NSString *const kDWDXcomBaseUrl = @"192.168.10.72";
//uint16_t const kDWDXcomPort = 10887;
#else

//// ===================  外网 服务器 release ========================
NSString *const kDWDApiBaseUrl = @"https://service.dwd-sj.com:8085/";
//NSString *const kDWDApiBaseUrl = @"https://service.dwd-sj.com:8085/EduChatWebService/services/";
NSString *const kDWDXcomBaseUrl = @"service.dwd-sj.com";
uint16_t const kDWDXcomPort = 10889;

#endif

NSString *const kDWDErrorDomain = @"DWDNetworkError";
NSString *const kDWDDBErrorDomain = @"DWDDBError";

#pragma mark - 本地缓存名
NSString *const DWDLoginState = @"DWDLoginState";
NSString *const DWDLoginCustIdCache = @"DWDLoginCustIdCache";
NSString *const kDWDOrignPwdCache = @"kDWDOrignPwdCache";
NSString *const kDWDMD5PwdCache = @"kDWDMD5PwdCache";
NSString *const kDWDEncryptPwdCache = @"kDWDEncryptPwdCache"; 
NSString *const DWDUserNameCache = @"DWDUserNameCache";
NSString *const DWDCustInfoData = @"DWDCustInfoData";
// 登录请求信息 缓存名
NSString *const kDWDRequestHeaderInfoCache = @"kDWDRequestHeaderInfoCache";


//注册  dataType:  1-注册 2-找回密码 11-微信注册
NSString *const DWDGetVerifyCodeRegisterType = @"1";
NSString *const DWDGetVerifyCodeFindPwdType = @"2";


#pragma mark - 通知名
/** 执行登录 */
NSString *const kDWDNotificationExecuteLogin = @"notificationExecuteLogin";
/** 会话列表 加载、刷新行数据 通知名 */
NSString *const kDWDNotificationRecentChatLoad = @"notificationRecentChatLoad";
/** 会话列表  是否需要刷新会话列表 通知名 */
NSString *const kDWDNotificationNeedRecentChatLoad = @"notificationNeedRecentChatLoad";
/** 会话列表 删除行数据 通知名 */
NSString *const kDWDNotificationDeleteRowRecentChat = @"notificationDeleteRecentChatData";
/** 本地库 通讯录 通知名 */
NSString *const DWDNotificationContactUpdate = @"notificationContactUpdate";
NSString *const DWDNotificationContactsGet = @"notificationContactsGet";

/** 本地库 群组 通知名 */
NSString *const DWDNotificationGroupListReload = @"notificationGroupListReload";
/** 本地库 班级 通知名 */
NSString *const kDWDNotificationClassListReload = @"notificationClassListReload";

/** 显示小红点 通知名 */
NSString *const kDWDNotificationShowRed = @"notificationShowRed";

/** 实时更新班级头像 通知名 */
NSString *const kDWDChangeClassPhotoKeyNotification = @"changeClassPhotoKeyNotification";
/** 实时更新群组头像 通知名 */
NSString *const kDWDChangeGroupPhotoKeyNotification = @"changeGroupPhotoKeyNotification";
/** 实时更新群组昵称 通知名 */
NSString *const kDWDChangeGroupNicknameNotification = @"changeGroupNicknameNotification";
/** 实时更新联系人头像 */
NSString *const kDWDChangeContactPhotoKeyNotification = @"changeContactPhotoKeyNotification";
/** 实时更新联系人昵称 */
NSString *const kDWDChangeContactNicknameNotification = @"changeContactNicknameNotification";

/** app 将退出后台 */
NSString *const kDWDAppWillResignActive = @"notificationWillResignActive";
/** app 将进入前台 */
NSString *const kDWDAppWillEnterForeground = @"notificationWillEnterForeground";

NSString *const kDWDNotificationEnterAppReloadUnreadMsg = @"nootificationEnterAppReloadUnreadMsg";
/** 互斥登录 */
NSString *const kDWDNotificationCrowdedUserOffline = @"notificationCrowdedUserOffline";

/** 更新菜单变更 */
NSString *const kDWDNotificationSmartOAMenu = @"notificationSmartOAMenu";
/** 更新智能办公 classModel */
NSString *const kDWDNotificationClassManagerClassModel = @"notificationClassManagerClassMode";

/** 登录者身份 */
NSString *const kDWDNotificationChangeLoginIdentify = @"notificationChangeLoginIdentify";

/** 网络状态 根据状态是否显示会话列表HeaderView描述 通知名 */
NSString *const kDWDNotificationNetState = @"notificationNetState";

/** 用户资料 刷新 通知名 */
NSString *const DWDNotificationPersonDataReload = @"notificationPersonDataReload";

/** 在聊天界面当中 接收到系统消息有好友、群、班 对自己进行删除操作 提示群组解散 通知名 */
NSString *const DWDNotificationShowAlert = @"notificationShowAlert";

/** 有聊天消息被撤回 通知名 */
NSString *const DWDNotificationHaveMsgRevoked = @"notificationHaveMsgRevoked";

/** 有班级中的聊天消息被班主任删除 通知名 */
NSString *const DWDNotificationClassManagerDeleteMsg = @"notificationClassManagerDeleteMsg";

/** 刷新聊天控制器 数据 */
 NSString *const DWDNotificationSystemMessageReload = @"notificationSystemMessageReload";

/** 需要刷新recentChat的lastContent */
NSString *const DWDNotificationRecentChatLastContentNeedChange = @"notificationRecentChatLastContentNeedChange";

/** 当前聊天界面插入离线未读消息 */
NSString *const kDWDNotificationInsertUnreadMsgToChatVC = @"notificationInsertUnreadMsgToChatVC";

/** 聊天界面图片预览点击大图返回聊天界面时 , 通知聊天控制器恢复状态栏 */
NSString *const kDWDNotificationChatPreViewCellImageViewTap = @"kDWDNotificationChatPreViewCellImageViewTap";
NSString *const kDWDNotificationChatPreViewCellDidRelayToSomeone = @"kDWDNotificationChatPreViewCellDidRelayToSomeone";

/** 聊天界面转发消息 , 发通知判断是否发给当前的toUser */
NSString *const kDWDNotificationChatRelayJudgeCurrentTouser = @"kDWDNotificationChatRelayJudgeCurrentTouser";

/** 登陆状态改变时刷新咨询模块 */
NSString *const kDWDNotificationRefreshInformation = @"notificationRefreshInformation";

/** 聊天视频全屏时回收键盘 */
NSString *const kDWDNotificationChatVideoPlay = @"notificationChatVideoPlay";
NSString *const kDWDNotificationChatNeedInsertTimeMsg = @"kDWDNotificationChatNeedInsertTimeMsg";

#pragma mark - 系统消息字段
NSString * const kDWDSysmsgNewFriendverify = @"sysmsgNewFriendverify";
NSString * const kDWDSysmsgFriendverifyPassed = @"sysmsgFriendverifyPassed";
NSString * const kDWDSysmsgFriendverifyFailed = @"sysmsgFriendverifyFailed";
NSString * const kDWDSysmsgDeleteFriend = @"sysmsgDeleteFriend";
NSString * const kDWDSysmsgDeleteFriendChatKey = @"dwd_system_delete_friend_when_chatcontroller";

NSString * const kDWDSysmsgNewClassMemberverify = @"sysmsgNewClassMemberverify";  // 有人申请加入我的班级  1
NSString * const kDWDSysmsgClassMemberverifyPassed = @"sysmsgClassMemberverifyPassed";  // 谁加入班级  1
NSString * const kDWDSysmsgClassMemberverifyRefused = @"sysmsgClassMemberverifyRefused"; // 拒绝我加入班级  1
NSString * const kDWDSysmsgDeleteClassMember = @"sysmsgDeleteClassMember";  // 删除班级成员  1
NSString * const kDWDSysmsgDeleteClass = @"sysmsgDeleteClass";  // 删除班级 只有班主有权操作  1
NSString * const kDWDSysmsgMemberQuitClass = @"sysmsgMemberQuitClass"; //班级成员主动退出  1

NSString * const kDWDSysmsgAddGroupMember = @"sysmsgAddGroupMember";  // 添加群组成员   1
NSString * const kDWDSysmsgDeleteGroupMember = @"sysmsgDeleteGroupMember"; // 删除群组成员  1
NSString * const kDWDSysmsgDeleteGroup = @"sysmsgDeleteGroup"; // 删除群组 只有群主有权操作  1
NSString * const kDWDSysmsgMemberQuitGroup = @"sysmsgMemberQuitGroup"; // 群组成员主动退出  1 

NSString * const kDWDSysmsgContextual = @"sysmsgContextual";  // 接送中心
NSString * const kDWDSysmsgUpdateClass = @"sysmsgUpdateClass";  // 实时更新班级的头像
NSString * const kDWDSysmsgUpdateGroup = @"sysmsgUpdateGroup";  // 实时更新群组的头像或者昵称
NSString * const kDWDSysmsgUpdateContact = @"sysmsgUpdatePersonalInfo";  // 实时更新好友个人的头像、个人昵称

NSString * const kDWDSysmsgCrowdedUserOffline = @"sysmsgCrowdedUserOffline";  // 被迫下线
NSString * const kDWDSysmsgRevokeMsg = @"sysmsgUndoMessage";  // 有消息被撤回

NSString * const kDWDSysmsgMenu = @"sysmsgMenu";  // 菜单变更系统消息

#pragma mark - 接送中心通知
NSString * const DWDPickUpCenterDidUpdateTeacherGoSchool = @"DWDPickUpCenterDidUpdateTeacherGoSchool";     //教师端上学信息存入数据库
NSString * const DWDPickUpCenterDidUpdateTeacherLeaveSchool = @"DWDPickUpCenterDidUpdateTeacherLeaveSchool";
NSString * const DWDPickUpCenterDidUpdateChildInfomation = @"DWDPickUpCenterDidUpdateChildInfomation";
NSString * const DWDPickUpCenterDidUpdateListInfomation = @"DWDPickUpCenterDidUpdateListInfomation";
NSString * const  DWDPickUpCenteruserDefaultPickUpCenterTodayStudentsKey = @"userDefaultPickUpCenterTodayStudentsKey";


#pragma mark - 智能办公菜单编号
/** 
 父菜单编号
 */
NSString * const kDWDIntParentMenuCodeClassManagement = @"A020101010101";     //父菜单--班级管理
NSString * const kDWDIntParentMenuCodeMemberManagement = @"A020101010102";     //父菜单--成员管理
NSString * const kDWDIntParentMenuCodeSchoolManagement = @"A0201010201";     //父菜单--校务管理
NSString * const kDWDIntParentMenuCodePersonManagement = @"A0201010202";     //父菜单--个人管理

/** 
 班级管理--子菜单编号 
 */
NSString * const kDWDIntMenuCodeClassManagementGrowth = @"A02010101010101";     //成长记录
NSString * const kDWDIntMenuCodeClassManagementNotice = @"A02010101010102";     //班级通知
NSString * const kDWDIntMenuCodeClassManagementHomework = @"A02010101010103";     //作业
NSString * const kDWDIntMenuCodeClassManagementLeave = @"A02010101010104";     //假条
NSString * const kDWDIntMenuCodeClassManagementTransferCenter = @"A02010101010105";     //接送中心
NSString * const kDWDIntMenuCodeClassManagementClassSetting = @"A02010101010106";     //班级设置
NSString * const kDWDIntMenuCodeClassManagementLeagueManagement = @"A02010101010107";     //社团管理
NSString * const kDWDIntMenuCodeClassManagementMore = @"A02010101010108";     //级管理期待更多

/** 
 成员管理--子菜单编号 
 */
NSString * const kDWDIntMenuCodeMemberManagementStudentManagement = @"A02010101010201";     //学生管理
NSString * const kDWDIntMenuCodeMemberManagementClassMember = @"A02010101010202";     //班群成员
NSString * const kDWDIntMenuCodeMemberManagerMore = @"A02010101010203";     //成员管理期待更多

/**
 校务管理--子菜单编号
 */
NSString * const kDWDIntMenuCodeSchoolManagementContact = @"A020101020101";     //智能通讯录
NSString * const kDWDIntMenuCodeSchoolManagementTeachingActivities = @"A020101020102";     //教研活动
NSString * const kDWDIntMenuCodeSchoolManagementAttendance = @"A020101020103";     //考勤签到
NSString * const kDWDIntMenuCodeSchoolManagementNotice = @"A020101020104";     //通知公告
NSString * const kDWDIntMenuCodeSchoolManagementMeeting = @"A020101020105";     //会议情况
NSString * const kDWDIntMenuCodeSchoolManagementCourseManagement = @"A020101020106";     //课表管理
NSString * const kDWDIntMenuCodeSchoolManagementApply = @"A020101020107";     //审批申请
NSString * const kDWDIntMenuCodeSchoolManagementVote = @"A020101020108";     //投票调研
NSString * const kDWDIntMenuCodeSchoolManagementHall = @"A020101020109";     //数字展厅
NSString * const kDWDIntMenuCodeSchoolManagementMore = @"A020101020110";     //期待更多
/**
 个人管理--子菜单编号
 */
NSString * const kDWDIntMenuCodePersonManagementMySalary = @"A020101020201";     //我的工资
NSString * const kDWDIntMenuCodePerformanceManagement= @"A020101020202";     //绩效管理

#pragma mark - 智能办公学校模板ID
long long const schoolIdDefault = -2010000000000;


#pragma mark - 强制更新标记
NSString * const DWDCheckVersionForceUpdateKey = @"DWDCheckVersionForceUpdateStaticKey";
NSString * const DWDCheckVersionForceUpdateContentKey = @"DWDCheckVersionForceUpdateStaticContentKey";

#pragma mark - 第三方应用号
//友盟统计
NSString * const kUMAppkey = @"5754dd1fe0f55adf96000069";
//极光
NSString * const kJPushAppkey = @"352b0f074538171af1f7c62b";

#pragma mark - token
/** token 失效标识 */
NSString *const kTokenOverdue = @"49A1101011001";

CGFloat const selectViewHeight = 40.0;

