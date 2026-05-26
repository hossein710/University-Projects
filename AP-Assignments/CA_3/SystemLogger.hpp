// --- Observer Interface --
#pragma once

#include "ComponentState.hpp"
#include "Observer.hpp"

class Installable;
// --- Concrete Observer ---
class SystemLogger : public Observer {
public:
    void onStateChanged(const Installable* comp,
    ComponentState oldState, ComponentState newState) override;
};