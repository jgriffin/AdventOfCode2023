import Foundation
import Parsing

public enum Day20 {
    public enum Module: Equatable {
        public typealias Name = Substring

        case broadcaster(outputs: [Name])
        case flipFlop(Name, outputs: [Name])
        case conjunction(Name, outputs: [Name])

        public var name: Name {
            switch self {
            case .broadcaster: "broadcaster"
            case let .flipFlop(name, _): name
            case let .conjunction(name, _): name
            }
        }

        var outputs: [Name] {
            switch self {
            case let .broadcaster(outputs): outputs
            case let .flipFlop(_, outputs): outputs
            case let .conjunction(_, outputs): outputs
            }
        }

        static let parser = OneOf {
            Parse {
                Module.broadcaster(outputs: $0)
            } with: {
                "broadcaster -> "
                Many { nameParser } separator: { ", " }
            }

            Parse {
                Module.flipFlop($0, outputs: $1)
            } with: {
                "%"; nameParser; " -> "
                Many { nameParser } separator: { ", " }
            }

            Parse {
                Module.conjunction($0, outputs: $1)
            } with: {
                "&"; nameParser; " -> "
                Many { nameParser } separator: { ", " }
            }
        }

        static let nameParser = Parse { CharacterSet.letters }
    }

    static let input = """
    %vn -> ts, lq
    &ks -> dt
    %zt -> vl
    %xg -> ts, pb
    &xd -> qz, bc, zt, vk, hq, qx, gc
    &pm -> dt
    %gb -> vj, xd
    %qx -> gb
    %rl -> qn
    %lq -> gk
    %qm -> bf
    %zn -> vh, pf
    %lz -> kk, vr
    %bf -> rr
    %gx -> vr
    %zr -> vx, pf
    %lt -> ng, vr
    %hd -> mg, xd
    %mg -> xd
    %tx -> jg, vr
    %gk -> kx, ts
    &vr -> tr, vf, tx, ks, kk, jg
    broadcaster -> qz, tx, jr, hk
    %bc -> qx
    %xz -> lt, vr
    %jg -> sb
    %qn -> zr, pf
    %gc -> xv
    %vx -> lj, pf
    %vf -> cn
    &dt -> rx
    %sb -> lz, vr
    %kx -> xg
    %hk -> pf, tv
    %cb -> pf
    &dl -> dt
    %vl -> xd, bc
    %fl -> pp, pf
    %ng -> vr, gx
    %jr -> ts, qm
    %cd -> vn, ts
    %mt -> ts
    %rr -> ts, cd
    %tr -> xz
    %hq -> zt
    %xv -> hq, xd
    %vj -> xd, hd
    %pp -> zn
    %vh -> pf, cb
    %cn -> vr, tr
    %kk -> vf
    &pf -> pp, tv, rl, pm, hk
    &ts -> dl, qm, kx, lq, bf, jr
    %tv -> rl
    &vk -> dt
    %pb -> ts, mt
    %lj -> pf, fl
    %qz -> xd, gc

    """
}
