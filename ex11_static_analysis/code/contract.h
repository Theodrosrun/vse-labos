#ifndef CONTRACT_H
#define CONTRACT_H

#include <stdexcept>
#include <string>
#include <iostream>

#ifdef DEBUG

#ifdef EASY_DEBUG

void PRE_CONDITION(bool condition, std::string message) {
    if (!(condition)) {
        throw std::runtime_error("Pre-condition error in file " + std::string(__FILE__) + " , line " + std::to_string(__LINE__) + " : \n\t " + message); \
    }
}
#else // EASY_DEBUG
#define PRE_CONDITION(condition, message) \
    if (!(condition)) { \
        throw std::runtime_error("Pre-condition error in file " + std::string(__FILE__) + " , line " + std::to_string(__LINE__) + " : " + message); \
    }
#endif // EASY_DEBUG

#ifdef EASY_DEBUG
void POST_CONDITION(bool condition, std::string message) {
    if (!(condition)) {
        throw std::runtime_error("Post-condition error in file " + std::string(__FILE__) + " , line " + std::to_string(__LINE__) + " : \n\t " + message); \
    }
}
#else // EASY_DEBUG

#define POST_CONDITION(condition, message) \
    if (!(condition)) { \
    throw std::runtime_error("Post-condition error in file " + std::string(__FILE__) + " , line " + std::to_string(__LINE__) + " : \n\t " + message); \
    }
#endif // EASY_DEBUG

#else // DEBUG

#define PRE_CONDITION(condition, message)
#define POST_CONDITION(condition, message)
#endif // DEBUG


// NOLINTNEXTLINE(cppcoreguidelines-macro-usage)
#define INVARIANT(expression, message)                                                                 \
    {                                                                                                  \
        if (!expression) {                                                                             \
            throw std::runtime_error("Invariant error in file " + std::string(__FILE__) + " , line " + \
                                     std::to_string(__LINE__) + " : " + message);                      \
        }                                                                                              \
    }

// NOLINTNEXTLINE(cppcoreguidelines-macro-usage)
#define COMPLEX_INVARIANT(expression) expression;

// NOLINTNEXTLINE(cppcoreguidelines-macro-usage)
#define INVARIANTS(decl)                 \
public:                                  \
    virtual bool checkInvariants() const \
    {                                    \
        bool ok = true;                  \
        decl;                            \
        return ok;                       \
    }


// NOLINTNEXTLINE(cppcoreguidelines-macro-usage)
#define INVARIANTS_OVERRIDE(decl)         \
public:                                   \
    bool checkInvariants() const override \
{                                         \
        bool ok = true;                   \
        decl;                             \
        return ok;                        \
}

// NOLINTNEXTLINE(cppcoreguidelines-macro-usage)
#define EMPTYINVARIANTS                  \
public:                                  \
    virtual bool checkInvariants() const \
    {                                    \
        return true;                     \
    }

// NOLINTNEXTLINE(cppcoreguidelines-macro-usage)
#define CHECKINVARIANTS checkInvariants()

// NOLINTNEXTLINE(cppcoreguidelines-macro-usage)
#define LAMBDA_INVARIANT(expression, message)                                                              \
    {                                                                                                      \
        auto f = [this]() { expression };                                                                  \
        {                                                                                                  \
            bool result = f();                                                                             \
            if (!result) {                                                                                 \
                throw std::runtime_error("Invariant error in file " + std::string(__FILE__) + " , line " + \
                                         std::to_string(__LINE__) + " : " + message);                      \
            }                                                                                              \
            ok &= result;                                                                                  \
            if (!ok)                                                                                       \
                return false;                                                                              \
        }                                                                                                  \
    }

#endif // CONTRACT_H
