<a href="https://www.kickstarter.com"><img src=".github/ksr-wordmark.svg" width="36%" alt="Kickstarter for iOS"></a>

[![Circle CI](https://circleci.com/gh/kickstarter/ios-oss.svg?style=svg)](https://circleci.com/gh/kickstarter/ios-oss)

Welcome to Kickstarter’s open source iOS app! Come on in, take your shoes off,
stay a while—explore how Kickstarter’s native squad has built and continues to
build the app.

We’ve also open sourced our [Android app](https://github.com/kickstarter/android-oss),
and read more about our journey to open source [here](https://kickstarter.engineering/open-sourcing-our-android-and-ios-apps-6891be909fcd).

## Getting Started

1. Install Xcode. We currently support XCode 14.3 Swift 5.8.
2. Clone this repository.

&#42; To provide a mock version that serves up hard-coded data immediately, set `KsApi.Secrets.isOSS` = `true`.

## Some fun things to explore

If you’re just looking for a quick glance at a few things we’re particularly
proud of, look no further:

* The snapshots directory in each feature folder of `Kickstarter-Framework-iOS` together holds nearly 600 screenshots of various screens in every language,
device and edge-case state that we like to make sure stays true. For example,
a backer viewing a project in Japanese
[here](https://github.com/kickstarter/ios-oss/blob/main/Kickstarter-iOS/Features/ProjectPage/Controller/__Snapshots__/ProjectPageViewControllerTests/testLoggedIn_Backer_LiveProject_NonUS_ProjectCurrency_US_ProjectCountry_NonUS_UserChosenCurrency_NotOmittingCurrencyCode_Success.lang_ja_device_pad.png)
, or a creator looking at their dashboard in German and on an iPad
[here](https://github.com/kickstarter/ios-oss/blob/main/Kickstarter-iOS/Features/Dashboard/Controller/__Snapshots__/DashboardViewControllerTests/testView.lang_de_device_pad.png).

* [We use view models](https://www.youtube.com/watch?v=EpTlqx6NjYo) as
a lightweight way to isolate side effects and embrace a functional core. We
write [these](https://github.com/kickstarter/ios-oss/tree/main/Library/ViewModels)
as a pure mapping of input signals to output signals, and [test](https://github.com/kickstarter/ios-oss/tree/main/Library/ViewModels)
them heavily, including tests for localization, accessibility and event
tracking.

## Testing the project

- Run all tests from the command line by running `make test-all`.
- Run an individual scheme's tests by selecting that scheme in Xcode and hitting CMD+U.

## Documentation

While we’re at it, why not share our docs? Check out the
[native docs](https://github.com/kickstarter/native-docs) we have written so far
for more documentation.

## Dependencies

We make heavy use of the following projects, and so it can be helpful to be
familiar with them:

### 1st party

* [![Circle CI](https://circleci.com/gh/kickstarter/Kickstarter-Prelude.svg?style=svg)](https://circleci.com/gh/kickstarter/Kickstarter-Prelude)
[Prelude](https://github.com/kickstarter/Kickstarter-Prelude): Foundation of
types and functions we feel are missing from the Swift standard library. 

* [![Circle CI](https://circleci.com/gh/kickstarter/Kickstarter-ReactiveExtensions.svg?style=svg&)](https://circleci.com/gh/kickstarter/Kickstarter-ReactiveExtensions)
[ReactiveExtensions](https://github.com/kickstarter/Kickstarter-ReactiveExtensions):
A collection of operators we like to add to ReactiveCocoa. Built on top of ReactiveSwift.

### 3rd party

* [AlamofireImage](https://github.com/Alamofire/AlamofireImage)
* [SnapshotTesting](https://github.com/pointfreeco/swift-snapshot-testing)
* [Apollo](https://github.com/apollographql/apollo-ios)
* [Stripe](https://github.com/stripe/stripe-ios)
* [KingFisher](https://github.com/onevcat/Kingfisher)
* [SwiftSoup](https://github.com/scinfu/SwiftSoup)
* [Facebook](https://github.com/facebook/facebook-ios-sdk)
* [Firebase](https://github.com/firebase/firebase-ios-sdk)
* [Appboy](https://github.com/Appboy/Appboy-segment-ios)
* [PerimeterX](https://github.com/PerimeterX/px-iOS-Framework)

Notices for 3rd party libraries in this repository are contained in
`NOTICE.md`.

## Contributing

We intend for this project to be an educational resource: we are excited to
share our wins, mistakes, and methodology of iOS development as we work
in the open. Our primary focus is to continue improving the app for our users in
line with our roadmap.

The best way to submit feedback and report bugs is to open a GitHub issue.
Please be sure to include your operating system, device, version number, and
steps to reproduce reported bugs. Keep in mind that all participants will be
expected to follow our code of conduct.

## Code of Conduct

We aim to share our knowledge and findings as we work daily to improve our
product, for our community, in a safe and open space. We work as we live, as
kind and considerate human beings who learn and grow from giving and receiving
positive, constructive feedback. We reserve the right to delete or ban any
behavior violating this base foundation of respect.

## Find this interesting?

We do too, and we’re [hiring](https://www.kickstarter.com/jobs)!

## License

```
Copyright 2021 Kickstarter, PBC.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
```
