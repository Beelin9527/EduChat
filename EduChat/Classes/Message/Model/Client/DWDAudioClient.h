//
//  DWDAudioClient.h
//  EduChat
//
//  Created by apple on 11/18/15.
//  Copyright © 2015 dwd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class DWDAudioClient;

@protocol DWDAudioClientDelegate <NSObject>

@optional
//use to make a animation
- (void)audioClient:(DWDAudioClient *)client didRecordingWihtMetering:(CGFloat)metering;
- (void)audioClient:(DWDAudioClient *)client didPlayingWihtMetering:(CGFloat)metering;
- (void)audioClientDidFinishPlaying:(DWDAudioClient *)client;

@end

@interface DWDAudioClient : NSObject

@property (weak, nonatomic) id<DWDAudioClientDelegate> delegate;

@property (nonatomic) CGFloat sampleRate;
@property (nonatomic) AVAudioQuality quality;

//do not use init, use this to get singelton client
+ (id)sharedAudioClient;

- (void)startRecorderAudioWithTempFile:(NSURL *)tempUrl mp3FileName:(NSString *)mp3FileName;
- (NSString *)endRecord;
- (void)cancleRecord;
- (void)playAudioWithURL:(NSURL *)audioSource;
- (void)endPlay;

@end
