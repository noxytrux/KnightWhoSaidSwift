//
//  AudioBridge.h
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 09.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

#import "KnightWhoSaidSwift-Swift.h"

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

void BufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer);
void InitializeAudioBuffer(void *userAudioClass);
