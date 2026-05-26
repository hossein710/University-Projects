#include "utils.hpp"
#include "Installable.hpp"

#include <iostream>

void SystemLogger::onStateChanged(const Installable* comp,
    ComponentState oldState, ComponentState newState) {


        cout << "[OBSERVER] Component " << comp->getId() << " changed from "
             << stateToString(oldState) << " to " << stateToString(newState) << endl;

    }