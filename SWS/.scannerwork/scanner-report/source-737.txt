//
//  NSStream+BoundPairAdditions.h
//  UDNetwork
//
//  Created by 杨仕忠 on 10/31/12.
//  Copyright (c) 2012 YLMF Co.,Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSStream (BoundPairAdditions)
+ (void)createBoundInputStream:(NSInputStream **)inputStreamPtr outputStream:(NSOutputStream **)outputStreamPtr bufferSize:(NSUInteger)bufferSize;

@end
