//
//  TCLog.m
//  Tecom
//
//  Created by Andrew on 16/1/27.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "TCLog.h"
#import "TCLog+NSString.h"

#define INNER_TV_KEYS(num) INNER_TV_KEYS_BYSTR(INNER_TV_NUM2STR(num))
#define INNER_TV_NUM2STR(num) [NSString stringWithFormat:@"%llu",(long long)(num)]
#define INNER_TV_KEYS_BYSTR(str) [NSString stringWithFormat:@"innerTVKey%@",(str)]

#define TV_MAGIC_NUM 315

@interface TCLog ()<UITextFieldDelegate>

@property (nonatomic, strong) NSMutableArray      *innerAry;

@property (nonatomic, strong) UITextView *innerTV;
@property (nonatomic, assign) BOOL custom;
@property (nonatomic, assign) NSInteger customType;

@end

@implementation TCLog

+ (TCLog *)sharedInstance
{
    static TCLog *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[TCLog alloc]init];
    });
    
    return sharedInstance;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _innerAry = [[NSMutableArray alloc]init];
#ifdef TCLOG_WRITE_SWITCH
        [self redirectNSLogIntoLogFile];
        [self backupLogFile];
#endif
    }
    return self;
}

- (UITextView *)innerTV
{
    if (_innerTV == nil) {
        CGRect tvRect = CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 300);
        _innerTV = [[UITextView alloc]initWithFrame:tvRect];
        _innerTV.editable = NO;
        _innerTV.tag = TV_MAGIC_NUM;
        _innerTV.hidden = YES;
    }
    return _innerTV;
}

-(void)redirectNSLogIntoLogFile
{
    NSString *logName = [NSString stringWithFormat:@"%@.log", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
    NSString *logFilePath = [[self documentPath] stringByAppendingPathComponent:logName];
    
    freopen([logFilePath cStringUsingEncoding:NSUTF8StringEncoding], "a+", stderr);
}

-(void)backupLogFile
{
    NSString *logName = [NSString stringWithFormat:@"%@.log", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
    NSString *logFilePath = [[self documentPath] stringByAppendingPathComponent:logName];
    NSString *backupLogName = [NSString stringWithFormat:@"%@_backup.log", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleName"]];
    NSString *backupLogFilePath = [[self documentPath] stringByAppendingPathComponent:backupLogName];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    if ([fileManager fileExistsAtPath:logFilePath isDirectory:&isDirectory]
        && isDirectory == NO) {
        NSError *attributesError = nil;
        NSDictionary *fileAttributes = [fileManager attributesOfItemAtPath:logFilePath error:&attributesError];
        unsigned long long logFileSize = [fileAttributes fileSize];
        NSLog(@"Log file size [%llu]", logFileSize);
        
        if (logFileSize > TCLOG_Max_LogFileSize) {
            if ([fileManager fileExistsAtPath:backupLogFilePath isDirectory:&isDirectory]
                && isDirectory == NO) { // remove old.
                [fileManager removeItemAtPath:backupLogFilePath error:nil];
            }
            [fileManager copyItemAtPath:logFilePath toPath:backupLogFilePath error:nil];
            [fileManager removeItemAtPath:logFilePath error:nil];
            
            [self redirectNSLogIntoLogFile];
        }
    }
}

- (NSString*)documentPath
{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

#pragma mark - General API

- (void)LogByType:(TCLog_Type)type content:(NSString*)content
{
    NSLog(@"TCLOG: Type:%lu, Content:%@",(unsigned long)type, content);
    
    content.type = type;
    content.timeStamp = [NSDate date];
    [self addCombinedLog:content];
    
    if (self.innerTV.isHidden) {
        return;
    }
    
    NSString *log;
    if (self.custom) {
        if (self.customType == type) {
            log = [self getSeperateLogOfType:self.customType];
        } else {
            return;
        }
    } else {
        log = [self getCombinedLogOfCustomType:self.customType];
    }
    [self showLog:log OnTV:self.innerTV];
}

- (void)showLog:(NSString*)log OnTV:(UITextView*)tv
{
#ifdef SHOW_LOG_ON_UI
    __block NSString *bLog = log;
    __block UITextView *blockTV = tv;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        blockTV.text = bLog;
        if (!blockTV.isTracking && !blockTV.isDecelerating && !blockTV.isDragging) {
            [blockTV scrollRangeToVisible:NSMakeRange(blockTV.text.length - 1, 1)];
        }
    });
#endif
}

- (void)addCombinedLog:(NSString*)content
{
    [_innerAry addObject:content];
    if (_innerAry.count >= TCLOG_MAX_LOG_COUNT) {
        [_innerAry removeObjectAtIndex:0];
    }
}

#pragma mark - GET

- (NSString*)getCombinedLogOfCustomType:(NSUInteger)type
{
    NSMutableString *result = [NSMutableString stringWithString:@""];
    NSArray *ary = [self.innerAry copy];
    for (NSString *str in ary) {
        if (str.type >= type) {
            [result appendString:[self stringOfDate:str.timeStamp]];
            [result appendString:@" "];
            [result appendString:str];
            [result appendString:@"\n\n"];
        }
    }
    return [result copy];
}

- (NSString*)getSeperateLogOfType:(NSUInteger)type
{
    NSMutableString *result = [NSMutableString stringWithString:@""];
    NSArray *ary = [self.innerAry copy];
    for (NSString *str in ary) {
        if (str.type == type) {
            [result appendString:[self stringOfDate:str.timeStamp]];
            [result appendString:@" "];
            [result appendString:str];
            [result appendString:@"\n\n"];
        }
    }
    return [result copy];
}

- (NSString*)stringOfDate:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    return [formatter stringFromDate:date];
}

#ifdef SHOW_LOG_ON_UI

- (void)showLogByNumOnBar:(UINavigationBar*)bar
{
    if (![bar viewWithTag:339]) {
        UITextField *tf = [[UITextField alloc]initWithFrame:CGRectMake(0, 0, 200, 60)];
        tf.center = bar.center;
        tf.delegate = self;
        tf.keyboardType = UIKeyboardTypeNumberPad;
        tf.clearsOnBeginEditing = YES;
        tf.tag = 339;
        [bar addSubview:tf];
        self.custom = YES;
    }
    
    [bar addSubview:self.innerTV];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSString *tfText = textField.text;
    if ([tfText isEqualToString:@""]) {
        self.innerTV.hidden = YES;
    } else {
        NSString *tvText;
        if ([tfText hasSuffix:@"."]) {
            NSInteger type = [[tfText substringToIndex:tfText.length - 1]integerValue];
            self.custom = YES;
            self.customType = type;
            tvText = [self getSeperateLogOfType:type];
        } else {
            self.custom = NO;
            self.customType = [tfText integerValue];
            tvText = [self getCombinedLogOfCustomType:[tfText integerValue]];
        }
        self.innerTV.text = tvText;

        [self.innerTV scrollRangeToVisible:NSMakeRange(self.innerTV.text.length - 1, 1)];
        self.innerTV.hidden = NO;
    }
    [textField resignFirstResponder];
    return YES;
}

#endif

@end