const { nextTick, cpuUsage } = require("process")

const input = require("fs")
    .readFileSync("input17.txt")
    .toString().split(/\n/).map(e => e.split('').map(e => e - 0))

const up = 0
const right = 1
const left = 3
const down = 2

function mark(x, y, richtung, trace) {
    trace = JSON.parse(JSON.stringify(trace))
    trace[y][x] = ['^', '>', 'v', '<', '?'][richtung]
    return trace
}

class Koordinate {
    constructor(x, y, richtung, steps, g, trace) {
        this.x = x;
        this.y = y;
        this.richtung = richtung;
        this.steps = steps
        this.g = g ? g : 0
        //this.trace = trace ? mark(this.x, this.y, this.richtung ?? 4, trace) : input
    }

    get next() {
        return [this.up, this.left, this.right, this.down].filter(e => {
            if (e == undefined)
                return false;
            if (this.richtung == undefined) return true
            if (this.steps > 0 && e.richtung != this.richtung) return false
            return true
        })
    }

    get cost() {
        let cost = this.g + h(this)
        if (isNaN(cost)) throw JSON.stringify([this, h(this), this.g])
        return cost
    }

    get up() {
        if (this.y > 0 && (this.richtung != up || (this.steps > -6)) && this.richtung != down) {
            return new Koordinate(this.x, this.y - 1, up, this.richtung == up ? this.steps - 1 : 3, this.g + input[this.y - 1][this.x], this.trace)
        }
    }
    get left() {
        if (this.x > 0 && (this.richtung != left || (this.steps > -6)) && this.richtung != right) {
            return new Koordinate(this.x - 1, this.y, left, this.richtung == left ? this.steps - 1 : 3, this.g + input[this.y][this.x - 1], this.trace)
        }
    }
    get right() {
        if (this.x < input[0].length - 1 && (this.richtung != right || this.steps > -6) && this.richtung != left) {
            return new Koordinate(this.x + 1, this.y, right, this.richtung == right ? this.steps - 1 : 3, this.g + input[this.y][this.x + 1], this.trace)
        }
    }
    get down() {
        if (this.y < input.length - 1 && (this.richtung != down || (this.steps > -6)) && this.richtung != up) {
            return new Koordinate(this.x, this.y + 1, down, this.richtung == down ? this.steps - 1 : 3, this.g + input[this.y + 1][this.x], this.trace)
        }
    }
}

const end = new Koordinate(input[0].length - 1, input.length - 1)
const start = new Koordinate(0, 0)

function h(aktuell, ziel) {
    ziel = ziel ? ziel : end

    sum = 0;
    for (let i = Math.min(aktuell.x, ziel.x); i < Math.max(aktuell.x, ziel.x); i++) {
        sum += input[ziel.y][i]

    }
    for (let i = Math.min(aktuell.y, ziel.y); i < Math.max(aktuell.y, ziel.y); i++) {
        sum += input[i][aktuell.x]

    }
    if (isNaN(sum)) throw JSON.stringify([aktuell, ziel, "Hmm geht nicht"])
    return sum * 2
}

function isEnd(k) {
    return k.x == end.x && k.y == end.y && k.steps < 0
}

function printTrace(trace) {
    console.log(trace.map(e => e.join("")).join("\n"))
    console.log("\n")
}

function equals(a, b) {
    return a.x == b.x && a.y == b.y && a.richtung == b.richtung && a.steps == b.steps
}

function pickMin(a) {
    let current = a[0]
    for (let e of a)
        if (e.cost < current.cost)
            current = e
    return current

}

function solution1() {
    let toCheck = new Koordinate(0, 0).next
    let visited = new Map()
    let paths = []

    let i = 0
    let currentBestG = 1170
    while (toCheck.length != 0) {
        i++



        let current = toCheck.pop()
        //let current = toCheck.reduce((minCostCoord, coord) =>
        //    coord.cost < minCostCoord.cost ? coord : minCostCoord
        //);

        //toCheck = toCheck.filter(coord => coord.g < currentBestG && !(equals(coord, current) && coord.g >= current.g));

        if (current.g >= currentBestG) continue;

        let key = JSON.stringify([current.x, current.y, current.richtung, current.steps])
        if (visited.has(key) && visited.get(key) <= current.g)
            continue;


        visited.set(key, current.g)

        if (isEnd(current)) { paths.push(current); currentBestG = current.g; console.log("found:", current.g); continue }
        if (i % 1000000 == 0) {
            console.log(current, current.cost, toCheck.length)
        }

        toCheck.push(...(current.next))

    }
    console.log(i)
    return paths.sort((a, b) => a.g - b.g)

}


console.log(new Koordinate(1, 1, 1, -3, 3).next)

res = solution1()
res.forEach(e => { console.log(e.g); printTrace(e.trace) })
console.log(res[0].g)
