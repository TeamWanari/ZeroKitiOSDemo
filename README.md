# ZeroKitiOSDemo

For more info about ZeroKit and the project, please read our blogpost:
http://leaks.wanari.com/2017/03/09/zerokit-firebase-demo-app-first-look/

To init the app, you have to create two accounts:
  1. ZeroKit account: https://tresorit.com/zerokit you will need your brand new Service URL to set in the Info.plist file.
  2. Firebase account: https://console.firebase.google.com you have to create a new project and add your app,
     then setup Firebase realtime database and get the GoogleService-Info.plist config file and add it to your project.
     
You also have to setup a backend to handle API calls and AdminAPI approvals, you can reach at
https://github.com/TeamWanari/ZeroKitBackend

Check out the Android demo here:
https://github.com/TeamWanari/ZeroKitAndroidDemo
     
Demo features:
  1.  Registration
  2.  Login (plus Remember me option, requires device)
  3.  Logout
  4.  Tresor creation - when you create a new table it always generates a new tresor for it
  5.  Sharing tresor
  6.  Invite (with password)
  7.  Deeplink with invite
  8.  Accept invitiation (with password)
  9.  Encrypt
  10. Decrypt

# License

This software is licensed under the Apache 2 license, quoted below.

Copyright 2017 Wanari, Inc.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
