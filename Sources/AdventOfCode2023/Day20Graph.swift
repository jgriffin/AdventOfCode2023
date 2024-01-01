import Grape
import Parsing
import SwiftUI

struct Day20Graph: View {
    @State var isRunning = false
    let graphData = getData(miserables)

    var body: some View {
        ForceDirectedGraph(isRunning: $isRunning) {
            flipFlop("vn") // -> ts, lq
            conjunction("ks") // -> dt
            flipFlop("zt") // -> vl
            flipFlop("xg") // -> ts, pb
            conjunction("xd") // -> qz, bc, zt, vk, hq, qx, gc
            conjunction("pm") // -> dt
            flipFlop("gb") // -> vj, xd
            flipFlop("qx") // -> gb
            flipFlop("rl") // -> qn
            flipFlop("lq") // -> gk
            flipFlop("qm") // -> bf
            flipFlop("zn") // -> vh, pf
            flipFlop("lz") // -> kk, vr
            flipFlop("bf") // -> rr
            flipFlop("gx") // -> vr
            flipFlop("zr") // -> vx, pf
            flipFlop("lt") // -> ng, vr
            flipFlop("hd") // -> mg, xd
            flipFlop("mg") // -> xd
            flipFlop("tx") // -> jg, vr
            flipFlop("gk") // -> kx, ts
            conjunction("vr") // -> tr, vf, tx, ks, kk, jg
            broadcaster() //  -> qz, tx, jr, hk
            flipFlop("bc") // -> qx
            flipFlop("xz") // -> lt, vr
            flipFlop("jg") // -> sb
            flipFlop("qn") // -> zr, pf
            flipFlop("gc") // -> xv
            flipFlop("vx") // -> lj, pf
            flipFlop("vf") // -> cn
            conjunction("dt") // -> rx
            flipFlop("sb") // -> lz, vr
            flipFlop("kx") // -> xg
            flipFlop("hk") // -> pf, tv
            flipFlop("cb") // -> pf
            conjunction("dl") // -> dt
            flipFlop("vl") // -> xd, bc
            flipFlop("fl") // -> pp, pf
            flipFlop("ng") // -> vr, gx
            flipFlop("jr") // -> ts, qm
            flipFlop("cd") // -> vn, ts
            flipFlop("mt") // -> ts
            flipFlop("rr") // -> ts, cd
            flipFlop("tr") // -> xz
            flipFlop("hq") // -> zt
            flipFlop("xv") // -> hq, xd
            flipFlop("vj") // -> xd, hd
            flipFlop("pp") // -> zn
            flipFlop("vh") // -> pf, cb
            flipFlop("cn") // -> vr, tr
            flipFlop("kk") // -> vf
            conjunction("pf") // -> pp, tv, rl, pm, hk
            conjunction("ts") // -> dl, qm, kx, lq, bf, jr
            flipFlop("tv") // -> rl
            conjunction("vk") // -> dt
            flipFlop("pb") // -> ts, mt
            flipFlop("lj") // -> pf, fl
            flipFlop("qz") // -> xd, gc
            output("rx")

            "broadcaster" --> "qz"
            "broadcaster" --> "tx"
            "broadcaster" --> "jr"
            "broadcaster" --> "hk"

            "vn" --> "ts"
            "vn" --> "lq"
            "ks" --> "dt"
            "zt" --> "vl"
            "xg" --> "ts"
            "xg" --> "pb"
            "xd" --> "qz"
            "xd" --> "bc"
            "xd" --> "zt"
            "xd" --> "vk"
            "xd" --> "hq"
            "xd" --> "qx"
            "xd" --> "gc"
            "pm" --> "dt"
            "gb" --> "vj"
            "gb" --> "xd"
            "qx" --> "gb"
            "rl" --> "qn"
            "lq" --> "gk"
            "qm" --> "bf"
            "zn" --> "vh"
            "zn" --> "pf"
            "lz" --> "kk"
            "lz" --> "vr"
            "bf" --> "rr"
            "gx" --> "vr"
            "zr" --> "vx"
            "zr" --> "pf"
            "lt" --> "ng"
            "lt" --> "vr"
            "hd" --> "mg"
            "hd" --> "xd"
            "mg" --> "xd"
            "tx" --> "jg"
            "tx" --> "vr"
            "gk" --> "kx"
            "gk" --> "ts"
            "vr" --> "tr"
            "vr" --> "vf"
            "vr" --> "tx"
            "vr" --> "ks"
            "vr" --> "kk"
            "vr" --> "jg"
            "bc" --> "qx"
            "xz" --> "lt"
            "xz" --> "vr"
            "jg" --> "sb"
            "qn" --> "zr"
            "qn" --> "pf"
            "gc" --> "xv"
            "vx" --> "lj"
            "vx" --> "pf"
            "vf" --> "cn"
            "dt" --> "rx"
            "sb" --> "lz"
            "sb" --> "vr"
            "kx" --> "xg"
            "hk" --> "pf"
            "hk" --> "tv"
            "cb" --> "pf"
            "dl" --> "dt"
            "vl" --> "xd"
            "vl" --> "bc"
            "fl" --> "pp"
            "fl" --> "pf"
            "ng" --> "vr"
            "ng" --> "gx"
            "jr" --> "ts"
            "jr" --> "qm"
            "cd" --> "vn"
            "cd" --> "ts"
            "mt" --> "ts"
            "rr" --> "ts"
            "rr" --> "cd"
            "tr" --> "xz"
            "hq" --> "zt"
            "xv" --> "hq"
            "xv" --> "xd"
            "vj" --> "xd"
            "vj" --> "hd"
            "pp" --> "zn"
            "vh" --> "pf"
            "vh" --> "cb"
            "cn" --> "vr"
            "cn" --> "tr"
            "kk" --> "vf"
            "pf" --> "pp"
            "pf" --> "tv"
            "pf" --> "rl"
            "pf" --> "pm"
            "pf" --> "hk"
            "ts" --> "dl"
            "ts" --> "qm"
            "ts" --> "kx"
            "ts" --> "lq"
            "ts" --> "bf"
            "ts" --> "jr"
            "tv" --> "rl"
            "vk" --> "dt"
            "pb" --> "ts"
            "pb" --> "mt"
            "lj" --> "pf"
            "lj" --> "fl"
            "qz" --> "xd"
            "qz" --> "gc"
        } forceField: {
            ManyBodyForce(strength: -20)
            LinkForce(
                originalLength: .constant(25),
                stiffness: .constant(1.0)
            )
            CenterForce(strength: 0.2)
            CollideForce()
        }
        .toolbar {
            Button {
                isRunning = !isRunning
            } label: {
                Image(systemName: isRunning ? "pause.fill" : "play.fill")
                Text(isRunning ? "Pause" : "Start")
            }
        }
    }

    func broadcaster() -> NodeMark<String> {
        NodeMark(id: "broadcaster", fill: .broadcaster, radius: 5,
                 label: "broadcaster")
    }

    func flipFlop(_ id: String) -> NodeMark<String> {
        NodeMark(id: id, fill: .flipFlop, radius: 5)
    }

    func conjunction(_ id: String) -> NodeMark<String> {
        NodeMark(id: id, fill: .conjunction, radius: 5)
    }

    func output(_ id: String) -> NodeMark<String> {
        NodeMark(id: id, fill: .output, radius: 5)
    }
}

#Preview {
    NavigationView {
        Day20Graph(isRunning: true)
    }
    .navigationViewStyle(.stack)
}

extension Color {
    static let broadcaster = Color.blue
    static let flipFlop = Color.green
    static let conjunction = Color.red
    static let output = Color.yellow
}

let colors: [Color] = [
    .init(red: 17.0 / 255, green: 181.0 / 255, blue: 174.0 / 255),
    .init(red: 64.0 / 255, green: 70.0 / 255, blue: 201.0 / 255),
    .init(red: 246.0 / 255, green: 133.0 / 255, blue: 18.0 / 255),
    .init(red: 222.0 / 255, green: 60.0 / 255, blue: 130.0 / 255),
    .init(red: 17.0 / 255, green: 181.0 / 255, blue: 174.0 / 255),
    .init(red: 114.0 / 255, green: 224.0 / 255, blue: 106.0 / 255),
    .init(red: 22.0 / 255, green: 124.0 / 255, blue: 243.0 / 255),
    .init(red: 115.0 / 255, green: 38.0 / 255, blue: 211.0 / 255),
    .init(red: 232.0 / 255, green: 198.0 / 255, blue: 0.0 / 255),
    .init(red: 203.0 / 255, green: 93.0 / 255, blue: 2.0 / 255),
    .init(red: 0.0 / 255, green: 143.0 / 255, blue: 93.0 / 255),
    .init(red: 188.0 / 255, green: 233.0 / 255, blue: 49.0 / 255),
]
