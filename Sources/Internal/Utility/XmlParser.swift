import Foundation


internal struct XmlElement {

	internal var attributes: [String : String]
	internal var children: [XmlElement]
	internal var path: [String]
	internal var text: String


	internal var name: String {
		return path.last ?? ""
	}


	internal init(attributes: [String : String], children: [XmlElement], path: [String], text: String) {
		self.attributes = attributes
		self.children = children
		self.path = path
		self.text = text
	}
}


internal final class XmlParser {

	internal func parse(xml data: NSData) throws -> XmlElement {
		return try ActualParser(xml: data).rootElement
	}
}


private final class ActualParser: NSObject {

	private var currentText = ""
	private var elementBuilder: ElementBuilder?
	private var elementBuilderStack = [ElementBuilder]()
	private var elementPath = [String]()
	private var error: ErrorType?
	private let parser: NSXMLParser
	private lazy var rootElement: XmlElement = lazyPlaceholder()


	private init(xml data: NSData) throws {
		self.parser = NSXMLParser(data: data)

		super.init()

		parser.delegate = self
		parser.parse()
		parser.delegate = nil

		if let error = error {
			throw error
		}
	}



	private final class ElementBuilder {

		private let attributes: [String : String]
		private var children = [XmlElement]()
		private let path: [String]
		private var text = ""


		private init(attributes: [String : String], path: [String]) {
			self.attributes = attributes
			self.path = path
		}


		private func build() -> XmlElement {
			return XmlElement(attributes: attributes, children: children, path: path, text: text)
		}
	}
}


extension ActualParser: NSXMLParserDelegate {

	@objc
	private func parser(parser: NSXMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName: String?) {
		guard let elementBuilder = elementBuilder else {
			fatalError()
		}

		currentText = currentText.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())

		elementBuilder.text = currentText

		let element = elementBuilder.build()

		if let parentElementBuilder = elementBuilderStack.popLast() {
			parentElementBuilder.children.append(element)

			self.elementBuilder = parentElementBuilder
		}
		else {
			rootElement = element

			self.elementBuilder = nil
		}

		currentText = ""
		elementPath.removeLast()
	}


	@objc
	private func parser(parser: NSXMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName: String?, attributes: [String : String]) {
		currentText = ""
		elementPath.append(elementName)

		if let elementBuilder = elementBuilder {
			elementBuilderStack.append(elementBuilder)
		}

		elementBuilder = ElementBuilder(attributes: attributes, path: elementPath)
	}


	@objc
	private func parser(parser: NSXMLParser, foundCharacters string: String) {
		currentText += string
	}


	@objc
	private func parser(parser: NSXMLParser, parseErrorOccurred parseError: NSError) {
		if error == nil {
			error = parseError
		}
	}
}
