const input = require("fs")
    .readFileSync("input9.txt")
    .toString()
    .split(/\n/)
    .map(e => e.split(/\s+/).map(e => e - 0))

function nextValue(sequence) {
    let changes = [sequence]
    while (changes.at(-1).filter(e => e !== 0).length !== 0)
        changes.push(changeStep(changes.at(-1)))

    changes = changes.reverse()
    changes[0].push(0)
    for (let i = 0; i < changes.length - 1; i++) {
        if (changes[i].length !== changes[i + 1].length) throw "upsi"

        changes[i + 1].push(changes[i].at(-1) + changes[i + 1].at(-1))
    }
    return changes.at(-1).at(-1)

}

function previousValue(sequence) {
    return nextValue(sequence.reverse())
}

function changeStep(sequence) {
    let values = []
    for (let i = 0; i < sequence.length - 1; i++) {
        values.push(sequence[i + 1] - sequence[i])
    }
    return values
}

function part1(sequences) {
    return sequences.map(e => nextValue(e)).reduce((a, b) => a + b, 0)
}

function part2(sequences) {
    return sequences.map(e => previousValue(e)).reduce((a, b) => a + b, 0)
}

console.log("Part 1:", part1(input))
console.log("Part 2:", part2(input))