#include <stdio.h>

typedef struct game {
    int green;
    int red;
    int blue;
    int id;
} game_t;

game_t toGame(const char *line) {
    int i = 0;
    while (line[i] > '9' || line[i] < '0')
        i++;
    game_t game;

    int id = 0;
    while (line[i] <= '9' && line[i] >= '0') {
        id *= 10;
        id += line[i] - '0';
        i++;
    }
    game.id = id;
    game.red = 0;
    game.green = 0;
    game.blue = 0;
    while (line[i]) {
        int number = 0;
        while (line[i] > '9' || line[i] < '0') {
            if(!line[i]) break;
            i++;
        }
        if(!line[i])  break;
        while (line[i] <= '9' && line[i] >= '0') {
            number *= 10;
            number += line[i] - '0';
            i++;
        }
        i++;
        if (line[i] == 'r')
            game.red = game.red < number? number: game.red;
        if (line[i] == 'g')
            game.green = game.green < number? number: game.green;
        if (line[i] == 'b')
            game.blue = game.blue < number? number: game.blue;
        number = 0;
    }
    printf("Game %d: %d red, %d green, %d blue\n", game.id, game.red, game.green, game.blue);
    return game;
}

int day2part1() {

    FILE *input;
    input = fopen("input2.txt", "r");
    char line[200];
    int sum = 0;
    while (fgets(line, 200, input)) {
        game_t game =  toGame(line);
        if(game.red <= 12 && game.green <= 13 &&  game.blue <= 14)
            sum += game.id;
    }
    printf("%d", sum);
    return 0;
}
int day2part2(){
    FILE *input;
    input = fopen("input2.txt", "r");
    char line[200];
    int sum = 0;
    while (fgets(line, 200, input)) {
        game_t game =  toGame(line);
        sum += game.red * game.blue * game.green;
    }
    printf("%d", sum);
    return 0;
}
