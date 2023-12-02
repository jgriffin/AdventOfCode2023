import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day01Tests: XCTestCase {
    // MARK: - part 1

    func testCalibrationValuesPart1Example() throws {
        let calibrationValues = try findCalibrationValuesDigits(Self.example)
        XCTAssertEqual(calibrationValues, [12, 38, 15, 77])
        XCTAssertEqual(calibrationValues.reduce(0,+), 142)
    }

    func testCalibrationValuesPart1Input() throws {
        let calibrationValues = try findCalibrationValuesDigits(Self.input)
        XCTAssertEqual(calibrationValues.reduce(0,+), 56108)
    }

    // MARK: - part 2

    func testLineValuesSimple() throws {
        let tests: [(input: String, check: [Int])] = [
            ("1", [1]),
            ("one", [1]),
        ]

        for test in tests {
            let result = lineValues(test.input[...])
            XCTAssertEqual(result, test.check)
        }
    }

    func testValuesParser() throws {
        let tests: [(input: String, check: [Int])] = [
            ("1", [1]),
            ("one", [1]),
            ("1b", [1]),
            ("1abc2", [1, 2]),
        ]

        for test in tests {
            let result = lineValues(test.input[...])
            XCTAssertEqual(result, test.check)
        }
    }

    func testCalibrationValuesPart2Example() throws {
        let calibrationValues = try findCalibrationValuesDigitsOrNames(Self.examplePart2)
        XCTAssertEqual(calibrationValues, [29, 83, 13, 24, 42, 14, 76])
        XCTAssertEqual(calibrationValues.reduce(0,+), 281)
    }

    func testCalibrationValuesPart2Input() throws {
        let calibrationValues = try findCalibrationValuesDigitsOrNames(Self.input)
        let result = calibrationValues.reduce(0,+)
        XCTAssertEqual(result, 55652)
    }
}

extension Day01Tests {
    func findCalibrationValuesDigits(_ input: String) throws -> [Int] {
        let lineDigits = input.split(separator: .newline).map { $0.compactMap(\.asDigitValue) }
        return try lineDigits.map {
            try Int($0.first.unwrapped) * 10 + Int($0.last.unwrapped)
        }
    }

    func findCalibrationValuesDigitsOrNames(_ input: String) throws -> [Int] {
        let lineDigits = input.split(separator: .newline).map(lineValues)
        let lineFirstLasts = lineDigits.map { ($0.first!, $0.last!) }
        return lineFirstLasts.map { $0.0 * 10 + $0.1 }
    }

    func lineValues(_ input: Substring) -> [Int] {
        var values: [Int] = []
        for index in input.indices {
            let substring = input[index ..< input.endIndex]
            for string in Self.digitsTrie.containedPrefixes(of: substring) {
                let value = Self.digitsMap[string]!
                values.append(value)
            }
        }
        return values
    }
}

extension Day01Tests {
    static let input = try! dataFromResource(filename: "Day01Input.txt").asString

    static let example = """
    1abc2
    pqr3stu8vwx
    a1b2c3d4e5f
    treb7uchet
    """

    static let examplePart2 = """
    two1nine
    eightwothree
    abcone2threexyz
    xtwone3four
    4nineeightseven2
    zoneight234
    7pqrstsixteen
    """

    static let digitsMap: [Substring: Int] = [
        "1": 1,
        "2": 2,
        "3": 3,
        "4": 4,
        "5": 5,
        "6": 6,
        "7": 7,
        "8": 8,
        "9": 9,
        "0": 0,

        "one": 1,
        "two": 2,
        "three": 3,
        "four": 4,
        "five": 5,
        "six": 6,
        "seven": 7,
        "eight": 8,
        "nine": 9,
    ].reduce(into: [Substring: Int]()) { result, kv in
        result[kv.key[...]] = kv.value
    }

    static let digitsTrie = Trie(digitsMap.keys)
}
