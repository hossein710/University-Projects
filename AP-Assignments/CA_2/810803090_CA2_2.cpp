/*
* ========== Naming Convention Guideline ==========
* Class names: PascalCase
* Function names : camelCase
* Variable names : lower_snake_case
* Constant names : UPPER_SNAKE_CASE
* =================================================
*/

// Hossein Moradi 810803090
// Anagram Solver

#include <iostream>
#include <map>
#include <string>
#include <vector>
#include <sstream>
using namespace std;

void loadDictionary(map<string, bool>& dictionary, int n){
    string name;
    for(int i = 0;i<n;i++){
        cin >> name;
        dictionary.insert(make_pair(name, false));
    }
}

void loadCharacters(vector<vector<char>>& character_set, int n){
    cin.ignore();
    for (int i = 0; i < n; i++){
        string line;
        getline(cin, line);

        stringstream ss(line);
        char c;
        vector<char> chars;

        while (ss >> c)
            chars.push_back(c);
        
        character_set.push_back(chars);
    }
}

bool goForward(const string& word, vector<char>& chars, vector<bool>& used, int index = 0){
    if(index == word.size())
        return true;
    
    for(int i = 0;i<chars.size();i++){
        if(!used[i] and chars[i] == word[index]){
            used[i] = true;
            if(goForward(word, chars, used, index+1))
                return true;
            used[i] = false;
        }
    }
    return false;
}

bool canBuildWord(const string& word, vector<char> chars){
    vector<bool> used(chars.size(),false);
    return goForward(word, chars, used);
}

void processQuery(map<string, bool> dictionary, vector<char> chars){
    int possible_words = 0;
    for(const auto& word : dictionary){
        if(canBuildWord(word.first, chars)){
            dictionary[word.first] = true;
            possible_words++;
        }
    }

    cout << possible_words << endl;
    if(possible_words){
        for(const auto& word : dictionary){
            if(word.second){
                cout << word.first << endl;
            }
        }
    }
}

void runGame(){
    int n;
    cin >> n;
    map<string, bool> dict;
    loadDictionary(dict,n);

    cin >> n;
    vector<vector<char>> chars;
    loadCharacters(chars, n);

    for(int i = 0;i < n;i++){
        processQuery(dict, chars[i]);
    }
}

int main() {
    runGame();
    return 0;
}