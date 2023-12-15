//
// Created by John Griffin on 12/15/23
//

import AdventOfCode2023
import EulerTools
import Parsing
import XCTest

final class Day15Tests: XCTestCase {
    func testHash() {
        let input = "HASH"
        XCTAssertEqual(input.hash, 52)
    }

    func testExample() throws {
        let input = Self.example.split(separator: ",")
        let result = input.map(\.hash).reduce(0,+)
        XCTAssertEqual(result, 1320)
    }

    func testInput() throws {
        let input = Self.input.trimmingCharacters(in: .newlines).split(separator: ",")
        let result = input.map(\.hash).reduce(0,+)
        XCTAssertEqual(result, 507_666)
    }

    func testLensesExample() throws {
        let instructions = try Self.inputParser.parse(Self.example)
        let boxer = Boxer(instructions)

        XCTAssertEqual(boxer.boxes.values.sorted(by: \.id), [
            .init(id: 0, lenses: [.init("rn", 1), .init("cm", 2)]),
            .init(id: 1, lenses: []),
            .init(id: 3, lenses: [.init("ot", 7), .init("ab", 5), .init("pc", 6)]),
        ])

        XCTAssertEqual(boxer.focusPower, 145)
    }

    func testLensesInput() throws {
        let instructions = try Self.inputParser.parse(Self.input)
        let boxer = Boxer(instructions)
        XCTAssertEqual(boxer.focusPower, 233_537)
    }
}

extension Day15Tests {
    typealias Label = Substring
    typealias FocusPower = Int

    struct Boxer: CustomStringConvertible {
        var boxes: [Box.ID: Box] = [:]

        init() {}

        init(_ instructions: [Instruction]) {
            self.init()
            apply(instructions)
        }

        var focusPower: Int {
            boxes.values.map(\.focusPower).reduce(0,+)
        }

        mutating func apply(_ instructions: [Instruction]) {
            instructions.forEach {
                apply($0)
            }
        }

        mutating func apply(_ instruction: Instruction) {
            let boxId = instruction.boxId

            switch instruction {
            case let .assign(label, power):
                boxes[boxId, default: Box(id: boxId, lenses: [])]
                    .upsert(label, power: power)
            case let .remove(label):
                boxes[boxId]?.remove(label)
            }
        }

        var description: String {
            boxes.values.sorted(by: \.id).map(\.description).joinedByNewlines
        }
    }

    struct Box: Identifiable, Equatable, CustomStringConvertible {
        let id: Int
        var lenses: [Lens]

        var focusPower: Int {
            lenses.enumerated().map { i, lens in
                (id + 1) * (i + 1) * lens.power
            }.reduce(0,+)
        }

        mutating func remove(_ label: Label) {
            if let index = lenses.firstIndex(where: { $0.label == label }) {
                lenses.remove(at: index)
            }
        }

        mutating func upsert(_ label: Label, power: FocusPower) {
            guard let lensIndex = lenses.firstIndex(where: { $0.label == label }) else {
                lenses.append(Lens(label, power))
                return
            }

            lenses[lensIndex].power = power
        }

        var description: String { "box: \(id) \(lenses)" }
    }

    struct Lens: Equatable, CustomStringConvertible {
        let label: Label
        var power: FocusPower

        init(_ label: some StringProtocol, _ power: FocusPower) {
            self.label = Substring(label)
            self.power = power
        }

        var description: String { "\(label): \(power)" }
    }

    enum Instruction {
        case assign(Label, FocusPower)
        case remove(Label)

        var label: Label {
            switch self {
            case let .assign(label, _),
                 let .remove(label):
                return label
            }
        }

        var boxId: Box.ID { label.hash }

        static let parser = Parse {
            OneOf {
                Parse {
                    CharacterSet.letters; "="; Digits()
                }.map { Instruction.assign($0, $1) }
                Parse {
                    CharacterSet.letters; "-"
                }.map { Instruction.remove($0) }
            }
        }
    }
}

private extension StringProtocol {
    var hash: Int {
        map { Int($0.asciiValue!) }.reduce(0) { result, next in
            (result + next) * 17 % 256
        }
    }
}

extension Day15Tests {
    static let input = try! dataFromResource(filename: "Day15Input.txt").asString

    static let example: String = """
    rn=1,cm-,qp=3,cm=2,qp-,pc=4,ot=9,ab=5,pc-,pc=6,ot=7
    """

    // MARK: - parser

    static let inputParser = Parse {
        Many { Instruction.parser } separator: { "," }
        Skip { Optionally { "\n" } }
    }.eraseToAnyParser()

    func testParseExample() throws {
        let input = try Self.inputParser.parse(Self.example)
        XCTAssertNotNil(input)
    }

    func testParseInput() throws {
        let input = try Self.inputParser.parse(Self.input)
        XCTAssertNotNil(input)
    }
}
