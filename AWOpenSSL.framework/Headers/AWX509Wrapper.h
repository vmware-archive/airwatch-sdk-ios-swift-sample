//
//  AWX509Wrapper.h
//  AWOpenssl
//
// Copyright © 2016 VMware, Inc. All rights reserved.
// This product is protected by copyright and intellectual property laws in the United States and other countries as well as by international treaties.
// AirWatch products may be covered by one or more patents listed at http://www.vmware.com/go/patents.
//

#import <Foundation/Foundation.h>

extern NSString * _Nonnull kAWCertificateSubjectName;
extern NSString * _Nonnull kAWCertificateUserID;
extern NSString * _Nonnull kAWCertificateValidity;

extern unsigned long kAWXNFormatRFC2253;
extern unsigned long kAWXNFormatOneLine;
extern unsigned long kAWXNFormatMultiLine;

typedef NS_ENUM(NSUInteger, KeyUsage) {
    DigitalSignature    = 1 << 7,
    NonRepudiation      = 1 << 6,
    KeyEncipherment     = 1 << 5,
    DataEncipherment    = 1 << 4,
    KeyAgreement        = 1 << 3,
    KeyCertSign         = 1 << 2,
    CrlSign             = 1 << 1,
    EncipherOnly        = 1 << 0,
    DecipherOnly        = 1 << 15
};

typedef NS_ENUM(NSUInteger, ExtendedKeyUsage) {
    SSL_Server  = 1 << 0,
    SSL_Client  = 1 << 1,
    SMIME       = 1 << 2,
    CodeSign    = 1 << 3,
    SGC         = 1 << 4,
    OCSPSign    = 1 << 5,
    TimeStamp   = 1 << 6,
    DVCS        = 1 << 7,
    AnyEKU      = 1 << 8
};

/*!
 @class AWX509Wrapper

 @brief Wrapper that provide certificate creation, export to NSData

 @discussion This class hides the implementation details for how certificate is created, loaded from data etc.

 */
@interface AWX509Wrapper : NSObject

/** NO if the certificate is expired otherwise YES */
@property (nonatomic, readonly, getter=isValid) BOOL valid;

/** Subject Name of the certificate */
@property (nonatomic, readonly, nullable) NSString *subjectName;

/** Subject User ID of the certificate */
@property (nonatomic, readonly, nullable) NSString *subjectUserID;

/** Subject email address of the certificate */
@property (nonatomic, readonly, nullable) NSString *emailAddress;

/** Serial number of the certificate */
@property (nonatomic, readonly, nullable) NSData *serialNumber;

/** Subject common name of the certificate */
@property (nonatomic, readonly, nullable) NSString *commonName;

/** Issuer name of the certificate */
@property (nonatomic, readonly, nullable) NSString *issuer;

/** Algorithm of the certificate */
@property (nonatomic, readonly, nullable) NSString *algorithm;

/** Start date of the certificate */
@property (nonatomic, readonly, nullable) NSDate *startDate;

/** End date of the certificate */
@property (nonatomic, readonly, nullable) NSDate *endDate;

/** Subject Alternative Name of the certificate */
@property (nonatomic, readonly, nullable) NSString *subjectAlternativeName;

/** Key Usage of the certificate */
@property (nonatomic, readonly, nullable) NSString *keyUsage;

/** Extended Key Usage of the certificate */
@property (nonatomic, readonly, nullable) NSString *extendedKeyUsage;

/*!
 @brief Intializes wrapper with data for the certificate represented in DER or 
 PEM format.

 @discussion This initializer accepts data in both <b>PEM</b> and <b>DER</b> formats

 To use it, simply call @c[[AWX509Wrapper alloc] initWithCertificateData:data];

 @param  data PEM or DER representation of certificate data.

 @return AWX509Wrapper instance if data can not be successfully parsed as a X509 Certificate.
 */
-(instancetype _Nullable) initWithCertificateData:(NSData* _Nullable)data;

/*!
 @brief Create a new X509 certificate with given attributed and Public Key.

 @discussion you can pass attributed with <b>AWCertificateSubjectName</b>,
 <b>kAWCertificateUserID</b>
 <b>kAWCertificateValidity</b>(optional)

 @param  attributes dictionary with subject name, User ID and validity. Validity
 should be given in seconds since now as string.

 @param  publicKey PEM or DER representation of key.

 @return AWX509Wrapper instance if successful in creating a X509.
 */
-(instancetype _Nullable) initWithAttributes:(NSDictionary* _Nullable)attributes
                                   publicKey:(NSData* _Nullable)publicKey;

/*!
 @brief Exports X509 certificate from internal format into DER format.

 @discussion This exports certificate in DER format.

 @return NSData DER representation of internal X509.
 */
-(NSData* _Nullable) exportCertificateData;

/*!
 @brief Signs current certificate with isssuer's private key.

 @discussion The Certificate must have never been signed. The privateKey and password combination
 should match to extract private key.

 @param  signingX509 CA/Intermediate X509.
 
 @param  issuerPrivateKey Private Key for Signer/CA
 
 @param  password password for Signer/CA

 @return NSData DER representation of signed X509.
 */
-(NSData* _Nullable) signWithIssuer:(AWX509Wrapper* _Nullable)signingX509
                         privateKey:(NSData* _Nullable)issuerPrivateKey
                           password:(NSString* _Nullable)password;

/*!
 @brief Verify whether the current X509 Certificate was signed by the given root X509.

 @discussion This method will make sure that the certificate was signed with the rootX509

 @param  rootX509 CA/singer X509.



 @return BOOL successfully verifies YES, otherwise NO.
 */
-(BOOL) verifyWithRootCertificate:(AWX509Wrapper* _Nullable)rootX509;

/*!
 @brief Verify whether certificate can be used for specified usage
 
 @discussion This method checks key usage of certificate
 
 @param  usage KeyUsage
 
 @return BOOL YES if certificate can be used for usage, otherwise NO.
 */
-(BOOL) canUseFor:(KeyUsage)usage;

/*!
 @brief Verify whether certificate has extended usage for specified usage
 
 @discussion This method checks extended key usage of certificate
 
 @param  eUsage Extended Key Usage
 
 @return BOOL YES if certificate has extended usage for eUsage, otherwise NO.
 */
-(BOOL) hasExtendedUsage:(ExtendedKeyUsage)eUsage;

/*!
 @brief Provides the detailed subject name of the certificate
 
 @discussion Subject name in detail for example - CN=Eugene Liderman,OU=Department of Administration,O=U.S. Government,C=US
 
 @param format - The format in which detailing needed.
 
 @return NSString Detailed subject name in the specified format.
 */
-(NSString* _Nullable)subjectDetailWithFormat:(unsigned long)format;

/*!
 @brief Provides the detailed issuer name of the certificate
 
 @discussion Issuer name in detail for example - CN=MYIDNXT-DC01,DC=MyIDNxT,DC=com
 
 @param format - The format in which detailing needed.
 
 @return NSString Detailed isser name in the specified format.
 */
-(NSString* _Nullable)issuerDetailWithFormat:(unsigned long)format;

@end
