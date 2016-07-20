public enum AnonymizableValue<HashedType> {

	case plain(HashedType)
	case hashed(md5: String?, sha256: String?)
}
