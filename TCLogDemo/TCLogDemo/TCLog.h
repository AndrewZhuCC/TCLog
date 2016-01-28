//
//  TCLog.h
//  Tecom
//
//  Created by Andrew on 16/1/27.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, TCLog_Type) {
    TCLog_Lightly = 1,
    TCLog_Mid,
    TCLog_High,
};

#pragma mark - LOG APIS

#define TCLOG_LIGHT(s, ...) TCLOG_BY_TYPE(TCLog_Lightly, s, ##__VA_ARGS__)
#define TCLOG_MID(s, ...)   TCLOG_BY_TYPE(TCLog_Mid, s, ##__VA_ARGS__)
#define TCLOG_High(s, ...)  TCLOG_BY_TYPE(TCLog_High, s, ##__VA_ARGS__)

#define TCLOG_BY_TYPE(type, s, ...) [[TCLog sharedInstance]LogByType:type content:TCLOG_FORMAT_STRING(s, ##__VA_ARGS__)]

#define TCLOG_MAX_LOG_COUNT 1000
#define TCLOG_Max_LogFileSize 1000000

#define SHOW_LOG_ON_UI
//#define TCLOG_WRITE_SWITCH

#pragma mark - Tools

#define TCLOG_FORMAT_STRING(s, ...) TC_STRING_FORMAT(@"%@(%d)----->\n\t%@", TC_FILE_PATH, __LINE__, [NSString stringWithFormat:(s), ##__VA_ARGS__])

#define TC_STRING_FORMAT(s, ...) [NSString stringWithFormat:(s), ##__VA_ARGS__]
#define TC_FILE_PATH [[NSString stringWithUTF8String:__FILE__] lastPathComponent]

#ifdef SHOW_LOG_ON_UI
    #define TCLOG_SHOWCUSTOM_LOG  [[TCLog sharedInstance] showLogByNumOnBar:self.navigationBar]
#else
    #define TCLOG_SHOWCUSTOM_LOG
#endif

#pragma mark - TCLog Class

@interface TCLog : NSObject

+ (TCLog *)sharedInstance;
- (void)LogByType:(TCLog_Type)type content:(NSString*)content;

#ifdef SHOW_LOG_ON_UI
- (void)showLogByNumOnBar:(UINavigationBar*)bar;

@end

#pragma mark - NavigationBar Extension

@interface UINavigationBar (TCLogNavigationBarEx)

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;

@end

@implementation UINavigationBar (TCLogNavigationBarEx)

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == nil) {
        for (UIView *subview in self.subviews) {
            CGPoint pt = [subview convertPoint:point fromView:self];
            UIView *hitResult = [subview hitTest:pt withEvent:event];
            if (hitResult) {
                view = hitResult;
                break;
            }
        }
    }
    return view;
}
#endif

@end

