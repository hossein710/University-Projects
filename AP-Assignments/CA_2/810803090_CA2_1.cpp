/*
* ========== Naming Convention Guideline ==========
* Class names: PascalCase
* Function names : camelCase
* Variable names : lower_snake_case
* Constant names : UPPER_SNAKE_CASE
* =================================================
*/
// 810803090 Hossein Moradi
// Sudoku

#include <iostream>
using namespace std;

void printBoard(int board[9][9]){
    for(int i =0;i<9;i++){
        for(int j = 0;j<9;j++){
            cout << board[i][j];
            if(j < 8) cout << " ";
        }
        cout << endl;
    }
}

bool isValid(int board[9][9], int row, int col, int num){
    for(int i = 0; i < 9; i++)
        if(i != col and board[row][i] == num)
            return false;

    for(int i = 0; i < 9; i++)
        if(i != row and board[i][col] == num)
            return false;

    // Find row and column modulo-3 equivalent.
    // If modulo-3 != 0 then go back 1 step or 2 step
    int row_modulo3 = row - row % 3;
    int col_modulo3 = col - col % 3;

    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 3; j++)
            if (!((row_modulo3 + i == row) and (col_modulo3 + j == col)) and board[row_modulo3 + i][col_modulo3 + j] == num)
                return false;

    return true;
}

bool readValidBoard(int board[9][9]){
    int x = 0;
    bool flag;
    for(int i =0;i<9;i++){
        for(int j = 0;j<9;j++){
            cin >> x;
            board[i][j] = x;
        }
    }

    for(int i =0;i<9;i++)
        for(int j = 0;j<9;j++){
            if(board[i][j] == 0)
                continue;

            if(!isValid(board,i,j,board[i][j]))
                return false;
        }

    return true;
}

bool solve(int board[9][9]){
    for (int i = 0; i < 9; i++){
        for (int j = 0; j < 9; j++){
            if (board[i][j] == 0){
                for (int x = 1; x < 10; x++){
                    if (isValid(board, i, j, x)){
                        board[i][j] = x;

                        if (solve(board))
                            return true;

                        board[i][j] = 0;
                    }
                }

                return false;
            }
        }
    }

    return true;
}
int main(){
    int board[9][9];
    bool is_valid = readValidBoard(board);
    if(is_valid)
        if (solve(board)){
            printBoard(board);
            return 0;
        }

    cout << "No solution exists" << endl;
    return 0;
}