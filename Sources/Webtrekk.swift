import Foundation



public final class Webtrekk {

	var configParser: ConfigParser?
	var config: TrackerConfiguration

	public init(configParser: ConfigParser){
		self.configParser = configParser
		self.config = configParser.trackerConfiguration
	}

	public init(config: TrackerConfiguration) {
		self.config = config
	}
}
