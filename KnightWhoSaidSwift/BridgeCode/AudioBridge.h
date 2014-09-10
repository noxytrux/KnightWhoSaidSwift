//
//  AudioBridge.h
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 09.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

extern void BufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer);

