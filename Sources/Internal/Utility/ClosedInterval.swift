internal extension ClosedInterval {

	internal func clamp(value: Bound) -> Bound {
		if value < start {
			return start
		}
		if value > end {
			return end
		}

		return value
	}
}


internal extension ClosedInterval where Bound: MinimumMaximumAware {

	internal var conditionText: String {
		if start.isMinimum && end.isMaximum {
			return "any value"
		}
		if end.isMaximum {
			return ">= \(start)"
		}
		if start.isMinimum {
			return "<= \(end)"
		}

		return ">= \(start) and <= \(end)"
	}
}



internal protocol MinimumMaximumAware {

	var isMaximum: Bool { get }
	var isMinimum: Bool { get }
}


extension Float: MinimumMaximumAware {

	internal var isMaximum: Bool {
		return !isSignMinus && isInfinite
	}


	internal var isMinimum: Bool {
		return isSignMinus && isInfinite
	}
}


extension Double: MinimumMaximumAware {

	internal var isMaximum: Bool {
		return !isSignMinus && isInfinite
	}


	internal var isMinimum: Bool {
		return isSignMinus && isInfinite
	}
}


extension Int: MinimumMaximumAware {

	internal var isMaximum: Bool {
		return self == .max
	}


	internal var isMinimum: Bool {
		return self == .min
	}
}
