#pragma once

#include <vector>

// --- Forward Declarations --
class Installable;


// --- Transaction Context --
struct TransactionContext {
std::vector<Installable*> stateChangedNodes;
std::vector<Installable*> countIncreasedNodes;
};