use_frameworks!

install! "cocoapods", :share_schemes_for_development_pods => false

pod "Webtrekk", :path => ".."


def base_pods
    inherit! :search_paths
    pod 'OHHTTPStubs', '~> 6.0.0'
    pod 'OHHTTPStubs/Swift', '~> 6.0.0'
end

def main_pods
    base_pods
    pod 'Nimble', '~> 7.0.1'
end

abstract_target "iOS" do
	platform :ios, "8.0"

    target "ModuleTest" do
        target "Tests" do
        main_pods
        end
    end
end

abstract_target "tvOS" do
    platform :tvos, "9.0"
    
    target "SampleTVApp" do
        target "SampleTVAppTests" do
        main_pods
        end
    end
end

abstract_target "watchOS" do
    platform :watchos, "2.0"
    
    target "WatchApp" do
        target "WatchApp Extension" do
        pod "Webtrekk", :path => ".."
        base_pods
        end
    end
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            if target.name != 'Nimble-iOS' && target.name != 'Nimble-tvOS'
                config.build_settings['SWIFT_VERSION'] = '4.0'
                else
                config.build_settings['SWIFT_VERSION'] = '3.2'
            end
        end
    end
end

