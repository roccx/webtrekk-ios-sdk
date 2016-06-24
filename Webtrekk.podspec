Pod::Spec.new do |s|

	s.name    = 'Webtrekk'
	s.version = '1.0.0'

	s.author   = { 'Benjamin Werker' => 'benjamin@widgetlabs.eu' }
	s.homepage = 'https://github.com/webtrekk/webtrekk-ios'
	s.license  = 'MIT'
	s.platform = :ios, '8.0'
	s.source   = { :git => 'https://github.com/webtrekk/webtrekk-ios.git' }
	s.summary  = 'TODO'

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
