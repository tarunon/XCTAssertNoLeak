# XCTAssertNoLeak
[![Build Status](https://travis-ci.org/tarunon/XCTAssertNoLeak.svg?branch=master)](https://travis-ci.org/tarunon/XCTAssertNoLeak)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
![pod](https://img.shields.io/cocoapods/v/XCTAssertNoLeak.svg)

Provides memory leak test cases for Swift.

![](https://github.com/tarunon/XCTAssertNoLeak/blob/master/Readme/screenshot.png?raw=true)

Found memory leak objects from traverse object tree using Mirror.

# Support version
|Swift|Support|Note|
|-|-|-|
|5.0|○|-|
|4.2 (Xcode 10.2)|○|-|
|4.2 (Xcode 10.1)|×|[SR-8878](https://bugs.swift.org/browse/SR-8878)|
|4.1|○|-|

# Instration

## Carthage
```rb
github "tarunon/XCTAssertNoLeak"
```

## CocoaPods
Write it below Pods for testing.
```rb
pod 'XCTAssertNoLeak'
```
