## Overview
This sample app provides an overview of the common use-cases of the AirWatch SDK. Where appropriate, comments are added to the code. The current code base is using the 17.5 Beta version of the new [Swift SDK](https://support.air-watch.com/articles/115008882887).

  * For access to the Beta version of the SDK please follow the instructions in the above article.


## Set Up the Sample App
The AirWatch SDK frameworks are excluded from this sample, they will need to be added to the project prior to building the source code. 

* AWSDK.framework
* AWOpenSSL.framework


### Build the Sample App
The AirWatch SDK is implemented in this project. After the AirWatch SDK libraries are added, build an IPA file and upload the build to the AirWatch Console.
 
 * **Note:** The Sample App needs to be whitelisted against an AirWatch environment. Uploading an IPA to the AirWatch Console accomplishes this task.

#### Create an SDK Profile
Configure the default SDK settings or create an SDK profile in the AirWatch Console to set the correct payloads for the app.

* Several of the example View Controllers check for SDK profile settings and demonstrate how to configure if they have not been configured previously.

#### Upload the App to AirWatch
* Add the app to the AirWatch Console.
* Add the SDK settings to the app.
* Set the App Assignment to the correct Smart Groups.
* Save and Publish the changes.

### Install the App on the Device and Run It.
When running the app from Xcode, make sure the app is also whitelisted on the AirWatch console. Additionally, the device needs to be enrolled into an instance of AirWatch and the app is assigned to the device.

 * **Note:** The SDK currently requires a physical device in order to run. If the app is run on a simulator then it will not function correctly.

## Resources

* [Developer Center](https://code.vmware.com/web/workspace-one)
* [Community Forums](https://support.air-watch.com/search/results?requiredfields=forumName:Mobile%20App%20Development.contentType:Forum%20Posts&sort=meta:updatedOn:D&partialfields=languageId:en&version=9.1)
* [Knowledge Base](https://support.air-watch.com/search/results?requiredfields=forumName:Developer%20Support.contentType:KB%20Articles&sort=meta:updatedOn:D&partialfields=languageId:en&version=9.1)

## Filing Issues

* For issues with the AirWatch SDK, please contact [AirWatch Support](https://support.air-watch.com/).	

 


