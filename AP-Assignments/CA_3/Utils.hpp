// Helper Functions:
#pragma once


#include "ComponentState.hpp"

#include <string>
using namespace std;

string getNextToken(string& str);
string stateToString(ComponentState s);
string trimLeading(const string& str);