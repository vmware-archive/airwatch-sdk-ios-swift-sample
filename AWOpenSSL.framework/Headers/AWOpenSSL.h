//
//  AWOpenSSL.h
//  AWOpenSSL
//
//  Created by Kishore Sajja on 4/27/16.
//  Copyright © 2016 VMWare, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

//! Project version number for AWOpenSSL.
FOUNDATION_EXPORT double AWOpenSSLVersionNumber;

//! Project version string for AWOpenSSL.
FOUNDATION_EXPORT const unsigned char AWOpenSSLVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <AWOpenSSL/PublicHeader.h>


#import "AWX509Wrapper.h"
#import "AWPKCS7Cryptor.h"
#import "AWCMSCryptor.h"
#import "AWPKCS12Helper.h"

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability-completeness"
BOOL AWGenerateRSAKeyPair(int keySizeInBits, NSData **publicKey, NSData **privateKey);

void AWEnableFIPSMode();
void AWDisableFIPSMode();

/**
 @brief This function adds, removes, or changes a passphrase.
 
 @discussion Two typical scenarios...
 * Upgrade scenario - is used for pre 17.1, change the passphrase which used to be NSData to a String.
 * Add a passphrase - If there is no passphrase on the key, then add one with the newPassphrase.
 
 @param key The DER key in PKCS8 fromat as NSData
 
 @param oldPassphrase The old passphrase used to wrap the DER with
 
 @param newPassphrase The new passphrase to wrap the DER with
 
 @return NSData The DER is PKCS8 with the new passphrase using the newPassphrase string. NULL will be returned if there is an error
 */
NSData* _Nullable AWUpdateKeyPassphrase(NSData* _Nonnull key, NSData* _Nullable oldPassphrase, NSString* _Nullable newPassphrase);

#pragma clang diagnostic pop
