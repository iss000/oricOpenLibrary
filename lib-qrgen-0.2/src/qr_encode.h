/*
 * qr_encode.h
 *
 *  Created on: Jan 18, 2012
 *  Adapted by Jamie Howard
 *  Author: swex
 */

#ifndef __QR_ENCODE_H__
#define __QR_ENCODE_H__

#define MAX_BITDATA 301

int EncodeData(int nLevel, int nVersion, const char* lpsSource, int sourcelen, unsigned char QR_m_data[]);

#endif
