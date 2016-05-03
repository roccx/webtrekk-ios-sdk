Pod::Spec.new do |s|

	s.name    = 'Webtrekk'
	s.version = '0.0.1'

	s.author   = { 'Benjamin Werker' => 'benjamin@widgetlabs.eu' }
	s.homepage = 'https://github.com/webtrekk/webtrekk-ios'
	s.license  = 'MIT'
	s.platform = :ios, '8.0'
	s.source   = { :git => 'https://github.com/webtrekk/webtrekk-ios.git' }
	s.summary  = 'TODO'

	s.module_map    = 'Module/Webtrekk.modulemap'
	s.source_files  = ['Sources/**/*.swift', 'Module/Webtrekk.h']
	s.frameworks    = 'AVKit', 'Foundation', 'UIKit', 'SWXMLHash', 'ReachabilitySwift', 'CryptoSwift'
end
