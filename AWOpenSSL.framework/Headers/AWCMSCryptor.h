//
//  AWCMSCryptor.h
//  AWOpenSSL
//
// Copyright © 2016 VMware, Inc. All rights reserved.
// This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
// AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
//

#import <Foundation/Foundation.h>

/*!
 @class AWCMSCryptor

 @brief AWCMSCryptor Cryptor to encrypt, decrypt, sign and verify CMS/PKCS7 Data.

 @discussion This class is used to encrypt using public key from certificate. decrypt, create PKCS12 envelope with signature and verify the signature.
 */

@interface AWCMSCryptor : NSObject
/*!
 @brief Encrypts payload using certificate public key

 @discussion This method will use openssl CMS_encrypt to encrypt the payload and return CMS enveloped cipher data.

 To use it, simply call @c[AWCMSCryptor encrypt:payloadData certificateData:certificateData];

 @param  payload Plain Text Data to encrypt

 @param  certificate X509 certificate with public key to encrypt.

 @return NSData CMS Enveloped cipher Data. nil if the payload is nil or certificate data is empty or bad.
 */
+(NSData* _Nullable) encrypt:(NSData* _Nullable)payload
             certificateData:(NSData* _Nullable)certificate;

/*!
 @brief Decrypts payload using certificate private key and password

 @discussion This method will use openssl CMS_decrypt to decrypt the CMS/PKCS7 envelope and return plain Text data.

 To use it, simply call @c[AWCMSCryptor decrypt:cmsorpkcs7Data privateKeyData:privateKey password:@"private-key-password"];

 @param  cmsData CMS/PKCS7 encrypted data

 @param  privateKeyData PEM or DER representation of private key.
 
 @param  password password for the private key.

 @return NSData Decrypted Plain Text Data. nil if the CMS/PKCS7 structure is bad or private key password combination does not match.
 */
+(NSData* _Nullable) decrypt:(NSData* _Nullable)cmsData
              privateKeyData:(NSData* _Nullable)privateKeyData
                    password:(NSString* _Nullable)password;


/*!
 @brief Return a CMS data in DER format after signing the payload with signers certificate, private key and password

 @discussion This method will encrypt the payload with signer Certificate and signs the payload using privatekey, password combination.

 @param  payload Plain Data to Encrypt and Sign.

 @param  privateKeyData PEM or DER representation of private key.

 @param  password password for the private key.
 
 @param  signerCertificate Certificate to sign with.

 @return NSData returns either a valid CMS/PKCS7 Envelope represented in DER format or nil if an error occured.
 */

+(NSData* _Nullable) cmsSignedPayload:(NSData* _Nullable)payload
                       privateKeyData:(NSData* _Nullable)privateKeyData
                             password:(NSString* _Nullable)password
                    signerCertificate:(NSData* _Nullable)signerCertificate;

/*!
 @brief Signs the payload with signers certificate, private key and password

 @discussion This method will return only CMS signature.

 @param  payload Plain Data to Sign

 @param  privateKeyData PEM or DER representation of private key.

 @param  password password for the private key.

 @param  signerCertificate Certificate to sign with.

 @return NSData returns either a valid CMS Signature or nil if an error occured.
 */

+(NSData* _Nullable) cmsSignatureForPayload:(NSData* _Nullable )payload
                             privateKeyData:(NSData* _Nullable)privateKeyData
                                   password:(NSString* _Nullable)password
                          signerCertificate:(NSData* _Nullable)signerCertificate;

/*!
 @brief Verifies payload with senders certificate.

 @discussion This method will verify the CMS signed payload and returns
 data if verification is successful.

 @param  payload data representation of CMS to verify.

 @param  verificationCertificateData PEM or DER representation of certificate of sender.

 @param  verificationCertificateRootCertificateData the certificate you can validate the verifier certificate.

 @param  signerCertificate Certificate to sign with/

 @return NSData returns either validated data or nil if validation or operation fails.
 */
+(NSData* _Nullable) verifyCMSPayloadData:(NSData* _Nullable)payload
                        withCertificateData:(NSData* _Nullable)verificationCertificateData
                            rootCertificate:(NSData* _Nullable)verificationCertificateRootCertificateData;

@end
