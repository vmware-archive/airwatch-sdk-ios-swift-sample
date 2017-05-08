### Overview
This sample app provides an overview of the common use-cases of the AirWatch SDK. Where appropriate, comments are added to the code.

#### Set Up the Sample App
The AirWatch SDK frameworks are excluded from this sample, so add them to the project prior to building the source code.

* AWKit.bundle
* SDKLocalization.bundle
* AWSDK.framework

### Run the Sample App
The AirWatch SDK is implemented in this project. After the AirWatch SDK libraries are added, build the an IPA file and upload the build to the AirWatch Console.

#### Create an SDK Profile
Configure the default SDK settings or create an SDK profile in the AirWatch Console to set the correct payloads for the app.

#### Upload the App to AirWatch
* Add the app to the AirWatch Console.
* Add the SDK settings to the app.
* Set the App Assignment to the correct Smart Groups.
* Save and Publish the changes.

### Install the App on the Device and Run It.
When running the app from Xcode, make sure the app is also whitelisted on the AirWatch console. Additionally, the device needs to be enrolled into an instance of AirWatch and the app is assigned to the device.


