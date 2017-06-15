//
//  DWDRSAHandler.m
//  EduChat
//
//  Created by KKK on 16/5/20.
//  Copyright © 2016年 dwd. All rights reserved.
//

#import "DWDRSAHandler.h"

#import <openssl/pem.h>


#define DocumentsDir [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define OpenSSLRSAKeyDir [DocumentsDir stringByAppendingPathComponent:@".openssl_rsa"]
#define OpenSSLRSAPublicKeyFile [OpenSSLRSAKeyDir stringByAppendingPathComponent:@"dwd.publicKey.pem"]
#define OpenSSLRSAPrivateKeyFile [OpenSSLRSAKeyDir stringByAppendingPathComponent:@"dwd.privateKey.pem"]

@implementation DWDRSAHandler
{
    RSA *_rsaPublic;
}

#pragma mark - Public Method

+ (instancetype)sharedHandler
{
    static DWDRSAHandler *mySelf;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mySelf = [[self alloc]init];
    });
    return  mySelf;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        // mkdir for key dir
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm fileExistsAtPath:OpenSSLRSAKeyDir])
        {
            [fm createDirectoryAtPath:OpenSSLRSAKeyDir withIntermediateDirectories:YES attributes:nil error:nil];
            
        }
    }
    return self;
}

- (BOOL)savePublicKey:(NSString *)publicKey {
    
    
    NSString *publicKeyStr = publicKey;
//    publicKeyStr = @"MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCQidU3b6SSso1MjPlMOktIgjjApqwrjYCtfxYBX1gZRoKvAjgT5/PmjJBdoxmzLoVJK7mOFaYyES66iDoOq09ut3T6MgVkIY6Xky5i7NUu9o3END+JjkGaG/8UWkqP2VYXKtGZfSzmHcMoyq+yDN2xocmE1oeqIQF7RRuQBCahqwIDAQAB";
    NSMutableString *result = [NSMutableString string];
    [result appendString:@"-----BEGIN PUBLIC KEY-----\n"];
    int count = 0;
    for (int i = 0; i < [publicKeyStr length]; ++i) {
        unichar c = [publicKeyStr characterAtIndex:i];
        if (c == '\n' || c == '\r') {
            continue;
        }
        [result appendFormat:@"%c", c];
        if (++count == 64) {
            [result appendString:@"\n"];
            count = 0;
        }
    }
    [result appendString:@"\n-----END PUBLIC KEY-----"];
    
    NSError *error = [[NSError alloc] init];
    
    BOOL saveResult =  [result writeToFile:OpenSSLRSAPublicKeyFile atomically:YES encoding:NSASCIIStringEncoding error:&error];
    if (saveResult) {
        [self importPublicKey];
    }
    return saveResult;

}

- (NSString *)encryptPublicKeyWithInfoString:(NSString *)string {
    
    if ([string length])
    {
        NSString *md5Str = [string md532BitLower] ;
        
        NSData *strData = [md5Str dataUsingEncoding:NSUTF8StringEncoding];
        NSString *dataStr = [self encryptPublicKeyWithInfoData:strData];
        return dataStr;
    }
    
    return nil;
}

- (NSString *)encryptPublicKeyWithInfoData:(NSData *)data
{
    if (!_rsaPublic) {
        [self importPublicKey];
        if (!_rsaPublic) {
            return nil;
        }
    }
    
    if (data) {
        int len = (int)[data length];
        unsigned char *plainBuffer = (unsigned char *)[data bytes];
        
        //result len
        int clen = RSA_size(_rsaPublic);
        unsigned char *cipherBuffer = calloc(clen, sizeof(unsigned char));
        
        RSA_public_encrypt(len, plainBuffer, cipherBuffer, _rsaPublic, RSA_PKCS1_PADDING);
        
        NSData *data1 = [NSData dataWithBytes:cipherBuffer length:clen];
        
//       NSString *strrrr = [[NSString alloc] initWithData:data1 encoding:NSASCIIStringEncoding];
        
        NSString *resultStr = [data1 base64EncodedStringWithOptions:0];
        free(cipherBuffer);
        return resultStr;
    }
    return nil;
}
#pragma mark - Private Method

/**
 *  注入公钥
 */
- (void)importPublicKey {
    FILE *publicKeyFile;
    const char *publicKeyFileName = [OpenSSLRSAPublicKeyFile cStringUsingEncoding:NSASCIIStringEncoding];
    publicKeyFile = fopen([OpenSSLRSAPublicKeyFile cStringUsingEncoding:NSASCIIStringEncoding],"rb");
    if (NULL != publicKeyFile)
    {
        BIO *bpubkey = NULL;
        bpubkey = BIO_new(BIO_s_file());
        BIO_read_filename(bpubkey, publicKeyFileName);
        
        _rsaPublic = PEM_read_bio_RSA_PUBKEY(bpubkey, NULL, NULL, NULL);
        //        assert(_rsa != NULL);
        BIO_free_all(bpubkey);
    }
}
@end


