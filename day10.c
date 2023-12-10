#include <stdio.h>
#include <stdlib.h>

typedef struct koordinate {
    int x;
    int y;
} Koordinate_t;
typedef struct pipe {
    Koordinate_t a;
    Koordinate_t b;
} Pipe_t;

Pipe_t terrain[200][200];
int arePartOfLoop[200][200] = {{0}};
Koordinate_t anfang = (Koordinate_t) {0, 0};

int koordinate_equals(Koordinate_t a, Koordinate_t b) {
    if (a.x == b.x && a.y == b.y) return 1;
    return 0;
}

Koordinate_t next(Koordinate_t previous, Pipe_t current) {
    if (koordinate_equals(previous, current.a)) return current.b;
    if (koordinate_equals(previous, current.b)) return current.a;
    printf("Oh nein hier gehts nicht weiter");
    exit(2);
}

void readLine(int y, const char *line) {
    int x = 0;
    while (line[x]) {
        if (line[x] == '-') {
            terrain[x][y] = (Pipe_t) {{x - 1, y},
                                      {x + 1, y}};
        }
        if (line[x] == 'F') {
            terrain[x][y] = (Pipe_t) {{x,     y + 1},
                                      {x + 1, y}};
        }
        if (line[x] == '|') {
            terrain[x][y] = (Pipe_t) {{x, y - 1},
                                      {x, y + 1}};
        }
        if (line[x] == 'L') {
            terrain[x][y] = (Pipe_t) {{x,     y - 1},
                                      {x + 1, y}};
        }
        if (line[x] == 'J') {
            terrain[x][y] = (Pipe_t) {{x - 1, y},
                                      {x,     y - 1}};
        }
        if (line[x] == '7') {
            terrain[x][y] = (Pipe_t) {{x,     y + 1},
                                      {x - 1, y}};
        }
        if (line[x] == '.') {
            terrain[x][y] = (Pipe_t) {{0, 0},
                                      {0, 0}};
        }
        if (line[x] == 'S') {
            anfang = (Koordinate_t) {x, y};
        }
        x++;
    }
}

int pipeContains(Koordinate_t position, Pipe_t pipe) {
    return (koordinate_equals(pipe.a, position) || koordinate_equals(position, pipe.b));
}

Pipe_t getPipe(Koordinate_t position) {
    return terrain[position.x][position.y];
}

void addToLoop(Koordinate_t position) {
    Pipe_t pipe = getPipe(position);
    if (pipe.a.x == pipe.b.x) {
        arePartOfLoop[position.x][position.y] = 2;

    } else if (pipe.a.x != position.x && pipe.b.x != position.x) {
        arePartOfLoop[position.x][position.y] = 3;
    } else if (pipe.a.x > position.x || pipe.b.x > position.x) {
        arePartOfLoop[position.x][position.y] = 1;
    } else if (pipe.a.x < position.x || pipe.b.x < position.x) {
        arePartOfLoop[position.x][position.y] = -1;
    } else {
        printf("Something went wrong");
    }
}

int part1() {
    FILE *input;
    input = fopen("input10.txt", "r");
    char line[200];
    int x = 0;
    while (fgets(line, 200, input)) {
        readLine(x, line);
        x++;
    }
    Koordinate_t first = (Koordinate_t) {0, 0};
    if (pipeContains(anfang, terrain[anfang.x + 1][anfang.y])) {
        first = (Koordinate_t) {anfang.x + 1, anfang.y};
        if (koordinate_equals(getPipe(anfang).a, (Koordinate_t) {0, 0}))
            terrain[anfang.x][anfang.y].a = first;
        else {
            terrain[anfang.x][anfang.y].b = first;
        }
    }
    if (pipeContains(anfang, terrain[anfang.x - 1][anfang.y])) {
        first = (Koordinate_t) {anfang.x - 1, anfang.y};
        if (koordinate_equals(getPipe(anfang).a, (Koordinate_t) {0, 0}))
            terrain[anfang.x][anfang.y].a = first;
        else {
            terrain[anfang.x][anfang.y].b = first;
        }
    }
    if (pipeContains(anfang, terrain[anfang.x][anfang.y + 1])) {
        first = (Koordinate_t) {anfang.x, anfang.y + 1};
        if (koordinate_equals(getPipe(anfang).a, (Koordinate_t) {0, 0}))
            terrain[anfang.x][anfang.y].a = first;
        else {
            terrain[anfang.x][anfang.y].b = first;
        }
    }
    if (pipeContains(anfang, terrain[anfang.x][anfang.y - 1])) {
        first = (Koordinate_t) {anfang.x, anfang.y - 1};
        if (koordinate_equals(getPipe(anfang).a, (Koordinate_t) {0, 0}))
            terrain[anfang.x][anfang.y].a = first;
        else {
            terrain[anfang.x][anfang.y].b = first;
        }
    }

    Koordinate_t previous = anfang;
    Koordinate_t current = first;
    addToLoop(anfang);


    int counter = 1;
    while (!koordinate_equals(anfang, next(previous, getPipe(current)))) {
        addToLoop(current);
        counter++;
        Koordinate_t tmp = current;
        current = next(previous, getPipe(current));
        previous = tmp;
    }
    addToLoop(current);
    printf("Part 1: %d\n", (counter / 2) + 1);
    return (counter / 2) + 1;
}

int part2() {
    part1();
    int inLoop;
    int counter = 0;
    int last = 0;
    for (int i = 0; i < 200; i++) {
        inLoop = 0;
        last = 0;
        for (int j = 0; j < 200; j++) {
            if (arePartOfLoop[i][j] == 2) {

            } else if (arePartOfLoop[i][j] == 1) {
                if (last == 0) {
                    last = 1;
                } else if (last == -1) {
                    last = 0;
                    inLoop = !inLoop;
                } else if (last == 1) {
                    last = 0;
                }
            } else if (arePartOfLoop[i][j] == -1) {
                if (last == 0) {
                    last = -1;
                } else if (last == 1) {
                    last = 0;
                    inLoop = !inLoop;
                } else if (last == -1) {
                    last = 0;
                }
            } else if (arePartOfLoop[i][j] == 3) {
                inLoop = !inLoop;
            } else if (arePartOfLoop[i][j] == 0 && inLoop) {
                counter++;
            } else if (arePartOfLoop[i][j] == 0 && !inLoop) {

            } else {
                printf("something wrent wrong"); }
        }
    }
    printf("Part 2: %d\n", counter);
}