internal enum ParameterName: String {
	// MARK: Pixel
	case Pixel = "p"

	// MARK: General
	case EndOfRequest    = "eor"
	case EverId          = "eid"
	case FirstStart      = "one"
	case IpAddress       = "X-WT-IP"
	case NationalCode    = "la"
	case SamplingRate    = "ps"
	case TimeStamp       = "mts"
	case TimeZoneOffset  = "tz"
	case UserAgent       = "X-WT-UA"

	// MARK: Page
	case Page          = "cp"
	case PageCategory  = "cg"
	case Session       = "cs"

	// MARK: Action
	case ActionCategory = "ck"
	case ActionName     = "ct"

	// MARK: E-Commerce
	case EcomCategory     = "cb"
	case EcomVoucherValue = "cb563"
	case EcomCurrency     = "cr"
	case EcomOrderNumber  = "oi"
	case EcomTotalValue   = "ov"
	case EcomStatus       = "st"

	// MARK: Product
	case ProductCategory = "ca"
	case ProductName     = "ba"
	case ProductPrice    = "co"
	case ProductQuantity = "qn"

	// MARK: Customer
	case CustomerBirthday      = "uc707"
	case CustomerCategory      = "uc"
	case CustomerCity          = "uc708"
	case CustomerCountry       = "uc709"
	case CustomerEmail         = "uc700"
	case CustomerEmailReceiver = "uc701"
	case CustomerFirstName     = "uc703"
	case CustomerGender        = "uc706"
	case CustomerLastName      = "uc704"
	case CustomerNewsletter    = "uc702"
	case CustomerNumber        = "cd"
	case CustomerPhoneNumber   = "uc705"
	case CustomerStreet        = "uc711"
	case CustomerStreetNumber  = "uc712"
	case CustomerZip           = "uc710"

	// MARK: Media
	case MediaAction     = "mk"
	case MediaBandwidth  = "bw"
	case MediaCategories = "mg"
	case MediaDuration   = "mt2"
	case MediaName       = "mi"
	case MediaMute       = "mut"
	case MediaPosition   = "mt1"
	case MediaVolume     = "vol"
	case MediaTimeStamp  = "x"

	// MARK: AutoTrack
	case AdvertiserId        = "geid"
	case ConnectionType      = "connectionType"
	case RequestUrlStoreSize = "requestUrlStoreSize"
	case AppVersionCode      = "appVersionCode"
	case AppVersionName      = "appVersion"
	case ScreenOrientation   = "screenOrientation"
	case AppUpdate           = "appUpdated"


	// MARK: CrossDeviceBridge
	case CdbEmailMd5      = "cdb1"
	case CdbEmailSha256   = "cdb2"
	case CdbPhoneMd5      = "cdb3"
	case CdbPhoneSha256   = "cdb4"
	case CdbAddressMd5    = "cdb5"
	case CdbAddressSha256 = "cdb6"
	case CdbFacebook      = "cdb10"
	case CdbTwitter       = "cdb11"
	case CdbGooglePlus    = "cdb12"
	case CdbLinkedIn      = "cdb13"
}

extension ParameterName {

	static func urlParameter(fromName name: ParameterName, andValue value: String) -> String {
		return "\(name.rawValue)=\(value.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)"
	}


	static func urlParameter(fromName name: ParameterName, withIndex index: Int, andValue value: String) -> String {
		return "\(name.rawValue)\(index)=\(value.stringByAddingPercentEncodingWithAllowedCharacters(.URLQueryAllowedCharacterSet())!)"
	}

}