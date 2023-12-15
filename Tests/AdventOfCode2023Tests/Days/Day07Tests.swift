//
// Created by John Griffin on 12/7/23
//

import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day07Tests: XCTestCase {
    func testScoreHandsExample() throws {
        let hands = try Self.inputParser.parse(Self.example)
        XCTAssertEqual(hands.map(\.type), [.onePair, .threeOfAKind, .twoPair, .twoPair, .threeOfAKind])

        let ranked = hands.sorted().reversed().asArray
        let scores = ranked.enumerated().map { ($0 + 1) * $1.bid }
        let totalScore = scores.reduce(0, +)
        XCTAssertEqual(totalScore, 6440)
    }

    func testScoreHandsInput() throws {
        let hands = try Self.inputParser.parse(Self.input)
        let ranked = hands.sorted().reversed().asArray
        let scores = ranked.enumerated().map { ($0 + 1) * $1.bid }
        let totalScore = scores.reduce(0, +)
        XCTAssertEqual(totalScore, 255_048_101)
        XCTAssert(totalScore < 255_843_111, "not right answer")
    }

    func testWildScoreHandsExample() throws {
        let hands = try Self.inputParser.parse(Self.example)
        let wildHands = hands.map(\.asJokers)
        let ranked = wildHands.sorted().reversed().asArray
        let scores = ranked.enumerated().map { ($0 + 1) * $1.bid }
        let totalScore = scores.reduce(0, +)
        XCTAssertEqual(totalScore, 5905)
    }

    func testWildScoreHandsInput() throws {
        let hands = try Self.inputParser.parse(Self.input)
        let wildHands = hands.map(\.asJokers)
        let ranked = wildHands.sorted().reversed().asArray
        let scores = ranked.enumerated().map { ($0 + 1) * $1.bid }
        let totalScore = scores.reduce(0, +)
        XCTAssertEqual(totalScore, 253_718_286)
    }
}

extension Day07Tests {
    // Note: comparable is reversed - better is lower
    struct Hand: Comparable, CustomStringConvertible {
        typealias CardCount = (card: Card, count: Int)
        enum HandType: Comparable { case fiveOfAKind, fourOfAKind, fullHouse, threeOfAKind, twoPair, onePair, highCard }

        let cards: [Card]
        let bid: Int
        let cardCounts: [CardCount]
        let type: HandType

        init(cards: [Card], bid: Int) {
            self.cards = cards
            self.bid = bid
            cardCounts = Self.cardCountsFrom(cards)
            type = Self.typeFromCardCounts(cardCounts)
        }

        var asJokers: Hand {
            let jokerCards = cards.map { $0 == .J ? .joker : $0 }
            return .init(cards: jokerCards, bid: bid)
        }

        static func cardCountsFrom(_ cards: [Card]) -> [CardCount] {
            var counts = ElementCounts(cards).countOf
            if let jokerCount = counts[.joker] {
                counts[.joker] = nil
                let addToCard = counts.max { lhs, rhs in lhs.value < rhs.value }?.key
                counts[addToCard ?? .A, default: 0] += jokerCount
            }

            return counts.map { (card: $0.key, count: $0.value) }
                .sorted(by: \.count, thenDesc: \.card).reversed().asArray
        }

        static func typeFromCardCounts(_ cardCounts: [CardCount]) -> HandType {
            let startsWithMap: [(counts: [Int], type: HandType)] = [
                ([5], .fiveOfAKind),
                ([4], .fourOfAKind),
                ([3, 2], .fullHouse),
                ([3], .threeOfAKind),
                ([2, 2], .twoPair),
                ([2], .onePair),
                ([1, 1, 1, 1, 1], .highCard),
            ]
            let counts = cardCounts.map(\.count)
            return startsWithMap.first(where: { counts.starts(with: $0.counts) })!.type
        }

        var description: String {
            "\(cardCounts.map { String(repeating: $0.card.description, count: $0.count) }.joined().asString) \(type)"
        }

        static func < (lhs: Hand, rhs: Hand) -> Bool {
            guard lhs.type == rhs.type else {
                return lhs.type < rhs.type
            }
            return lhs.cards.lexicographicallyPrecedes(rhs.cards)
        }

        static func == (lhs: Day07Tests.Hand, rhs: Day07Tests.Hand) -> Bool {
            zip(lhs.cardCounts, rhs.cardCounts)
                .allSatisfy { l, r in l.count == r.count && l.card == r.card }
        }

        // MARK: - parse

        static let parser = Parse {
            Hand(cards: $0, bid: $1)
        } with: {
            Many(5) { Card.parser }
            " "
            Digits()
        }
    }

    // No comparable is better - higher is lower
    enum Card: CaseIterable, Comparable, Hashable, ParserPrinterStringConvertible {
        case A, K, Q, J, ten, nine, eight, seven, six, five, four, three, two, joker

        static let parser = ParsePrint(input: Substring.self) {
            OneOf {
                "A".map { Card.A }
                "K".map { Card.K }
                "Q".map { Card.Q }
                "J".map { Card.J }
                "T".map { Card.ten }
                "9".map { Card.nine }
                "8".map { Card.eight }
                "7".map { Card.seven }
                "6".map { Card.six }
                "5".map { Card.five }
                "4".map { Card.four }
                "3".map { Card.three }
                "2".map { Card.two }
                "j".map { Card.joker }
            }
        }
    }

    static let input = try! dataFromResource(filename: "Day07Input.txt").asString

    static let example: String = """
    32T3K 765
    T55J5 684
    KK677 28
    KTJJT 220
    QQQJA 483
    """

    // MARK: - parser

    static let inputParser = Parse {
        Many { Hand.parser } separator: { "\n" }
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
