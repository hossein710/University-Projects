#pragma once


#include "ComponentState.hpp"


class Installable;

class Observer {
public:
    virtual void onStateChanged(const Installable* comp,
            ComponentState oldState, ComponentState newState) = 0;
    virtual ~Observer() = default;
};
