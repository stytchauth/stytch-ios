Pod::Spec.new do |s|
  s.name             = 'Stytch'
  s.version          = '0.1.0'
  s.summary          = 'Official Stytch iOS SDK'
  s.homepage         = 'https://stytch.com'

  s.description      = <<-DESC
Add long description of the pod here.
                       DESC

  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Edgar' => 'edgar@stytch.com' }
  s.source           = { :git => 'https://github.com/stytch/StytchSDK.git', :tag => s.version.to_s }

  s.ios.deployment_target = '12.0'

  s.ios.vendored_frameworks = 'Stytch.framework'

end
