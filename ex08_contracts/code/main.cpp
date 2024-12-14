#include <iostream>
#include <memory>
#include <assert.h>

#include "syntaxtree.h"

#include "doublelinkedlist.h"

using namespace std;


void test1() {
    std::cout << "---------------" << '\n';
    std::cout << "Starting test 1" << '\n';
    std::cout << "---------------" << '\n';
    auto expr = std::make_unique<BinaryExpression>();
    // Mmh... forgot to set the operation
    auto left = std::make_unique<Number>(4.0);
    auto right = std::make_unique<Number>(5.0);
    try {
        expr->checkInvariants();
    }  catch (std::runtime_error& error) {
        std::cout << "Got the exception : " << error.what() << '\n';
    }

    try {
        expr->evaluate();
    }  catch (std::runtime_error& error) {
        std::cout << "Got the exception : " << error.what() << '\n';
    }
    expr->setLeft(std::move(left));
    expr->setRight(std::move(right));
    try {
        double result = expr->evaluate();
        std::cout << "Result : " << result << '\n';
    }  catch (std::runtime_error& error) {
        std::cout << "Got assertthe exception : " << error.what() << '\n';
    }
    std::cout << "---------------" << '\n';
    std::cout << "Ending test 1  " << '\n';
    std::cout << "---------------" << '\n';
}

void test2() {
    std::cout << "---------------" << '\n';
    std::cout << "Starting test 2" << '\n';
    std::cout << "---------------" << '\n';
    auto expr = std::make_unique<BinaryExpression>();
    expr->setOperation(BinaryExpression::operation_t::Division);
    auto left = std::make_unique<Number>(4.0);
    auto right = std::make_unique<Number>(0.0);
    // Mmh... forgot to set the operands
    try {
        expr->checkInvariants();
    }  catch (std::runtime_error& error) {
        std::cout << "Got the exception : " << error.what() << '\n';
    }

    expr->setLeft(std::move(left));
    expr->setRight(std::move(right));

    try {
        double result = expr->evaluate();
        std::cout << "Result : " << result << '\n';
    }  catch (std::runtime_error& error) {
        std::cout << "Got the exception : " << error.what() << '\n';
    }
    std::cout << "---------------" << '\n';
    std::cout << "Ending test 2  " << '\n';
    std::cout << "---------------" << '\n';
}

void testList() {
    std::cout << "-----------------" << '\n';
    std::cout << "Starting testList" << '\n';
    std::cout << "-----------------" << '\n';
    DoubleLinkedList<int> list;
    assert(list.getNbElements() == 0);
    try {
        // Uncomment when the contract has been updated
        // auto first = list.getFirstElement();
    } catch (std::runtime_error& error) {
        std::cout << "Got the exception : " << error.what() << '\n';
    }

    list.pushBack(new Node<int>());
    list.pushBack(new Node<int>());
    auto newNode = new Node<int>();
    try {
        list.remove(newNode);
        std::cout << "Mmh, I was expecting an exception here" << '\n';
    } catch (std::runtime_error& error) {
        std::cout << "Got the exception : " << error.what() << '\n';
    }

    list.pushBack(newNode);
    list.pushBack(new Node<int>());
    list.remove(newNode);

    // Add more tests

    std::cout << "-----------------" << '\n';
    std::cout << "Ending testList" << '\n';
    std::cout << "-----------------" << '\n';
}


int main()
{
    test1();
    test2();
    testList();
    return 0;
}