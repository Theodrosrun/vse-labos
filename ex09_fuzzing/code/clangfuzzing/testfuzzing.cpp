
// See example here: https://www.youtube.com/watch?v=Is1MurHeZvg

// https://llvm.org/docs/LibFuzzer.html

/*
clang -g -O1 -fsanitize=fuzzer                         mytarget.c # Builds the fuzz target w/o sanitizers
clang -g -O1 -fsanitize=fuzzer,address                 mytarget.c # Builds the fuzz target with ASAN
clang -g -O1 -fsanitize=fuzzer,signed-integer-overflow mytarget.c # Builds the fuzz target with a part of UBSAN
clang -g -O1 -fsanitize=fuzzer,memory                  mytarget.c # Builds the fuzz target with MSAN
*/

#include <iostream>

std::size_t iteration = 0;

std::size_t parse(char sv[]) {
  ++iteration;
  if (sv[10] == ';') {
    return 0;
  }
  sv[10] = 'a';
  return 1;
}

std::size_t parseString(std::string sv) {
  ++iteration;
  if (sv[10] == ';') {
    return 0;
  }
  // TODO:
  // What happens here? Try with other values
  sv[10] = 'a';
  return 1;
}

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
  char c[Size];
  for (int i = 0; i < Size; i++) {
    c[i] = Data[i];
  }
  #ifdef TEST1
  if (c[10] == ';') {
    int i;
    std::cout << "Victory" << std::endl;
  }
  #endif // TEST1
  #ifdef TEST2
  parse(c);
  #endif // TEST2
  #ifdef TEST3
  std::string data{reinterpret_cast<const char*>(Data), Size};
  std::cout << Size << std::endl;
  parseString(data);
  #endif // TEST3
  return 0;  // Values other than 0 and -1 are reserved for future use.
}
