/*
* ========== Naming Convention Guideline ==========
* Class names: PascalCase
* Function names : camelCase
* Variable names : lower_snake_case
* Constant names : UPPER_SNAKE_CASE
* =================================================
*/

// 810803090 Hossein Moradi
// N-Queens

#include <iostream>
using namespace std;
const int NUMBER_OF_QUEENS = 8;

void readBoard(char board[NUMBER_OF_QUEENS][NUMBER_OF_QUEENS]){
	for(int i = 0;i < NUMBER_OF_QUEENS;i++){
		for(int j = 0;j<NUMBER_OF_QUEENS;j++){
			cin >> board[i][j];
		}
	}
}
bool isSafe(int queens[NUMBER_OF_QUEENS], int row, int col, char board[NUMBER_OF_QUEENS][NUMBER_OF_QUEENS]){
	if(board[row][col] == '*')
		return false;
	for( int i = 0;i < row; i++)
		if(queens[i] == col or (i - row) == (queens[i] - col) or (i - row) == (col - queens[i]))
			return false;
			
	return true;
}
int solve(int queens[NUMBER_OF_QUEENS], char board[NUMBER_OF_QUEENS][NUMBER_OF_QUEENS], int row=0){
	if (row == NUMBER_OF_QUEENS ){
		return 1;
	}
	
	int count = 0;
	for (int col = 0; col < NUMBER_OF_QUEENS;col++){
		if(isSafe(queens,row, col,board)){
			queens[row] = col;
			count += solve(queens,board,row+1);
		}
	}
	return count;
}
int main(){
	char board[NUMBER_OF_QUEENS][NUMBER_OF_QUEENS];
	readBoard(board);
	int queens[NUMBER_OF_QUEENS] = {0};
	int count_possible_ways = solve(queens, board);
	
	cout << count_possible_ways << endl;
	return 0;
}