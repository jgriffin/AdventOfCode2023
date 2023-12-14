//
// Created by John Griffin on 12/13/23
//

import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day12Tests: XCTestCase {
    func testExample() throws {
        let records = try Self.inputParser.parse(Self.example)

        let arrangements = records.map { Arranger.arrangements($0) }
        XCTAssertEqual(arrangements, [1, 4, 1, 1, 4, 10])
        XCTAssertEqual(arrangements.reduce(0,+), 21)
    }
    
    func testInput() throws {
        let records = try Self.inputParser.parse(Self.input)

        let arrangments = records.map { Arranger.arrangements($0) }
        XCTAssertEqual(arrangments.reduce(0,+), 7344)
    }
    
    func testUnfold() throws {
        let tests: [(input: String, check: String)] = [
            (".# 1", ".#?.#?.#?.#?.# 1,1,1,1,1"),
            ("???.### 1,1,3", "???.###????.###????.###????.###????.### 1,1,3,1,1,3,1,1,3,1,1,3,1,1,3"),
        ]
        
        for test in tests {
            let result = try Record.parser.parse(test.input).unfolded()
            XCTAssertEqual(result.description, test.check)
        }
    }

    func testUnfoldedExample() throws {
        let records = try Self.inputParser.parse(Self.example).map { $0.unfolded() }

        let arrangements = records.map { Arranger.arrangements($0) }
        XCTAssertEqual(arrangements, [1, 16384, 1, 16, 2500, 506250])
        XCTAssertEqual(arrangements.reduce(0,+), 525152)
    }
    
    func testUnfoldedInput() throws {
        let records = try Self.inputParser.parse(Self.input).map { $0.unfolded() }

        let arrangements = records.map { Arranger.arrangements($0) }
        
        XCTAssertEqual(arrangements.prefix(5), [504684, 759375, 5139, 32, 330160])
        XCTAssertEqual(arrangements.reduce(0,+), 1088006519007)
    }
}

extension Day12Tests {
    enum Arranger {
        static var cached = [Record: Int]()
        
        static func arrangements(_ record: Record) -> Int {
            let record = record.simplified()
            
            if let count = cached[record] {
                return count
            }
            
            let count = arrangementsFunc(record)
            cached[record] = count
            return count
        }
        
        static func arrangementsFunc(_ record: Record) -> Int {
            let springs = record.springs
            let sizes = record.sizes
            
            // MARK: - termination case
            
            guard let firstSize = sizes.first else {
                if springs.contains(.damaged) {
                    return 0
                } else {
                    return 1
                }
            }
            
            // MARK: - find the first unknown

            // everything up to the first .
            let firstSegment = springs.firstSegment
            guard let firstUnknownIndex = firstSegment.firstIndex(where: { $0 == .unknown }) else {
                // we know enough to fail or simplify
                assert(firstSegment.allSatisfy { $0 == .damaged })
                
                guard firstSegment.count == firstSize else {
                    return 0
                }
                
                let newRecord = Record(springs.dropFirst(firstSegment.count).asArray, sizes.dropFirst().asArray)
                return arrangements(newRecord)
            }

            // MARK: - try it both ways and add the counts
            
            var counts = 0
            
            // as operational
            var springsAsOperational = springs
            springsAsOperational[firstUnknownIndex] = .operational
            let asOperationalCount = arrangements(Record(springsAsOperational, sizes))
            counts += asOperationalCount

            // as damaged
            var springsAsDamaged = springs
            springsAsDamaged[firstUnknownIndex] = .damaged
            let asDamagedCount = arrangements(Record(springsAsDamaged, sizes))
            counts += asDamagedCount

            return counts
        }
    }
}

extension [Day12Tests.Status] {
    var firstSegment: [Day12Tests.Status].SubSequence {
        prefix(while: { $0 != .operational })
    }
    
    var lastSegment: [Day12Tests.Status].SubSequence {
        suffix(while: { $0 != .operational })
    }

    var firstUnknownIndex: [Day12Tests.Status].Index? {
        firstIndex(where: { $0 == .unknown })
    }
    
    var simplified: [Day12Tests.Status] {
        var springs = self
        
        // compact and trim .operational runs
        var i = springs.startIndex + 1
        while i < springs.endIndex {
            if springs[i] == .operational, springs[i - 1] == .operational {
                springs.remove(at: i)
            } else {
                i += 1
            }
        }
        springs.trim(while: { $0 == .operational })
        
        return springs
    }
}

extension Day12Tests {
    struct Record: Hashable, ParserPrinterStringConvertible {
        var springs: [Status]
        var sizes: [Int]

        init(_ springs: [Day12Tests.Status], _ sizes: [Int]) {
            self.springs = springs
            self.sizes = sizes
        }

        func simplified() -> Record {
            Record(springs.simplified, sizes)
        }
        
        func unfolded() -> Record {
            Record(
                5.times().map { _ in springs }.joined(by: Status.unknown).asArray,
                5.times().flatMap { _ in sizes }
            )
        }
        
        static let parser = ParsePrint(.memberwise(Record.init)) {
            Many { Status.parser }
            " "
            Many { Int.parser() } separator: { "," }
        }
    }

    enum Status: ParserPrinterStringConvertible {
        case unknown, operational, damaged
        
        static let parser = OneOf {
            "?".map { Status.unknown }
            ".".map { Status.operational }
            "#".map { Status.damaged }
        }
    }
    
    static let input = try! dataFromResource(filename: "Day12Input.txt").asString
    
    static let example: String = """
    ???.### 1,1,3
    .??..??...?##. 1,1,3
    ?#?#?#?#?#?#?#? 1,3,1,6
    ????.#...#... 4,1,1
    ????.######..#####. 1,6,5
    ?###???????? 3,2,1
    """
    
    // MARK: - parser
    
    static let inputParser = Parse {
        Many { Record.parser } separator: { "\n" }
        Skip { Optionally { "\n" } }
    }
    
    func testParseExample() throws {
        let input = try Self.inputParser.parse(Self.example)
        XCTAssertNotNil(input)
    }
    
    func testParseInput() throws {
        let input = try Self.inputParser.parse(Self.input)
        XCTAssertNotNil(input)
    }
}
