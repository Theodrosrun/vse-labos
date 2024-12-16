mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=DEBUG ../src
make
# lcov --no-external --capture --initial --directory . --base-directory ../code --output-file report.info
./coverage_test
# gcovr . -r ../code/ --html report.html
lcov --no-external --capture --directory . --base-directory ../src --output-file report.info
genhtml report.info --output-directory=./html

