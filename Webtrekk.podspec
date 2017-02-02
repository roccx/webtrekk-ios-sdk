Pod::Spec.new do |s|

	s.name    = 'Webtrekk'
	s.version = '4.4.0'

	s.author   = { 'Webtrekk' => 'arsen.vartbaronov@webtrekk.com' }
	s.homepage = 'https://www.webtrekk.com/en/solutions/mobile-analytics/'
	s.license  = { :type => 'MIT', :file => 'LICENSE.MD' }
    s.ios.deployment_target = '8.0'
    s.tvos.deployment_target = '9.0'
    s.watchos.deployment_target = '2.0'
    s.source   = { :git => 'https://github.com/Webtrekk/webtrekk-ios-sdk.git', :tag => s.version }
	s.summary  = 'The Webtrekk SDK allows you to track user activities, screen flow and media usage for an App.'

	s.module_map = 'Module/Module.modulemap'

	s.source_files          = 'Sources/**/*.swift', 'Module/Module.h'
    s.ios.exclude_files = 'Sources/Internal/Utility/WKInterfaceController.swift'
    s.tvos.exclude_files = 'Sources/Internal/Utility/WKInterfaceController.swift'
    s.watchos.exclude_files = 'Sources/Internal/Utility/UIDevice.swift', 'Sources/Internal/Utility/UIViewController.swift', 'Sources/Internal/Trackers/AVPlayerTracker.swift', 'Sources/Internal/Features/DeepLink.swift'

	s.frameworks         = 'Foundation', 'UIKit'
	s.ios.frameworks     = 'AVFoundation', 'AVKit', 'CoreTelephony'
	s.watchos.frameworks = 'WatchKit'

	s.dependency 'CryptoSwift', '0.6.7'

	s.ios.dependency 'ReachabilitySwift', '~> 3.0.0'
    s.tvos.dependency 'ReachabilitySwift', '~> 3.0.0'
end
