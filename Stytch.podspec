Pod::Spec.new do |s|
  s.name         = 'Stytch'
  s.version      = `Scripts/current-version`.strip
  s.summary      = "A Swift SDK for using Stytch's user-authentication products on Apple platforms."
  s.homepage     = 'https://github.com/stytchauth/stytch-swift'
  s.license      = {
    :type => 'MIT',
    :file => 'LICENSE'
  }
  s.authors      = {
      'Dan Loman' => 'dan@stytch.com'
  }
  s.source       = {
    :git => 'https://github.com/stytchauth/stytch-swift.git',
    :tag => s.version.to_s
  }

  s.ios.deployment_target  = '13.0'
  s.osx.deployment_target  = '10.15'
  s.tvos.deployment_target = '13.0'

  s.swift_version = '5.5'

  s.documentation_url = "https://stytchauth.github.io/stytch-swift/documentation/stytchcore/"

  s.default_subspec = 'StytchCore'

  s.subspec 'StytchCore' do |s|
    s.source_files = 'Sources/StytchCore/**/*'
    s.exclude_files = "**/Documentation*/**/*"
  end
end
