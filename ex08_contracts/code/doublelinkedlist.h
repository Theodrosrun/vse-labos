#ifndef DOUBLELINKEDLIST_H
#define DOUBLELINKEDLIST_H


#include "contract.h"

template<typename T>
class Node {
public:
    Node *prev = nullptr;
    Node *next = nullptr;
    T element{};
};

template<typename T>
class DoubleLinkedList
{

    Node<T> *first{nullptr};
    Node<T> *last{nullptr};
    size_t nbElements{0};
public:

    INVARIANTS(
        INVARIANT(((nbElements == 0) || (first != nullptr)), "The first element of a non-empty list cannot be nullptr")
        INVARIANT((nbElements == 0) || (last != nullptr), "The last element of a non-empty list cannot be nullptr"))

    ///
    /// \brief Adds a node at the end of the list
    /// \param node Node to be added
    ///
    void pushBack(Node<T>* node) {
        CHECKINVARIANTS;
        PRE_CONDITION((node != nullptr), "A node to be inserted cannot be nullptr");
        if (last != nullptr) {
            node->prev = last;
            last->next = node;
        }
        last = node;
        if (first == nullptr) {
            first = node;
        }
        nbElements ++;
        CHECKINVARIANTS;
    }

    ///
    /// \brief Adds a node at the front of the list
    /// \param node Node to be added
    ///
    void pushFront(Node<T>* node) {
        CHECKINVARIANTS;
        PRE_CONDITION((node != nullptr), "A node to be inserted cannot be nullptr");
        if (first != nullptr) {
            node->next = first;
            first->prev = node;
        }
        first = node;
        if (last == nullptr) {
            last = node;
        }
        nbElements ++;
        CHECKINVARIANTS;
    }

    ///
    /// \brief Adds a node after an existing node of the list
    /// \param node Node to be added
    /// \param afterThis Node after which the new node shall be added
    ///
    void insertAfter(Node<T>* node, Node<T>* afterThis) {
        CHECKINVARIANTS;
        PRE_CONDITION((node != nullptr), "A node to be inserted cannot be nullptr");
        PRE_CONDITION(isNodeInList(afterThis), "We cannot add a node after a one that is not in the list");
        node->next = afterThis->next;
        if (afterThis->next != nullptr) {
            afterThis->next->prev = node;
        }
        else {
            last = node;
        }
        node->prev = afterThis;
        afterThis->next = node;
        nbElements ++;
        CHECKINVARIANTS;
    }

    ///
    /// \brief Removes a node from the list
    /// \param node Node to be removed
    ///
    /// As an asumption the node should be in the list, else there is a misuse of this function
    ///
    void remove(Node<T>* node) {
        CHECKINVARIANTS;
        PRE_CONDITION(isNodeInList(node), "Try to remove a node that is not in the list");

        if (node->prev != nullptr) {
            node->prev->next = node->next;
        }
        else {
            first = node->next;
            if (first == nullptr) {
                last = nullptr;
            }
        }
        if (node->next != nullptr) {
            node->next->prev = node->prev;
        }
        else {
            last = node->prev;
            if (last == nullptr) {
                first = nullptr;
            }
        }
        nbElements --;
        CHECKINVARIANTS;
    }

    ///
    /// \brief Returns true if the node is in the list, false else
    /// \param node Node to be checked
    /// \return true if the node is in the list, falst else
    ///
    [[nodiscard]]
    bool isNodeInList(Node<T> *node) const {
        CHECKINVARIANTS;
        Node<T> *n = node;
        while (n != nullptr) {
            if (n == node) {
                return true;
            }
            n = n->next;
        }
        return false;
    }

    ///
    /// \brief Returns the last node of the list
    /// \return The last node of the list, nullptr if the list is empty
    ///
    [[nodiscard]]
    Node<T>* getLastNode() const {
        CHECKINVARIANTS;
        return last;
    }

    ///
    /// \brief Returns the first node of the list
    /// \return The first node of the list, nullptr if the list is empty
    ///
    [[nodiscard]]
    Node<T>* getFirstNode() const {
        CHECKINVARIANTS;
        return first;
    }

    ///
    /// \brief Returns the last element of the list
    /// \return The last element of the list
    ///
    /// This function should only be called on a non-empty list.
    ///
    [[nodiscard]]
    T getLastElement() const {
        CHECKINVARIANTS;
        PRE_CONDITION(last != nullptr, "Cannot get the last element if it doesn't exist");
        return last->element;
    }

    ///
    /// \brief Returns the first element of the list
    /// \return The first element of the list
    ///
    /// This function should only be called on a non-empty list.
    ///
    [[nodiscard]]
    T getFirstElement() const {
        CHECKINVARIANTS;
        PRE_CONDITION(first != nullptr, "Cannot get the first element if it doesn't exist");
        return first->element;
    }

    ///
    /// \brief Returns the number of elements in the list
    /// \return The number of elements in the list
    ///
    [[nodiscard]]
    size_t getNbElements() const {
        CHECKINVARIANTS;
        return nbElements;
    }

    ///
    /// \brief Removes the first element of the list.
    ///
    /// The call is invalid if the list is empty.
    ///
    void popFront() {
        CHECKINVARIANTS;
        PRE_CONDITION(first != nullptr, "Cannot popFront an empty list");
        if (first != nullptr) {
            if (first->next != nullptr) {
                first->next->prev = nullptr;
            }
        }
        if (last == first) {
            last = nullptr;
        }
        first = first->next;
        nbElements --;
        CHECKINVARIANTS;
    }

    ///
    /// \brief Removes the last element of the list.
    ///
    /// The call is invalid if the list is empty.
    ///
    void popBack() {
        CHECKINVARIANTS;
        PRE_CONDITION(last != nullptr, "Cannot popBack an empty list");
        if (last != nullptr) {
            if (last->prev != nullptr) {
                last->prev->next = nullptr;
            }
        }
        if (first == last) {
            first = nullptr;
        }
        last = last->prev;
        nbElements --;
        CHECKINVARIANTS;
    }

};


#endif // DOUBLELINKEDLIST_H
