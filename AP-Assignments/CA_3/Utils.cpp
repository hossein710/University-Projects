#include "utils.hpp"

string getNextToken(string& str) {
    str = trimLeading(str);
    if (str.empty()) return "";
    size_t pos = str.find_first_of(" \t\n\r\f\v");
    if (pos == string::npos) {
        string token = str;
        str.clear();
        return token;
    }
    string token = str.substr(0, pos);
    str = str.substr(pos + 1);
    return token;
}

string stateToString(ComponentState s){
    if(s == ComponentState::FAILED)
        return "FAILED";

    else if(s == ComponentState::INSTALLED)
        return "INSTALLED";

    else
        return "PENDING";
}

string trimLeading(const string& str) {
    size_t start = str.find_first_not_of(" \t\n\r\f\v");
    if (start == string::npos) return "";
    return str.substr(start);
}
