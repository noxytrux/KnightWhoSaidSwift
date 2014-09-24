//
//  Float16.h
//  Barok Engine
//
//  Created by Kamil Nowakowski
//  Copyright (c) 2014 Kamil Nowakowski. All rights reserved.
//

#ifndef FLOAT_16_H
#define FLOAT_16_H

#include <stdint.h>

uint16_t Float16CompressorCompress(float value);
float Float16CompressorDecompress(uint16_t value);

#endif // FLOAT_16_H

