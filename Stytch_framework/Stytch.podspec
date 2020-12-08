Pod::Spec.new do |s|
  s.name             = 'Stytch'
  s.version          = '1.0.0'
  s.summary          = 'Stytch is a platform for user authentication.'
  s.homepage         = 'https://stytch.com'

  s.description      = <<-DESC
The Stytch iOS SDK makes it quick and easy to build user authentication for your iOS app. We provide powerful and customizable UI screens and elements that can be used out-of-the-box to build your sign up and sign in flows. We also expose the low-level APIs that power those UIs so that you can build fully custom experiences.
                       DESC

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Edgar' => 'edgar@stytch.com' }
  s.source           = { :git => 'https://github.com/stytch/StytchSDK.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'

  s.ios.vendored_frameworks = 'Stytch.framework'

end
