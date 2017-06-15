//
//  DWDChatClient.m
//  EduChat
//
//  Created by apple on 1/5/16.
//  Copyright © 2016 dwd. All rights reserved.
//

//#import <CocoaAsyncSocket/CocoaAsyncSocket.h>

/**
 自定义socket类
 
 作用:
 - 消息分发
 - 断线重连
 - 心跳发送
 - 返回回执
 */

/**
 消息分发:
 
 截到全部socket消息
 通道 消息体 为有用部分
 
 通过另一个类解析分发
 还是在当前方法解析完毕直接分发
 
 特殊消息可以直接做特殊处理
 相关处理方法新建类
 */

/**
 readData读取通道 根据通道进入不同的解析?(待验证)
 */


#import "DWDChatClient.h"
#import "DWDChatMsgDataClient.h"
#import <YYTextView.h>

//0x24 0x24 |int8 int8 | int8 int 8 | int8 | 0x40 0x40
//包头 包头      通道       消息体长度   校验码     包尾
#define kDWDSocketProtocolHeaderLength 6
#define kDWDSocketProtocolHeaderTag 100
#define kDWDSocketProtocolRemainTag 101

#define kMaxReconnection_time 5

@interface DWDChatClient () <GCDAsyncSocketDelegate>
@property (nonatomic , strong) NSData *headerData;
@property (weak, nonatomic) DWDChatClient *chatSocketClient;

@property (strong, nonatomic) NSTimer *timer; //计时器
@property (assign, nonatomic) NSUInteger reconnection_time; //计时次数
@property (assign, nonatomic) NSInteger state; //标记网络状态 -1：未连接  1：已连接

@end

@implementation DWDChatClient





DWDSingletonM(DWDChatClient)
#pragma mark - Init Method
- (instancetype)init {
    
    self = [super init];

    if (self) {
//        _firstData = [[NSMutableData alloc] init];
        _reconnection_time = 1;
        [self getConnect];
    }
    
    return self;
}

#pragma mark - /******GCDAsyncSocketDelegate******/
//#pragma mark - Public Method
//#pragma mark - Private Method



// ===========================================================================  写
- (void)sendData:(NSData *)data {
    DWDLog(@"socket begin to send data in private method >>>>>>>>>> \n %@", data);
    
//    unsigned char bytes[4];
//    unsigned long len = 4;
//    [data getBytes:bytes range:NSMakeRange(0, len)];
//    
//    unsigned char typeBytes[] = {bytes[2], bytes[3]};
    
//    if ((typeBytes[0] == 0x60 && typeBytes[1] == 0x10) || (typeBytes[0] == 0x60 && typeBytes[1] == 0x60) || (typeBytes[0] == 0x61 && typeBytes[1] == 0x00) || (typeBytes[0] == 0x61 && typeBytes[1] == 0x60)) {
//        [self.socket writeData:data withTimeout:5 tag:2];  // 写入消息 到完成写入 大概有1 - 2 秒的延迟时间
//    }else{
//        [self.socket writeData:data withTimeout:-1 tag:1];
//    }
    
    [self.socket writeData:data withTimeout:-1 tag:1];
    
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag  //  发送完毕(成功)  写到本地管道 , 网络100%丢包也会完成写入
{
    DWDLog(@"socket didWriteData current time is %@==========" , [NSDate date]);
}

- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutWriteWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length{
    // same
    DWDLog(@"socket====写====数据超时了...各渠道总超时时间elapsed : %f" , elapsed);
    return 0;
}

// ========================================================================================  写
- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag   // 读到数据
{
    DWDLog(@"socket didReadData  <<<<<<<<<<<<<<<<<<<<<<<<<<<<<< data: \n %@ ", data );
    
    if (tag == kDWDSocketProtocolHeaderTag) {
        //请求头
//        [self. appendData:data];
        self.headerData = [NSData dataWithData:data];
        
        // 先判断是否为回执
//        unsigned char bytes[data.length];
//        unsigned long len = data.length;
//        [data getBytes:bytes range:NSMakeRange(0, len)];
//        unsigned char typeBytes[] = {bytes[2], bytes[3]};
//        
//        if ((typeBytes[0] == 0x60 && typeBytes[1] == 0x10) || (typeBytes[0] == 0x60 && typeBytes[1] == 0x60) || (typeBytes[0] == 0x61 && typeBytes[1] == 0x00) || (typeBytes[0] == 0x61 && typeBytes[1] == 0x60)) { // 回执
//            // 发通知
//            DWDLog(@"发通知");
//        }
        
        //高低位转换
        //读的时候 htons()
        //写的时候 ntohs() //是否需要暂不确定
        
        NSData *lengthData = [data subdataWithRange:NSMakeRange(4, 2)];  // 截取长度的两个字节
        
        int length = htons(*(int*)(lengthData.bytes)) + 3;
        
//        Byte a;
//        Byte b;
//        [lengthData getBytes:&a range:NSMakeRange(0, 1)];
//        [lengthData getBytes:&b range:NSMakeRange(1, 1)];
//        
//        Byte k[] = {b,a};
//        NSData *iwantData = [NSData dataWithBytes:&k length:2];
//        short buf;
//        buf = (short )malloc(sizeof(short));
//        [iwantData getBytes:&buf length:sizeof(short)];
        
//        short lastLen = buf + 3;
        
        [self.socket readDataToLength:length withTimeout:-1 tag:1];
        
    }else{
        NSMutableData *totalData = [NSMutableData dataWithData:self.headerData];
        [totalData appendData:data];
        [[DWDChatMsgDataClient sharedChatMsgDataClient] parseChatMsgFromDataAndPostSomeNotification:totalData];
        [self.socket readDataToLength:6 withTimeout:-1 tag:kDWDSocketProtocolHeaderTag];
        
//        Byte j[0];
        
//        [self.firstData replaceBytesInRange:NSMakeRange(0, self.firstData.length) withBytes:j length:0];
        
    }
    
    DWDLog(@"socket begin to read next msg <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<");
    
}


- (NSTimeInterval)socket:(GCDAsyncSocket *)sock shouldTimeoutReadWithTag:(long)tag elapsed:(NSTimeInterval)elapsed bytesDone:(NSUInteger)length{
    // 返回时间如果大于 0  就是延长的超时时间 , 否则为默认值
    DWDLog(@"socket====读取====数据超时了...各渠道总超时时间elapsed : %f" , elapsed);
    return 0;
    
}


#pragma mark socket delegate methods
- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port   // 链接成功
{
    //移除计时器
    [self removerTimer];
    
    //登陆成功 发送用户讯息
    NSData *loginData = [[DWDChatMsgDataClient sharedChatMsgDataClient] makeMsgClientLoginData:[DWDCustInfo shared].custUserName pwd:[DWDCustInfo shared].custMD5Pwd];
    [[DWDChatClient sharedDWDChatClient] sendData:loginData];
    
    //发送通知 链接成功
    self.state = 1;
    NSDictionary *dict = @{@"state":@(self.state)};
    [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNetState object:nil userInfo:dict];
    
    DWDLog(@"Cool, Socket didConnectToHost ==========");
}


- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err{ // 如果超时了, 也会调用这个方法

    DWDLog(@"DidDisconnect 回调");
    DWDLog(@"socketDidDisconnectError: %@", err);

    
    self.state = -1;
    
    //没有登录，不重连
    if (![DWDCustInfo shared].isLogin) {
        return;
    }
    
    //不在前台 不重连
    if ([[UIApplication sharedApplication] applicationState] != UIApplicationStateActive) {
        return;
    }
    
    //被迫下线,不重连
    if ([DWDCustInfo shared].forceOffLine == YES) {
        [DWDCustInfo shared].forceOffLine = NO;
        return;
    }
    
    //小于或等于5次、重连
    if(self.reconnection_time <= kMaxReconnection_time)
    {
        [self removerTimer];
        
        //2的次方
        int time =pow(2,_reconnection_time);

        self.timer= [NSTimer scheduledTimerWithTimeInterval:time target:self selector:@selector(reconnection) userInfo:nil repeats:NO];
        
        self.reconnection_time++;
        
        DWDLog(@"socket did reconnection,after %ds try again",time);
        
        //发送通知、会话列表头部提醒
        NSDictionary *dict = @{@"state":@(self.state)};
        [[NSNotificationCenter defaultCenter] postNotificationName:kDWDNotificationNetState object:nil userInfo:dict];
        
    }else{
        
        self.reconnection_time = 1;
        
        
    }
    
}


#pragma mark - /******Connection******/
#pragma mark - Public Method
/**
 *  连接socket通道
 */
-(void)getConnect
{
    [self setupConnection];
}

/**
 *  主动断开socket通道
 */
-(void)disConnect
{
    [self removerTimer];
    [self.socket disconnect];
}

/**
 *  尝试重新连接
 *  尝试5次,每次间隔时间为2^n秒
 */
- (void)reconnection
{
    //建立链接
    [self reConnectForNoNetwork];

}

/**
 *  监测当前连接状态
 *
 *  @return 是否连接中
 */
- (BOOL)isConnecting {
    return [self.socket isConnected];
}

/**
 *  移除定时器
 */
- (void)removerTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}
#pragma mark - Private Method
//建立连接
- (void)setupConnection {
    
    if(!_socket) {
        _socket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    }
    
    NSError *err = nil;
    if (![self.socket connectToHost:kDWDXcomBaseUrl onPort:kDWDXcomPort error:&err])
    {
        DWDLog(@"链接不成功: %@", err);
        return;
    }
    
    [self.socket readDataToLength:6 withTimeout:-1 tag:kDWDSocketProtocolHeaderTag];
}

/**
 *  重连方法
 */
- (void)reConnectForNoNetwork{
    NSError *err = nil;
    if ([self isConnecting]) {
        [self.socket disconnect];
    }
    
    if (![self.socket connectToHost:kDWDXcomBaseUrl onPort:kDWDXcomPort error:&err])
    {
        DWDLog(@"链接不成功: %@", err);
        return;
    }
    
    [self.socket readDataToLength:6 withTimeout:-1 tag:kDWDSocketProtocolHeaderTag];
}


@end
