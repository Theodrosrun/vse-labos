clang-tidy \
	-config="{Checks: '-*,readability-braces-around-statements, \
                              readability-identifier-naming, \
                              readability-avoid-const-params-in-decls, \
                              clang-analyzer-*, \
                              bugprone-integer-division, \
                              google-readability-casting, \
                              llvm-namespace-comment, \
                              google-global-names-in-headers, \
                              misc-unused-parameters, \
                              modernize-loop-convert, \
                              modernize-make-unique, \
                              modernize-use-nullptr, \
                              modernize-use-override, \
                              modernize-raw-string-literal, \
                              readability-implicit-bool-conversion, \
                              cppcoreguidelines-narrowing-conversions, \
                              bugprone-multiple-statement-macro, \
                              bugprone-integer-division, \
                              readability-inconsistent-declaration-parameter-name, \
                              bugprone-*, \
                              cppcoreguidelines-avoid-goto,cppcoreguidelines-avoid-non-const-global-variables,cppcoreguidelines-avoid-c-arrays,cppcoreguidelines-c-copy-assignment-signature,cppcoreguidelines-interfaces-global-init,cppcoreguidelines-macro-usage,cppcoreguidelines-narrowing-conversions,cppcoreguidelines-no-malloc,cppcoreguidelines-pro-*,cppcoreguidelines-slicing,performance-*,readability-avoid-const-params-in-decls,readability-const-return-type,readability-container-size-empty,readability-delete-null-pointer,readability-deleted-default,readability-else-after-return,readability-function-size,readability-identifier-naming,readability-inconsistent-declaration-parameter-name,readability-isolate-declaration,readability-misleading-indentation,readability-misplaced-array-index,readability-non-const-parameter,readability-redundant-*,readability-simplify-*,readability-static-*,readability-string-compare', \
		CheckOptions: [ \
			{ key: readability-identifier-naming.ClassCase,           value: CamelCase }, \
			{ key: readability-identifier-naming.MemberPrefix,        value: m_        }, \
			{ key: readability-identifier-naming.VariableCase,        value: camelBack }, \
			{ key: readability-identifier-naming.ParameterCase,       value: camelBack }, \
			{ key: readability-identifier-naming.ParameterPrefix,     value: '_'       }, \
                        { key: readability-identifier-naming.EnumCase,            value: CamelCase }, \
                        { key: readability-identifier-naming.EnumConstCase,       value: CamelCase }, \
                        { key: readability-identifier-naming.StaticConstantCase,  value: UPPER_CASE }, \
                        { key: readability-identifier-naming.GlobalConstantCase,  value: UPPER_CASE }, \
		]}" \
	-header-filter="./" \
	./*.cpp \
	-- \
	-I. \
	-std=c++14 \
> clang-warnings.txt


grep "\.h" clang-warnings.txt | sort -u > clang-warnings-shorts-h.txt
grep "\.cpp" clang-warnings.txt | sort -u > clang-warnings-shorts-cpp.txt
