const input = require("fs")
    .readFileSync("input8.txt")
    .toString()
    .split(/\n{2}/)
    .map(e => e.split(/\n/))

instructions = input[0][0].split("").map(e => e=="L"? 0 : 1)
let map = new Map()

input[1].forEach(line => {
    line = line.split(/[^A-Z0-9]+/)
    map.set(line[0], [line[1],line[2]])
})

let location = 'AAA'
let steps = 0;


//part 1
 while(location !== 'ZZZ'){
     location = map.get(location)[instructions[steps % instructions.length]]
     steps++
 }

let part1 = steps

//Part 2
let locations = [...map.keys()].filter(key => key[2] == 'A')

locations = locations.map(location =>{
    let steps = 0
    while(location[2] !== 'Z'){
        location = map.get(location)[instructions[steps % instructions.length]]
        steps++
    }
    return steps
})

let part2 = locations.reduce(kgV, 1);



function ggT(z1,z2) {
	var m = z1;
	var n = z2;
	var r = 1;
	while(r != 0) {
		if(m < n) {
			var h = m;
			m = n;
			n = h;
		}
		r = m - n;
		m = n;
		n = r;
	}
	return m;
}
function kgV(z1,z2) {
	return z1 * z2 / ggT(z1,z2);
	
}

console.log("Part 1:", part1)
console.log("Part 2:", part2)