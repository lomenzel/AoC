#include <stdio.h>

typedef struct race {
    long time;
    long record;
} race_t;

race_t input[4] = {
        {53, 275},
        {71, 1181},
        {78, 1215},
        {80, 1524},
};

race_t testInput[3] = {
        {7, 9},
        {15, 40},
        {30, 200},
};
race_t part2testrace = {
        71530, 940200
};
race_t part2race =  {
        53717880, 275118112151524
};

long winning(race_t race){
    long wins = 0;
    for (long i = 0; i<race.time; i++){
        if((race.time - i )* i > race.record)
            wins ++;
    }
    return wins;
}

long part1() {
    long ways = 1;
    for(long i = 0; i<4; i++){
        ways *= winning(input[i]);
    }
    return ways;
}
long part2(){
    return winning(part2race);
}
void day6(){
    printf("Part 1: %ld\nPart 2: %ld\n", part1(), part2());
}