Pod::Spec.new do |spec|
  spec.name             = 'StytchCore'
  spec.version          = '0.1.0'
  spec.summary          = "The StytchCore SDK is the easiest way for you to use Stytch's authentication products on Apple platforms."
  spec.homepage         = 'https://github.com/stytchauth/stytch-swift'
  spec.license          = { :type => 'MIT', :file => 'LICENSE' }
  spec.authors           = { 'Dan Loman' => 'dan@stytch.com' }
  spec.source           = { :git => 'https://github.com/stytchauth/stytch-swift.git', :tag => spec.version.to_s }
  spec.ios.deployment_target = '11.3'
  spec.osx.deployment_target = '10.13'
  spec.swift_version = '5.5'
  spec.source_files = 'Sources/StytchCore/**/*'
  spec.exclude_files = "**/Documentation*/**/*"
  spec.documentation_url = "https://stytch-swift.github.io/documentation/stytchcore"
end
