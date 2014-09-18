//
//  AudioBridge.m
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 09.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

/**
 lesson learned:
 - include this file before any other #import
 - *.mm files are not supported!
 */

#import "AudioBridge.h"

void InitializeAudioBuffer(void *userAudioClass)
{

}

void BufferCallback(void *inUserData, AudioQueueRef inAQ, AudioQueueBufferRef buffer)
{
    KWSBackgroundStreamPlayer *BackgroundPlayer = (__bridge KWSBackgroundStreamPlayer*)inUserData;
    [BackgroundPlayer callbackForBuffer:buffer];
}
