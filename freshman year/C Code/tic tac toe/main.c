#include <stdio.h>

//prototypes from the rubric, self explanatory 
void displayBoard(int board[]);
void legalMove (int *p, int in, int c[]);
int gameWon (int d[]);
void readGame(int e[], int *p);
void writeGame(int f[]);

//added a third save game function to make it easier because instead of write game where the player is automatically 1, we need to save the value of player
void saveGame(int g[], int *p);

//prints the lines that make the rows
void printline();

//functions for colors so they can be called instead of the color break out codes each time
void red();
void cyan();
void blue();
void purple();
void yellow();
void green();
void reset();

int main(void) {
  
//initializing array for board, file and other variables
  FILE *ifile;
  int board[10] = {'1','2','3','4','5','6','7','8','9',}; 
  int choice;
  int input, i=1, player;

  /*this part uses the beakout codes for colors instead. of the functions because while it may be harder to read, it saves lots of lines of code*/
  printf("Welcome to \033[1;35mR\033[1;33mA\033[1;32mI"
    "\033[0mN\033[1;36mB\033[1;31mO\033[1;34mW\033[0m"
    " Tic-tac-toe!\n\n");
  
  yellow();
  printf("Enter 1 to begin a new game.");
  purple();
  printf("\nEnter 2 to load a saved file\n");
  reset();
  scanf("%d", &choice);

  //tells the user to retry if invalid entry
  while (choice != 1 && choice != 2) {
     printf("\n\033[0;31mInvalid entry... \033[0mEnter 1 or 2\n");
     scanf("%d", &choice);
  }

    //starts the file over and creates a new one
    if (choice == 1) {
      writeGame(board);
    }
    //yes choice opens file, and check if it exists down in the     function
    else if (choice == 2) {
      readGame(board, &player);
    }

  //main part of the code that calls on the functions and is      the actual game
  do {
    displayBoard(board);

    if (player % 2 == 1){
      player = 1;
    }
    if (player % 2 == 0) {
      player = 2;
    }
    printf("\nPlayer %d it is your turn. Please enter a number. if you would not like to keep playing, enter 0: \n ", player);
    scanf("%d", &input);

    //calling the legal move function. it used current player, the space chosen, and the current board to make a decision if the move is valid, and then output the new board if it is or give an invalid message accordingly. 
    if (input != 0){
      legalMove(&player, input, board);
      i = gameWon(board);
    }
  }
  //tests if the game has finished or player chose to suspend
  while (i == -1 && input != 0);

  //tests if the player suspended the game
  if (input == 0 ){
    saveGame(board, &player);
    printf("\nYour game has been saved!:)");
  }
  
  //only diplays if the game is finished and the player has not paused the game
  if (i == 1 && input != 0) {
    displayBoard(board);
    printf("\n\nplayer %d wins!!", --player);
  }
  else if (i == 0 && input != 0) {
    displayBoard(board);
    printf("\n\nThe game is a draw.");
  }
  
  return 0;
}

//making color functions to make them easier to use repeatedly
void red() {
  printf("\033[0;31m");
}
void cyan() {
  printf("\033[1;36m");
}
void blue() {
  printf("\033[0;34m");
}
void purple(){
  printf("\033[1;35m");
}
void yellow() {
  printf("\033[1;33m");
}
void green(){
  printf("\033[1;32m");
}
void reset() {
  printf("\033[0m");
}

//to print off the colored lines
void printline (){
  int i;

  //for loop to shorten the code
  for (i=1; i<=19; i++) {
    if (i%5 == 1){
      purple();
    }
    else if (i%5 == 2) {
      yellow();
    }
    else if (i%5 == 3) {
      cyan();
    }
    else if (i%5 == 4) {
      green();
    }
    else if (i%5 == 0) {
      blue();
    }
    printf("-"); 
  }
  printf("\n");
  reset();
}

//display board function
void displayBoard(int b[]) {
  int i;

  /*this portion of DisplayBoard is for the top of the display*/
  printf("\nPlayer 1 is ");
  blue();
  printf("X");
  reset();
  printf(" and Player 2 is ");
  red();
  printf("O");
  reset();
  printf(".\n\n\n");

  //for line 1 with numbers 1 2 3 alternating the colors
  for(i=1; i<=6;i++) {

    //this part tells if a value falls in the number spots
    if (i%2 == 0 && i%2 != 6) {

      //this part just changes the color to blue or red depending on which turn it is
      if (b[i/2-1] == 'X') {
        blue();
      }
      else if( b[i/2-1] == 'O') {
        red();
      }
      else {
        reset();
      }
    printf("  %c  ", b[i/2-1]);
    }
    else if (i%6 == 5 || i%6 == 1) {
     purple();
    }
    if (i%6 == 3 || i == 6) {
     yellow();
    }
    if (i%2 ==1 || i ==6) {
    printf("|");
    }
  }
  printf("\n");
  
  printline();

  //for line 2 with numbers 4 5 6, alternating the     colors 
  for(i=1; i<=6;i++) {

  //this part tells if a value falls in the number     spots
    if (i%2 == 0 && i%2 != 6) {

      //this part just changes the color to blue or         red depending on which turn it is
      if (b[i/2+2] == 'X') {
        blue();
      }
      else if( b[i/2+2] == 'O') {
        red();
      }
      else{
        reset();
      }
      printf("  %c  ", b[i/2+2]);
    }
    else if (i%6 == 5 || i%6 == 1) {
     green();
    }
    if (i%6 == 3 || i == 6) {
     cyan();
      }
    if (i%2 ==1 || i ==6) {
    printf("|");
    }
  }
  printf("\n");
  
  printline();

  //for line 3 with numbers 7 8 9 alternating colors
  for(i=1; i<=6;i++) {
    
    //this part tells if a value falls in the number spots
    if (i%2 == 0 && i%2 != 6) {
      
       //this part just changes the color to blue or red depending on which turn it is
      if (b[i/2+5] == 'X') {
        blue();
      }
      else if( b[i/2+5] == 'O') {
        red();
      }
      else{
      reset();
      }
      printf("  %c  ", b[i/2+5]);
    }
    else if (i%6 == 5 || i%6 == 1) {
     purple();
    }
    if (i%6 == 3 || i == 6) {
     yellow();
      }
    if (i%2 ==1 || i == 6) {
    printf("|");
    }
  }
  printf("\n");
  reset();
}

//the inputs are p for player, in for input, and c[] for array. this function tests if a space is open and if it is it will take the board and display it accordingly
void legalMove (int *p, int in, int c[]){
  char tag;
  if (*p == 1){
    tag = 'X';
  }
  else {
    tag = 'O';
  }
  
  //i used *p to change the player that was active because it is inside of the function
  if (in == 1 && c[0] == '1') {
    c[0] = tag;     
    *p +=1;
    }
  else if (in == 2 && c[1] == '2') {
    c[1] = tag;  
    *p +=1;
    }
  else if (in == 3 && c[2] == '3'){
   c[2] = tag;  
    *p +=1;
    }
  else if (in == 4 && c[3] == '4'){
   c[3] = tag;
    *p +=1;
    }
  else if (in == 5 && c[4] == '5'){
   c[4] = tag;
    *p +=1;
    }
  else if (in == 6 && c[5] == '6'){
   c[5] = tag; 
    *p +=1;
    }
  else if (in == 7 && c[6] == '7'){
   c[6] = tag;
    *p +=1;
    }
  else if (in == 8 && c[7] == '8'){
   c[7] = tag;
    *p +=1;
    }
  else if (in == 9 && c[8] == '9'){
   c[8] = tag;   
    *p +=1;
    }
  else {
    red();
    printf("\nInvalid move...");
    reset();
    printf(" try again\n");
  }
  //to reset the text color
  reset();
  
}

//this function tests which player won the game, just tests all possible win locations 
int gameWon (int d[]){
  if (d[0] == d[1] && d[1] == d[2])
        return 1;
        
    else if (d[3] == d[4] && d[4] == d[5])
        return 1;
        
    else if (d[6] == d[7] && d[7] == d[8])
        return 1;
        
    else if (d[0] == d[3] && d[3] == d[6])
        return 1;
        
    else if (d[1] == d[4] && d[4] == d[7])
        return 1;
        
    else if (d[2] == d[5] && d[5] == d[8])
        return 1;
        
    else if (d[0] == d[4] && d[4] == d[8])
        return 1;
        
    else if (d[2] == d[4] && d[4] == d[6])
        return 1;
        
    else if (d[0] != '1' && d[1] != '2' && d[2] != '3' &&
        d[3] != '4' && d[4] != '5' && d[5] != '6' && d[6] 
        != '7' && d[7] != '8' && d[8] != '9')
        return 0;
    else
        return  - 1;
}

//reads the file for game input
void readGame(int e[], int *p){
  FILE *ifile;
  int j, k;
  char array3[10];

  
  //reading to see if file exists
  ifile = fopen("TicTacToeSave.txt", "r"); 
  //creates a file if one doesnt already exist
  if (ifile == NULL) {
    printf("\nFile not found!! Creating new save\n");
    writeGame(e);
    }
  else {
  //loop to read character values from text file
    for (j= 0; j <= 9; j++) {
    fscanf(ifile, "%c,", &array3[j]);
  }
    fclose(ifile);

    //converts the array stored in the file to the array that the functions use.
    for (k=0; k<=8; k++){
      if (array3[k] == 'A'){
      e[k] = 88;
    }
      else if (array3[k] == 'B') {
      e[k] = 79;
      }
      else {
        //to convert the number value to a character         value
        e[k] = k+49;
      }
    }
    if (array3[9] == 'A'){
    *p = 1;
    }
    else if (array3[9] == 'B') {
    *p = 2;
    }
  }
}

//writes a new game file
void writeGame(int f[]){
  FILE *ifile;
  int j, k;
  char array1[10];

  //starts the player at 1 and assigns the file array value of A
  f[9] = '1', array1[9] = 'A';

  //converts the numbers from the board into A's and B's so they can be stored in the file
  for (k=0; k<=8; k++){
    if (f[k] != 88 && f[k] != 79) {
      array1[k] = ' ';
    }
    else {
      //else statement for the X and O's
      array1[k] = f[k];
    }
  }
  
  ifile = fopen("TicTacToeSave.txt", "w");
  
  //loop to print the character values into the text file
  for (j= 0; j <= 9; j++) {
      fprintf(ifile, "%c,", array1[j]);
    }
    fclose(ifile);
}

//saves the game to the file
void saveGame(int g[], int *p){
  FILE *ifile;
  int j, k;
  char array2[10], plyr;

  //converts the board from x to A and o to B
  for (k=0; k<=8; k++){
    if (g[k] == 88){
      array2[k] = 'A';
      }
    else if (g[k] == 79) {
     array2[k] = 'B';
    }
    else{
      
      //anything else should be a space
      array2[k] = ' ';
    }
  }
  ifile = fopen("TicTacToeSave.txt", "w");
  
  //loop to print the character values into the text file
  for (j= 0; j <= 8; j++) {
      fprintf(ifile, "%c,", array2[j]);
    }
   //saves where the player was and converts it to A or B
  if (*p == 1){
    plyr = 'A';
  }
  else if (*p == 2) {
    plyr = 'B';
  }
  
  fprintf(ifile, "%c", plyr);
    fclose(ifile);
}
