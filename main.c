#include <stdio.h>


int number(const char *line) {
    if (line[0] <= '9' && line[0] >= '0')
        return line[0] - '0';

    if (line[0] == 'o')
        if (line[1] == 'n')
            if (line[2] == 'e')
                return 1;


    if (line[0] == 't')
        if (line[1] == 'w')
            if (line[2] == 'o')
                return 2;

    if (line[0] == 't')
        if (line[1] == 'h')
            if (line[2] == 'r')
                if (line[3] == 'e')
                    if (line[4] == 'e')
                        return 3;

    if (line[0] == 'f')
        if (line[1] == 'o')
            if (line[2] == 'u')
                if (line[3] == 'r')
                    return 4;
    if (line[0] == 'f')
        if (line[1] == 'i')
            if (line[2] == 'v')
                if (line[3] == 'e')
                        return 5;

    if (line[0] == 's')
        if (line[1] == 'i')
            if (line[2] == 'x')
                return 6;

    if (line[0] == 's')
        if (line[1] == 'e')
            if (line[2] == 'v')
                if (line[3] == 'e')
                    if (line[4] == 'n')
                        return 7;
    if (line[0] == 'e')
        if (line[1] == 'i')
            if (line[2] == 'g')
                if (line[3] == 'h')
                    if (line[4] == 't')
                        return 8;
    if (line[0] == 'n')
        if (line[1] == 'i')
            if (line[2] == 'n')
                if (line[3] == 'e')
                        return 9;
    return -1;
}

int getFirst(const char *line) {
    int i = 0;
    while (line[i]) {
        if (number(line + i) > -1)
            return number(line + i);
        i++;
    }
    return 0;
}

int getLast(const char *line) {
    int i = 0;
    int last = 0;
    while (line[i]) {
        if (number(line + i)> -1)
            last = number(line + i);
        i++;
    }
    return last;
}

int day1() {
    FILE *input;
    input = fopen("test.txt", "r");
    char line[100];

    int sum = 0;

    while (fgets(line, 100, input)) {
        sum += 10 * getFirst(line);
        sum += getLast(line);
        printf("%d %d \n", getFirst(line), getLast(line));
    }

    printf("%d\n", sum);

    return 0;
}
