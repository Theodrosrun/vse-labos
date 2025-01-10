#ifndef SYNTAXTREE_H
#define SYNTAXTREE_H

#include <cmath>
#include <memory>

#include "contract.h"

class Factor {
public:
    virtual double evaluate() = 0;

    EMPTYINVARIANTS
};

class BinaryExpression : public Factor {
public:
    enum class operation_t {
        Addition = 0,
        Subtraction,
        Multiplication,
        Division
    };

    void setOperation(operation_t operation) {
        this->operation = operation;
    }

    void setLeft(std::unique_ptr<Factor> node) {
        left = std::move(node);
    }

    void setRight(std::unique_ptr<Factor> node) {
        right = std::move(node);
    }

    INVARIANTS_OVERRIDE(
        INVARIANT((left != nullptr), "The left side of a binary expression shall not be nullptr");
        INVARIANT((right != nullptr), "The right side of a binary expression shall not be nullptr");
        LAMBDA_INVARIANT({if (left == nullptr) { return false;}return left->checkInvariants();}, "Invalid left child");
        LAMBDA_INVARIANT({if (right == nullptr) { return false;}return right->checkInvariants();}, "Invalid right child");
        )

    double evaluate() override {
        // Actually we should check NAN as well
        CHECKINVARIANTS;
        PRE_CONDITION((!std::isnan(left->evaluate())), "The left side of a binary operation shall not be NAN");
        PRE_CONDITION((!std::isnan(right->evaluate())), "The right side of a binary operation shall not be NAN");
        PRE_CONDITION((operation != operation_t::Division || (right->evaluate() != 0.0)), "The right side of a division shall not be 0");
        switch (operation) {
        case operation_t::Addition : return left->evaluate() + right->evaluate();
        case operation_t::Subtraction : return left->evaluate() - right->evaluate();
        case operation_t::Multiplication : return left->evaluate() * right->evaluate();
        case operation_t::Division : return left->evaluate() / right->evaluate();
        default : return 0.0;
        }
    }
private:
     operation_t operation;

     // Could be interesting to see what happens without the nullptr here
    std::unique_ptr<Factor> left{nullptr};
    std::unique_ptr<Factor> right{nullptr};
};

class UnaryExpression : public Factor {
public:
    enum class operation_t {
        Subtraction = 0
    };

    INVARIANTS_OVERRIDE(
        INVARIANT((child != nullptr), "The child node of a binary expression shall not be nullptr");
        LAMBDA_INVARIANT({if (child == nullptr) { return false;}return child->checkInvariants();}, "Invalid child");
        )

    void setChild(std::unique_ptr<Factor> node) {
        child = std::move(node);
    }

    double evaluate() override {
        CHECKINVARIANTS;
        switch (operation) {
        case operation_t::Subtraction : return -child->evaluate();
        default : return 0.0;
        }
    }
private:
    operation_t operation;

    std::unique_ptr<Factor> child;
};


class Number : public Factor {
public:
    Number(double value) : value(value){ }
    Number() {}

    INVARIANTS_OVERRIDE(
        INVARIANT((!std::isnan(value)), "A number shall not be NAN");
        )

    double evaluate() override {
        CHECKINVARIANTS;
        return value;
    }
private:
    double value{NAN};
};

#endif // SYNTAXTREE_H
