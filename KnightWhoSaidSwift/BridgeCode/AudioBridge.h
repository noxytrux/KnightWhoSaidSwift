//
//  AudioBridge.h
//  KnightWhoSaidSwift
//
//  Created by Marcin Pędzimąż on 09.09.2014.
//  Copyright (c) 2014 Marcin Pedzimaz. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

void InitializeAudioSource(void *userAudioClass);
void PlayAudio();
void PauseAudio();
void CloseAudio();
void SetAudioGain(Float32 gain);
