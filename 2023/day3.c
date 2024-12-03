#include <stdio.h>
#include <string.h>

typedef struct gear {
    int toMany;
    int a;
    int b;

} gear_t;

gear_t gears[150][150];

int getPartNumbers(const char *line, const char *previous, const char *next, int hasPrevious, int hasNext) {
    int sum = 0;
    int i = 0;
    int numb = 0;
    int isPart = 0;

    while (line[i]) {
        if (line[i] < '0' || line[i] > '9') {
            if (isPart)
                sum += numb;
            numb = 0;
            isPart = 0;
        } else if (line[i] <= '9' && line[i] >= '0') {
            numb *= 10;
            numb += line[i] - '0';
            if (!isPart) {
                if (i - 1 >= 0 && line[i - 1] != '.' && (line[i - 1] < '0' || line[i - 1] > '9'))
                    isPart = 1;
                if (line[i + 1] != '\n' && line[i + 1] != '.' && (line[i + 1] < '0' || line[i + 1] > '9'))
                    isPart = 1;

                for (int j = i - 1; j <= i + 1 && hasPrevious && !isPart; j++) {
                    if (j >= 0 && previous[j] != '\n' && previous[j] != '.' && (previous[j] < '0' || previous[j] > '9'))
                        isPart = 1;
                }
                for (int j = i - 1; j <= i + 1 && hasNext && !isPart; j++) {
                    if (j >= 0 && next[j] != '\n' && next[j] != '.' && (next[j] < '0' || next[j] > '9'))
                        isPart = 1;
                }
            }
        }
        i++;
    }
    if (isPart)
        sum += numb;
    numb = 0;
    isPart = 0;

    return sum;
}

void setGear(int line, int col, int number) {
    if (!gears[line][col].toMany) {
        if (gears[line][col].b) gears[line][col].toMany = 1;
        if (!gears[line][col].a) gears[line][col].a = number;
        else gears[line][col].b = number;
    }
}

void getGears(const char *line, const char *previous, const char *next, int hasPrevious, int hasNext, int lineNumber) {
    int i = 0;
    int numb = 0;
    int isPart = 0;
    int row;
    int col;

    while (line[i]) {
        if (line[i] < '0' || line[i] > '9') {
            if (isPart && numb)
                setGear(row, col, numb);
            numb = 0;
            isPart = 0;
        } else if (line[i] <= '9' && line[i] >= '0') {
            numb *= 10;
            numb += line[i] - '0';
            if (!isPart) {
                if (i - 1 >= 0 && line[i - 1] == '*') {
                    isPart = 1;
                    row = lineNumber;
                    col = i - 1;
                }
                if (line[i + 1] == '*') {
                    isPart = 1;
                    row = lineNumber;
                    col = i + 1;
                }
                for (int j = i - 1; j <= i + 1 && hasPrevious && !isPart; j++) {
                    if (j >= 0 && previous[j] == '*') {
                        isPart = 1;
                        row = lineNumber - 1;
                        col = j;
                    }
                }
                for (int j = i - 1; j <= i + 1 && hasNext && !isPart; j++) {
                    if (j >= 0 && next[j] == '*') {
                        isPart = 1;
                        row = lineNumber + 1;
                        col = j;
                    }
                }
            }
        }
        i++;
    }
    if (isPart && numb)
        setGear(row, col, numb);
    numb = 0;
    isPart = 0;
}

int day3part1() {

    FILE *input;
    input = fopen("input3.txt", "r");
    char line[200];
    char previous[200];
    char next[200];
    int sum = 0;

    fgets(line, 200, input);
    fgets(next, 200, input);
    sum += getPartNumbers(line, NULL, next, 0, 1);


    strcpy(previous, line);
    strcpy(line, next);

    while (fgets(next, 200, input)) {
        sum += getPartNumbers(line, previous, next, 1, 1);
        strcpy(previous, line);
        strcpy(line, next);
    }
    sum += getPartNumbers(line, previous, NULL, 1, 0);
    printf("%d", sum);
    return 0;
}

int day3part2() {
    FILE *input;
    input = fopen("input3.txt", "r");
    char line[200];
    char previous[200];
    char next[200];
    int lineNumber = 0;
    fgets(line, 200, input);
    fgets(next, 200, input);
    getGears(line, NULL, next, 0, 1, lineNumber);
    lineNumber++;

    strcpy(previous, line);
    strcpy(line, next);

    while (fgets(next, 200, input)) {
        getGears(line, previous, next, 1, 1, lineNumber);
        lineNumber++;
        strcpy(previous, line);
        strcpy(line, next);
    }
    getGears(line, previous, NULL, 1, 0, lineNumber);

    int sum = 0;
    for (int i = 0; i < 150; ++i) {
        for (int j = 0; j < 150; ++j) {
            if (!gears[i][j].toMany) {
                sum += gears[i][j].a * gears[i][j].b;
            }
        }

    }
    printf("%d", sum);

    return 0;
}
