public enum HashableTrackingValue<HashedType> {

	case plain(HashedType)
	case md5(String)
	case sha256(String)
}
