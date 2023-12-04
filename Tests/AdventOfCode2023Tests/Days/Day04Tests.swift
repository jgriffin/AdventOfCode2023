//
// Created by John Griffin on 12/3/23
//

import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day04Tests: XCTestCase {
    // MARK: - part 1

    func testWinningPointsExample() throws {
        let cards = try! Self.inputParser.parse(Self.example)
        let points = cards.map(\.points)
        XCTAssertEqual(points.reduce(0,+), 13)
    }

    func testWinningPointsInput() throws {
        let cards = try! Self.inputParser.parse(Self.input)
        let points = cards.map(\.points)
        XCTAssertEqual(points.reduce(0,+), 23028)
    }

    // MARK: - part 2

    func testCopyGameExample() throws {
        let cards = try! Self.inputParser.parse(Self.example)
        let cardCount = playCopyGame(cards)
        XCTAssertEqual(cardCount, 30)
    }

    func testCopyGameInput() throws {
        let cards = try! Self.inputParser.parse(Self.input)
        let cardCount = playCopyGame(cards)
        XCTAssertEqual(cardCount, 9236992)
    }
}

extension Day04Tests {
    func playCopyGame(_ cards: [Card]) -> Int {
        let wonByCard = cards.reduce(into: [Card.ID: [Card.ID]]()) { result, card in
            guard card.winningCount > 0 else { return }
            result[card.id] = (1 ... card.winningCount).map { copyOffset in card.id + copyOffset }
        }

        typealias Copies = [Card.ID: Int]

        // start with a copy of originals
        var copies = Copies(uniqueKeysWithValues: cards.map { ($0.id, 1) })
        for cardId in cards.map(\.id) {
            guard let copyCount = copies[cardId] else { fatalError() }
            guard let wins = wonByCard[cardId] else { continue }
            wins.forEach { copyId in
                copies[copyId, default: 0] += copyCount
            }
        }
        return copies.map(\.value).reduce(0, +)
    }

    struct Card: Identifiable, CustomStringConvertible {
        var id: Int { cardNumber }

        let cardNumber: Int
        let winningNumbers: [Int]
        let playedNumbers: [Int]
        let winningCount: Int

        init(cardNumber: Int, winningNumbers: [Int], playedNumbers: [Int]) {
            self.cardNumber = cardNumber
            self.winningNumbers = winningNumbers
            self.playedNumbers = playedNumbers
            winningCount = playedNumbers.filter(winningNumbers.contains).count
        }

        var points: Int {
            guard winningCount > 0 else { return 0 }
            return 1 << (winningCount - 1)
        }

        var description: String {
            "Card: \(cardNumber) \(winningNumbers) | \(playedNumbers)"
        }

        static let parser = Parse(input: Substring.self, Card.init) {
            "Card"; Whitespace(); Int.parser(); ":"; Whitespace()
            numbersParser
            " |"; Whitespace()
            numbersParser
        }.eraseToAnyParser()

        static let numbersParser = Parse(input: Substring.self) {
            Many {
                Int.parser()
            } separator: {
                Many(1 ... 2) { " " }
            }
        }.eraseToAnyParser()
    }

    static let input = try! dataFromResource(filename: "Day04Input.txt").asString

    static let example: String = """
    Card 1: 41 48 83 86 17 | 83 86  6 31 17  9 48 53
    Card 2: 13 32 20 16 61 | 61 30 68 82 17 32 24 19
    Card 3:  1 21 53 59 44 | 69 82 63 72 16 21 14  1
    Card 4: 41 92 73 84 69 | 59 84 76 51 58  5 54 83
    Card 5: 87 83 26 28 32 | 88 30 70 12 93 22 82 36
    Card 6: 31 18 13 56 72 | 74 77 10 23 35 67 36 11
    """

    // MARK: - parser

    static let inputParser = Parse {
        Many { Card.parser } separator: { "\n" }
        Skip { Optionally { "\n" } }
    }

    func testParseExample() throws {
        let input = try Self.inputParser.parse(Self.example)
        XCTAssertEqual(input.count, 6)
    }

    func testParseInput() throws {
        let input = try Self.inputParser.parse(Self.input)
        XCTAssertEqual(input.count, 206)
    }
}
