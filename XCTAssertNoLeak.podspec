Pod::Spec.new do |s|
  s.name             = 'XCTAssertNoLeak'
  s.version          = '0.2.1'
  s.summary          = 'Provides assert function that check memory leak in Swift.'
  s.description      = <<-DESC
Provides memory leak test cases for Swift.
Found memory leak objects from traverse object tree using Mirror.

                       DESC
  s.homepage         = 'https://github.com/tarunon/XCTAssertNoLeak'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'tarunon' => 'croissant9603@gmail.com' }
  s.source           = { :git => 'https://github.com/tarunon/XCTAssertNoLeak.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.osx.deployment_target = '10.11'
  s.tvos.deployment_target = '9.0'

  s.source_files = 'Sources/XCTAssertNoLeak/**/*.{swift}'
  s.framework = 'XCTest'
end
