Pod::Spec.new do |s|

	s.name    = 'Webtrekk'
	s.version = '1.0.0'

	s.author   = { 'Webtrekk' => 'support@webtrekk.com' }
	s.homepage = 'https://www.webtrekk.com/en/solutions/mobile-analytics/'
	s.license  = { :type => 'MIT', :file => 'LICENSE.MD' }
	s.platform = :ios, '8.0'
	s.source   = { :git => 'https://github.com/Webtrekk/webtrekk-ios.git', :tag => s.version }
	s.summary  = 'The Webtrekk SDK allows you to track user activities, screen flow and media usage for an App.'

	s.module_map = 'Module/Module.modulemap'

	s.source_files          = 'Sources/**/*.swift', 'Module/Module.h'
	s.watchos.exclude_files = 'Sources/Internal/Utility/UIDevice.swift', 'Sources/Internal/Utility/UIViewController.swift', 'Sources/Internal/Trackers/AVPlayerTracker.swift'

	s.frameworks         = 'Foundation', 'UIKit'
	s.ios.frameworks     = 'AVFoundation', 'AVKit', 'CoreTelephony'
	s.watchos.frameworks = 'WatchKit'

	s.ios.deployment_target     = '8.0'
	#s.watchos.deployment_target = '2.0' # not yet supported

	s.dependency 'CryptoSwift', '~> 0.5.1'

	s.ios.dependency 'ReachabilitySwift', '~> 2.3.3'
end
