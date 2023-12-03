import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day02Tests: XCTestCase {
    // MARK: - part 1

    func testPossiblesExample() throws {
        let games = try Self.inputParser.parse(Self.example)
        // only 12 red cubes, 13 green cubes, and 14 blue cubes
        let possibleCounts: [BallColor: Int] = [.red: 12, .green: 13, .blue: 14]

        let possibles = games.filter { isPossible($0, possibleCounts) }.map(\.number)
        XCTAssertEqual(possibles, [1, 2, 5])
        XCTAssertEqual(possibles.reduce(0,+), 8)
    }

    func testPossiblesInput() throws {
        let games = try Self.inputParser.parse(Self.input)
        // only 12 red cubes, 13 green cubes, and 14 blue cubes
        let possibleCounts: [BallColor: Int] = [.red: 12, .green: 13, .blue: 14]

        let possibles = games.filter { isPossible($0, possibleCounts) }.map(\.number)
        XCTAssertEqual(possibles.reduce(0,+), 2204)
    }

    // MARK: - part 2

    func testPowerExample() throws {
        let games = try Self.inputParser.parse(Self.example)
        let maxBalls = games.map(\.maxBalls)
        let powers = maxBalls.map { $0.values.reduce(1,*) }
        XCTAssertEqual(powers.reduce(0,+), 2286)
    }

    func testPowerInput() throws {
        let games = try Self.inputParser.parse(Self.input)
        let maxBalls = games.map(\.maxBalls)
        let powers = maxBalls.map { $0.values.reduce(1,*) }
        XCTAssertEqual(powers.reduce(0,+), 71036)
    }
}

extension Day02Tests {
    func isPossible(_ game: Game, _ possibleCounts: [BallColor: Int]) -> Bool {
        game.maxBalls.allSatisfy { color, count in
            count <= possibleCounts[color, default: 0]
        }
    }
}

extension Day02Tests {
    enum BallColor: String, ParserPrinterStringConvertible {
        case red, blue, green

        static let parser = OneOf {
            "red".map { BallColor.red }
            "blue".map { BallColor.blue }
            "green".map { BallColor.green }
        }.eraseToAnyParserPrinter()
    }

    struct BallCount: ParserPrinterStringConvertible {
        let color: BallColor
        let count: Int

        init(color: BallColor, count: Int) {
            self.color = color
            self.count = count
        }

        static let parser =
            ParsePrint(
                input: Substring.self,
                .convert(
                    apply: { count, color in BallCount(color: color, count: count) },
                    unapply: { bc in (bc.count, bc.color) }
                )
            ) {
                Int.parser()
                " "
                BallColor.parser
            }
            .eraseToAnyParserPrinter()
    }

    struct Game: ParserPrinterStringConvertible {
        let number: Int
        let draws: [[BallCount]]

        var maxBalls: [BallColor: Int] {
            draws.flatMap { $0 }.reduce(into: [:]) { result, ballCount in
                if ballCount.count > result[ballCount.color, default: 0] {
                    result[ballCount.color] = ballCount.count
                }
            }
        }

        static let parser = ParsePrint(.memberwise(Game.init)) {
            "Game "; Int.parser(); ": "
            Many {
                Many { BallCount.parser } separator: { ", " }
            } separator: { "; " }
        }.eraseToAnyParserPrinter()
    }
}

extension Day02Tests {
    static let input = try! dataFromResource(filename: "Day02Input.txt").asString

    static let example: String = """
    Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    """

    // MARK: - parser

    static let inputParser = Parse {
        Many { Game.parser } separator: { "\n" }
        Skip { Optionally { "\n" } }
    }

    func testParseExample() throws {
        let games = try Self.inputParser.parse(Self.example)
        XCTAssertEqual(games.count, 5)
    }

    func testParseInput() throws {
        let games = try Self.inputParser.parse(Self.input)
        XCTAssertEqual(games.count, 100)
    }
}
