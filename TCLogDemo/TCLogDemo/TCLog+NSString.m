//
//  TCLog+NSString.m
//  Tecom
//
//  Created by Andrew on 16/1/28.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import "TCLog+NSString.h"
#import <objc/runtime.h>

static const void *timeStampKey = &timeStampKey;
static const void *typeKey      = &typeKey;

@implementation NSString (TCLogExtension)

@dynamic timeStamp;
@dynamic type;

- (NSDate *)timeStamp
{
    return objc_getAssociatedObject(self, timeStampKey);
}

- (void)setTimeStamp:(NSDate *)timeStamp
{
    objc_setAssociatedObject(self, timeStampKey, timeStamp, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)type
{
    return [objc_getAssociatedObject(self, typeKey) integerValue];
}

- (void)setType:(NSInteger)type
{
    objc_setAssociatedObject(self, typeKey, [NSNumber numberWithInteger:type], OBJC_ASSOCIATION_ASSIGN);
}

@end
