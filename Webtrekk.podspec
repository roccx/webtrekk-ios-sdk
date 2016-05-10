Pod::Spec.new do |s|

	s.name    = 'Webtrekk'
	s.version = '1.0.0'

	s.author   = { 'Benjamin Werker' => 'benjamin@widgetlabs.eu' }
	s.homepage = 'https://github.com/webtrekk/webtrekk-ios'
	s.license  = 'MIT'
	s.platform = :ios, '8.0'
	s.source   = { :git => 'https://github.com/webtrekk/webtrekk-ios.git' }
	s.summary  = 'TODO'

	s.module_map    = 'Module/Webtrekk.modulemap'
	s.source_files  = ['Sources/**/*.swift', 'Module/Webtrekk.h']
	s.frameworks    = 'AVKit', 'Foundation', 'UIKit'
	s.dependency    'SWXMLHash',         '2.1.0'
	s.dependency    'ReachabilitySwift', '2.3.3'
	s.dependency    'CryptoSwift',       '0.4.1'
end
