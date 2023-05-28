#include <iostream>
#include <string>
#include <stdlib.h>
#include <time.h>
using namespace std;

/*Prints the rules of the game*/
void rules(){
    /*Prints rules*/
    cout << "Each tile either contains a mine, or a number. Your goal is to flag each t";
    cout << "ile containing a mine and clear each tile that doesn't. Tiles showing \"-";
    cout << "\" have not been checked, tiles showing \"!\" have been flagged as having ";
    cout << "a mine, and showing a number show you the total number of mines in adjacen";
    cout << "t tiles (including diagonals). You must use these numbers to deduce the lo";
    cout << "cations of all mines to win. If you clear a tile that shows a number on it";
    cout << ", all adjacent non-flagged tiles will be cleared.\n\nPress <enter> to cont";
    cout << "inue\n\n";
    
    /*Pauses program until user presses enter*/
    string placeholder;
    getline(cin, placeholder);
}

/*Take user input for difficulty/rules*/
    /*Easy: 10x10 w/ 12 mines*/
    /*Difficult: 15x15 w/ 35 mines*/
    /*Rules: Prints the rules of the game*/
int difficulty(){
    /*Declares difficulty variable and a temporary string for error handling*/
    int diff = 0;
    string temp_diff;

    /*Repeats until user enters a valid input*/
    while (diff < 1 || diff > 3){

        /*Gets user input*/
        cout << "Choose a difficulty\n\t1: Easy\n\t2: Normal\n\t3: Difficult\n\t4: Rules\n";
        getline(cin, temp_diff);

        /*Checks if input is valid*/
        try{
            
            /*Prints rules if 3 is chosen*/
            if (stoi(temp_diff) == 4)
                rules();

            /*If input is between 1 and 3, sets to diff, else prints an error message*/
            if (stoi(temp_diff) >= 1 && stoi(temp_diff) <= 4)
                diff = stoi(temp_diff);
            else
                cout <<"Error: Please ensure your input is between 1 and 3.\n";
        }

        /*If input is not a number, prints an error message*/
        catch(exception& e){
            cout << "Error: Please ensure your input is a number.\n";
        }
    }

    /*Once a valid input has been given, returns it*/
    return diff;
}



/*Initialize Board*/
    /*Create a 2D int array, set each position to 10*/
    /*Easy: Create a 12x12 array. This array will be treated as 10x10 with one layer
    extra on each side to make the mine counting function easier to write*/
    /*Normal: Create a 17x17 array. This array will be treated as 15x15 with one layer
    extra on each side to make the mine counting function easier to write*/
    /*Difficult: Create a 27x27 array. This array will be treated as a 25x25 with one
    layer extra on each side to make the mine counting function easier to write*/
int** create_board(int diff){
    /*Determines size*/
    int size = 12;
    if (diff == 2)
        size = 17;
    if (diff == 3)
        size = 27;

    /*Initializes the 2D array*/
    int** board = new int*[size];

    /*Sets each value in the array to 10 (unchecked number tile)*/
    for (int i = 0; i < size; i++){
        int * row = new int[size];
        for (int j = 0; j < size; j++)
            row[j] = 10;
        board[i] = row;
    }

    /*Returns array*/
    return board;
}

/*Set tiles to mines. Tiles will have "-" (10) if unchecked, "!" (11) if correctly
flagged for a mine, "!" (12) if incorrectly flagged for a mine, "-" (9) for a mine,
or a number 0-8 for how many mines (9 or 11) are in adjacent spaces*/
    /*Easy: Repeat 12 times*/
    /*Difficult: Repeat 35 times*/
        /*Generate 2 random numbers*/
        /*Check if location is set to 9*/
            /*If not, set location to 9 and increment counter*/
void set_mines(int** board, int diff){
    /*Creates a counter for the correct number of mines and sets a variable to mod for
    the correct board size*/
    int counter = 12;
    int mod = 10;
    if (diff == 2){
        counter = 35;
        mod = 15;
    }
    else if (diff == 3){
        counter = 100;
        mod = 25;
    }

    /*Seeds random nunmber generator*/
    srand( (unsigned)time(NULL) );

    /*Loops until 12, 35 or 100 mines have been placed*/
    while (counter){
        
        /*Generates a random x and y value within the 2D arary*/
        int x = rand() % mod + 1;
        int y = rand() % mod + 1;

        /*If the position is not a mine, changes it to a mine and decrements counter*/
        if (board[x][y] == 10){
            board[x][y] = 9;
            counter--;
        }
    }
}



/*Print the map with*/
        /*Easy: Numbers 1-10 on the left and on top*/
        /*Difficult: Numbers 1-15 on the left and on top*/
        /*If the number held in the arrays is 0-8, print that*/
        /*If the number is 9 or 10, print "-"*/
        /*If the number is 11 or 12, print "!"*/
void print(int** board, int diff){
    /*Sets an upper bound for the print loops based on the difficulty*/
    int max = 11;
    if (diff == 2)
        max = 16;
    else if (diff == 3)
        max = 26;

    /*Prints the top row (numbers labeling each position)*/
    cout << "    ";
    for (int i = 1; i < max; i++){
        cout << " " << i;

        /*Prints an extra space for small numbers to keep numbers lined up*/
        if (i < 10)
            cout << " ";
    }
    cout << "\n    ";
    for (int i = 1; i < max; i++)
        cout << "___";
    cout << "\n";

    /*Prints each position of the array and the left column of numbers and counts the
    number of mines*/
    int mines = 0, flags = 0;
    for (int i = 1; i < max; i++){

        /*Prints the left column of numbers*/
        cout << i << " ";

        /*Prints an extra space for small numbers to keep numbers lined up*/
        if (i < 10)
            cout << " ";
        cout << "|";
        
        /*Prints each position in the row*/
        for (int j = 1; j < max; j++){

            /*Prints "-" for unchecked tiles and unchecked mines, "!" for flagged mines
            and incorrectly flagged non-mine tiles, else, the number of adjacent mines*/
            if (board[i][j] == 9 || board[i][j] == 10)
                cout << " - ";
            else if (board[i][j] == 11 || board[i][j] == 12)
                cout << " ! ";
            else if (board[i][j] == 0)
                cout << "   ";
            else
                cout << " " << board[i][j] << " ";

            /*increments counter for each mine and increments a different counter for
            each flag*/
            if (board[i][j] == 9 || board[i][j] == 11)
                mines++;
            if (board[i][j] == 11 || board[i][j] == 12)
                flags++;
        }

        /*Ends each row after it has been printed*/
        cout << "\n";
    }

    cout << "You have placed " << flags << " flags. There are " << mines << " total mines.\n\n";
}

/*Takes a user input for row, column or action*/
int input(int diff, string word){
    /*Declares a position and string position variable for error handling*/
    int position = 0;
    string temp_position;

    /*Sets a maximum input value based on difficulty*/
    int max = 10;
    if (diff == 2)
        max = 15;
    else if (diff == 3)
        max = 25;

    /*Special case for input of 1 or 2*/
    if (diff == -1)
        max = 2;

    /*Repeats until user gives a valid input*/
    while (position < 1 || position > max){

        /*Asks user for a position input or special case action input*/
        if (max != 2)
            cout << "Choose a " << word << " (1-" << max << ")\n";
        else
            cout << "Choose an action:\n\t1: Clear location\n\t2: Flag/Unflag location\n";

        /*Gets the user input*/
        getline(cin, temp_position);

        /*Checks if input is valid*/
        try{

            /*If input is in valid range, sets to position variable, else prints an error*/
            if (stoi(temp_position) >= 1 && stoi(temp_position) <= max)
                position = stoi(temp_position);
            else
                cout << "Error: Please ensure your input is between 1 and " << max << ".\n";
        }

        /*If input is not a number, prints error message*/
        catch(exception &e){
            cout << "Error: Please ensure your input is a number.\n";
        }
    }

    /*Once user gives a valid input, returns it*/
    return position;
}

/*Toggle flag*/
    /*If location is set to 9, set location to 11*/
    /*If location is set to 10, set location to 12*/
    /*If location is set to 11, set to 9*/
    /*If locatin is set to 12, set to 10*/
void toggle_flag(int** board, int row, int col){
    /*Switches from unmarked mine (9) to marked mine (11) or from unmarked non-mine (10)
    to incorrectly flagged non-mine (12) or vice-versa. Else prints an error message*/
    if (board[row][col] == 9)
        board[row][col] = 11;
    else if (board[row][col] == 10)
        board[row][col] = 12;
    else if (board[row][col] == 11)
        board[row][col] = 9;
    else if (board[row][col] == 12)
        board[row][col] = 10;
    else
        cout << "This location has already been cleared.\n";
}

/*Counts and returns the number of mines in adjacent (including diagonals) tiles to the
provided one*/
int adjacent_mines(int** board, int row, int col, int max){
    /*Initializes mine counter*/
    int count = 0;

    /*Checks each adjacent tile, if there is a mine (9) or flagged mine (11), incrementes
    counter*/
    for (int i = -1; i <= 1; i++){
        for (int j = -1; j <= 1; j++){
            if (row + i > 0 && row + i < max && col + j > 0 && col + j < max){
                if (board[row + i][col + j] == 9 || board[row + i][col + j] == 11)
                    count++;
            }
        }
    }

    /*Returns counter*/
    return count;
}

/*Clear location function*/
    /*If location is set to 9, end game with a player loss message*/
    /*If location is set to 11 or 12, give error message saying players can't clear
    flagged spaces*/
    /*If location is set to 0-8, give error message saying players can't clear the
    same space twice*/
    /*Else counts adjacent miines*/
void clear_tile(int** board, int row, int col, int diff, int recursed){
    /*Sets maximum values based on difficulty*/
    int max = 11;
    if (diff == 2)
        max = 16;
    else if (diff == 3)
        max = 26;

    /*If the location has a mine (9), ends game with player loss. If flagged with a mine
    (11 or 12), gives an error message for trying to clear a flagged tile. If already
    cleared, (0-8) gives an error message for trying to clear an already cleared tile,
    else counts surrounding mines and assigns that value.*/
    if (board[row][col] == 9){
        cout << "\n\nYou tried to clear a mine. You lose.\n";
        exit(EXIT_FAILURE);
    }
    else if (board[row][col] == 11 || board[row][col] == 12){
        if (!recursed)
            cout << "Locations flagged for mines cannot be cleared. Unflag this tile and try again if you really want to clear it\n";
    }
    else if (board[row][col] >= 0 && board[row][col] <= 8){
        /*If the player clears an already revealed tile, it will clear each non-flagged
        tile surrounding it*/
        if (!recursed)
            for (int i = -1; i <= 1; i++){
                for (int j = -1; j <= 1; j++)
                    clear_tile(board, row + i, col + j, diff, 1);
            }
        return;
    }
    else
        board[row][col] = adjacent_mines(board, row, col, max);

    if (row == 0 || col == 0 || row == max || col == max)
        return;

    /*If there are no adjacent mines, automatically clears each surrounding tile*/
    if (board[row][col] == 0){
        for (int i = -1; i <= 1; i++){
            for (int j = -1; j <= 1; j++)
                clear_tile(board, row + i, col + j, diff, 1);
        }
    }
}

/*Check for player win*/
    /*Check each location in the array for a 9, 10 or 12*/
        /*If one is found, break*/
        /*If none are found, print player victory message*/
void win(int** board, int diff){
    /*Sets a max value to check on the array based on difficulty*/
    int max = 11;
    if (diff == 2)
        max = 16;
    else if (diff == 3)
        max = 26;

    /*Checks each location for an unmarked mine (9), uncleared location (10), or 
    incorrectly flagged tile (12). If one is found, sets max to 1 to break the loops, if
    none are found, the player wins*/
    for (int i = 1; i < max; i++){
        for (int j = 1; j < max; j++){
            if (board[i][j] == 9 || board[i][j] == 10 || board[i][j] == 12)
                max = 1;
        }
    }

    /*If no mines were found, prints a win message and ends game*/
    if (max != 1){
        print(board, diff);
        cout << "\nYou have found all the mines. You win!!!\n";
        exit(EXIT_SUCCESS);
    }
}

/*First turn*/
    /*Asks for a first tile to clear*/
    /*Checks if the tile the user chooses has any adjacent mines. If it does,*/
        /*Count the number of mines in the first column of the array*/
        /*Shift the array by one*/
        /*Create a new column with the counted number of mines*/
        /*Repeat until the chosen tile has no adjacent mines*/
    /*Clear chosen tile*/
void first_turn(int** board, int diff){
    /*Sets maximum values based on difficulty*/
    int max = 11;
    if (diff == 2)
        max = 16;
    else if (diff == 3)
        max = 26;

    /*Prints the current board state*/
    print(board, diff);

    /*Asks for a row, column and action inputs*/
    int row = input(diff, "row");
    int col = input(diff, "column");

    /*Repeats until there are no adjacent mines*/
    while(adjacent_mines(board, row, col, max)){
        int count = 0;

        /*Counts the mines in the leftmost column*/
        for (int i = 1; i < max; i++){
            if (board[i][1] == 9)
                count++;
        }

        /*Shifts the array to the left by one*/
        for (int i = 1; i < max; i++){
            for (int j = 1; j < max; j++){
                board[i][j] = board[i][j + 1];
            }
        }

        /*Adds the counted amount of random mines to the rightmost column*/
        while (count){

            /*Generates a random row*/
            int y = (rand() % (max - 1)) + 1;

            /*Checks if the row and last column is already a mine, if it isn't, adds a
            mine and decrements counter*/
            if (board[y][(max - 1)] == 10){
                board[y][(max - 1)] = 9;
                count--;
            }
        }
    }

    /*Clears or chosen tile*/
    clear_tile(board, row, col, diff, 1);
}

/*Player Turn*/
    /*Repeated until a win/loss condition is met*/
        /*Player checks a tile with a mine (loss)*/
        /*No tile is set to "-" (10) or incorrectly flagged (12) (win)*/
    /*Print the board*/
    /*Ask for player row input (1-10 or 1-15)*/
    /*Ask for player column input (1-10 or 1-15)*/
        /*Give an error message and re-prompt if input is outside of range*/
        /*Subtract 1 from each input so it fits with array indexing (0-9 or 0-14)*/
    /*Ask if they want to*/
        /*1: Clear Location*/
        /*2: Flag/unflag a mine*/
    /*Check for win*/
void play(int** board, int diff){
    /*Does a player's turn until they win or lose*/
    while(true){

        /*Prints the current board state*/
        print(board, diff);

        /*Asks for a row, column and action inputs*/
        int row = input(diff, "row");
        int col = input(diff, "column");
        int act = input(-1, "");

        /*Clears spaces or toggles flag based on input*/
        if (act == 1)
            clear_tile(board, row, col, diff, 0);
        else
            toggle_flag(board, row, col);

        /*Checks for a win*/
        win(board, diff);
    }
}

int main(){
    /*DIFFICULTY:*/
    /*gets an original user input*/
    int diff = difficulty();



    /*INITIALIZE BOARD:*/
    /*Creates a 15x15 2D int array with each position set to 10*/
    int** board = create_board(diff);

    /*Randomly selects an amount of spaces to be mines based on the difficulty level*/
    set_mines(board, diff);



    /*PLAYER TURNS*/
    /*First turn*/
    first_turn(board, diff);

    /*Every other turn*/
    play(board, diff);
}