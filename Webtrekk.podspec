Pod::Spec.new do |s|

	s.name    = 'Webtrekk'
	s.version = '1.0.0'

	s.author   = { 'Benjamin Werker' => 'benjamin@widgetlabs.eu' }
	s.homepage = 'https://github.com/webtrekk/webtrekk-ios'
	s.license  = 'MIT'
	s.platform = :ios, '8.0'
	s.source   = { :git => 'https://github.com/webtrekk/webtrekk-ios.git' }
	s.summary  = 'The Webtrekk SDK allows you to track user activities, screen flow and media usage for an App. All data is send to the Webtrekk tracking system for further analysis.'

	s.module_map    = 'Module/Module.modulemap'
	s.source_files  = ['Sources/**/*.swift', 'Module/Module.h']
	s.frameworks    = 'AVKit', 'Foundation', 'CoreTelephony', 'UIKit'

	s.dependency 'CryptoSwift',       '~> 0.4.1'
	s.dependency 'ReachabilitySwift', '~> 2.3.3'
end
