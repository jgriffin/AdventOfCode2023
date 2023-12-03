//
// Created by John Griffin on 12/2/23
//
import EulerTools
import Parsing

public protocol ParserPrinterStringConvertible: CustomStringConvertible {
    associatedtype Printer: ParserPrinter where Printer.Output == Self, Printer.Input == Substring
    static var parser: Printer { get }
}

public extension ParserPrinterStringConvertible {
    var description: String {
        try! Self.parser.print(self).asString
    }
}
