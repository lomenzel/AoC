const input = require("fs").readFileSync("input5.txt").toString()
let maps = input.split(/\n{2}/)
maps.shift()

maps = maps.map(map => {
    map = map.split(/\n/)
        .filter(r => r !== "").map(r => {
            r = r.split(/ /).map(n => n - 0)
            return r
        })
    map.shift()
    return map
})

function toLocation(seed) {
    seed = seed - 0

    for (let map of maps) {
        for (let e of map) {

            if (seed >= e[1] && seed <= e[1] + e[2]) {
                seed = e[0] + (seed - e[1])
                break
            }


        }

    }
    return seed
}

function pairs(arr) {
    let p = []
    for (let i = 0; i < arr.length; i += 2) {
        p.push([arr[i] - 0, arr[i + 1] - 0])
    }

    return p
}

function toLocationRanges(ranges) {
    if (ranges.length == 0)
        throw "no seeds"
    let tmp = new Set()
    addToSet(tmp, ranges)
    ranges = tmp
    let nextRanges = new Set();
    for (let map of maps) {
        nextRanges = new Set;
        for (let r of setToArray(ranges)) {
            let splitted = new Set();
            for (let e of map) {
                addToSet(splitted, split(r, e).filter(e => !e.enthalten).map(e => e.range))
                addToSet(nextRanges, split(r, e).filter(fe => fe.enthalten).map(me => shift(me.range, e)))
            }
            cutted = setToArray(splitted).map(r => {
                let cutted = [r];
                for (let me of map) {
                    cutted = cutted.map(ce => cut(ce, me)).flat(1)
                }
                return cutted
            }).flat(1)
            addToSet(nextRanges, cutted)

        }
        ranges = nextRanges

    }
    return setToArray(ranges)

}

function shift(range, e) {
    return [range[0] + (e[0] - e[1]), range[1]]
}

function cut(range, e) {
    return split(range, e).filter(e => !e.enthalten).map(e => e.range)
}

function split(range, e) {
    if (range[1] === 0) throw ["range of length 0", range, e]
    cr = [range[0], range[0] + range[1] - 1]
    ce = [e[1], e[1] + e[2] - 1]

    //wenn komplett enthalten
    if (cr[0] >= ce[0] && cr[1] <= ce[1])
        return [{enthalten: true, range: range}]

    //wenn auf beiden seiten überlappend
    if (cr[0] < ce[0] && cr[1] > ce[1])
        return [
            {enthalten: false, range: [cr[0], ce[0] - cr[0]]},
            {enthalten: true, range: [ce[0], ce[1] - ce[0] + 1]},
            {enthalten: false, range: [ce[1] + 1, cr[1] - ce[1]]}
        ]


    //wenn komplett außerhalb
    if ((cr[1] < ce[0]) || (cr[0] > [ce[1]])) {
        return [{enthalten: false, range: range}]
    }

    //wenn links
    if (cr[0] < ce[0] && cr[1] <= ce[1] && cr[1] >= ce[0])
        return [
            {enthalten: false, range: [cr[0], ce[0] - cr[0]]},
            {enthalten: true, range: [ce[0], cr[1] - ce[0] + 1]}
        ]
    //wenn rechts
    if (cr[0] >= ce[0] && cr[0] <= ce[1] && cr[1] > ce[1])
        return [
            {enthalten: true, range: [cr[0], ce[1] - cr[0] + 1]},
            {enthalten: false, range: [ce[1] + 1, cr[1] - ce[1]]}
        ]
    throw {message: "wtf", range: range, e: e, cr: cr, ce: ce}
}

function addToSet(set, arr) {
    arr.forEach(e => {
        set.add(JSON.stringify(e))
    });
}

function setToArray(set) {
    return [...set].map(JSON.parse)
}


function part1() {

    return input
        .split(/\n{2}/)[0]
        .split(/\D+/)
        .filter(e => e !== "")
        .map(e => toLocation(e))
        .sort((a, b) => a - b)[0]
}

function part2(data) {
    let seeds = pairs(input.split(/\n{2}/)[0]
        .split(/\D+/).filter(e => e !== ""))

    return toLocationRanges(seeds)

        .sort((a, b) => (a[0] - b[0]))[0][0]
}

//part2()
console.log("Part 1:", part1())
console.log("Part 2:", part2())
