clang-tidy \
	-header-filter="./" \
	./*.cpp \
	-- \
	-I. \
	-std=c++14 \
> clang-warnings.txt


grep "\.h" clang-warnings.txt | sort -u > clang-warnings-shorts-h.txt
grep "\.cpp" clang-warnings.txt | sort -u > clang-warnings-shorts-cpp.txt
