//
//  TCLog+NSString.h
//  Tecom
//
//  Created by Andrew on 16/1/28.
//  Copyright © 2016年 Andrew. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TCLogExtension)

@property (nonatomic, strong) NSDate    *timeStamp;
@property (nonatomic, assign) NSInteger type;

@end
