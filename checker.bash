#!/bin/bash

executable="./push_swap"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'
BOLD="\e[1m"
RESET="\e[0m"

title_valid="${GREEN}${BOLD}TESTS VALIDES${NC}"
title_nothing="${GREEN}${BOLD}TEST WITHOUT ARGUMENTS${NC}"
title_invalid="${GREEN}${BOLD}TEST INVALIDES ERROR${NC}"
title_final="${GREEN}${BOLD}TEST FINISH${NC}"

# Compteurs
total_tests=0
passed_tests=0

# Fonction pour normaliser (enlever espaces/retours à la ligne en trop)
normalize() {
	echo "$1" | tr -s '[:space:]' ' ' | sed 's/^ *//;s/ *$//'
}

# Fonction pour comparer et afficher
test_output() {
	local test_name="$1"
	local expected="$2"
	shift 2
	local result=$("$executable" "$@" 2>&1)

	total_tests=$((total_tests + 1))

	echo -e "${YELLOW}Test: ${test_name}${NC}"
	echo "Value expected: $expected"

	# Normaliser les deux chaînes pour la comparaison
	local normalized_result=$(normalize "$result")
	local normalized_expected=$(normalize "$expected")

	if [ "$normalized_result" = "$normalized_expected" ]; then
		echo -e "${GREEN}./push_swap: $result ✓${NC}"
		passed_tests=$((passed_tests + 1))
	else
		echo -e "${RED}./push_swap: $result ✗${NC}"
		echo -e "${RED}(expected: '$normalized_expected')${NC}"
		echo -e "${RED}(receveid: '$normalized_result')${NC}"
	fi
	echo ""
}

echo -e "${BLUE}╔═════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║	   ${title_nothing}         ${BLUE}║${NC}"
echo -e "${BLUE}╚═════════════════════════════════════════╝${NC}"

total_tests=$((total_tests + 1))
result=$("$executable" 2>&1)
expected=""
echo "Value expected: (nothing)"
if [ "$result" = "$expected" ]; then
	echo -e "${GREEN}./push_swap: (nothing) ✓${NC}"
	passed_tests=$((passed_tests + 1))
else
	echo -e "${RED}./push_swap: $result ✗${NC}"
fi
echo ""

echo -e "${BLUE}╔═════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║              ${title_valid}              ${BLUE}║${NC}"
echo -e "${BLUE}╚═════════════════════════════════════════╝${NC}"

echo -e "\n${BOLD}--- NUMBER SIMPLES ---"
test_output "1" "" 1
test_output "42" "" 42
test_output "-42" "" -42
test_output "+42" "" +42

echo -e "${BOLD}--- LIMITES INT ---"
test_output "2147483647 (INT_MAX)" "" 2147483647
test_output "2147483646" "" 2147483646
test_output "-2147483648 (INT_MIN)" "" -2147483648
test_output "-2147483647" "" -2147483647

echo -e "${BOLD}--- MULTIPLES ARGUMENTS ---"
test_output "100 200 300" "100 200 300" 100 200 300
test_output "-200 +300" "-200 300" -200 +300
test_output "\"1 2 3 4 5\"" "1 2 3 4 5" "1 2 3 4 5"
test_output "\"89 65 30\" 12 60" "89 65 30 12 60" "89 65 30" 12 60
test_output "\"89 43 56 72\" 42 65 76 \"24 32 87\"" "89 43 56 72 42 65 76 24 32 87" "89 43 56 72" 42 65 76 "24 32 87"
test_output "87 5589 \"     0 9 554   \" 89" "87 5589 0 9 554 89" 87 5589 "     0 9 554   " 89

echo -e "${BOLD}--- WITH SPACES ---"
test_output "\" 42\"" "" " 42"
test_output "\"42 \"" "" "42 "

echo -e "${BOLD}--- ZEROS ---"
test_output "0" "" 0
test_output "-0" "" -0
test_output "+0" "" +0
test_output "00000000000000000001" "" 00000000000000000001
test_output "0000000000000000000" "" 0000000000000000000
test_output "00000000000000000000000000 -00000000000000000000000000001 000000000000000000000002 03" "0 -1 2 3" "00000000000000000000000000 -00000000000000000000000000001 000000000000000000000002 03"

echo -e "${BLUE}╔═════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           ${title_invalid}          ${BLUE}║${NC}"
echo -e "${BLUE}╚═════════════════════════════════════════╝${NC}"

echo -e "\n${BOLD}--- OVERFLOW / UNDERFLOW ---"
test_output "2147483648 (INT_MAX+1)" "Error" 2147483648
test_output "-2147483649 (INT_MIN-1)" "Error" -2147483649
test_output "21474836489999 (INT_MAX+9999)" "Error" 21474836489999
test_output "9999999999" "Error" 9999999999
test_output "10000000000002" "Error" 10000000000002
test_output "2147483648 (INT_MAX+1)" "Error" 2147483648
test_output "9223372036854775808" "Error" 9223372036854775808
test_output "-9223372036854775809" "Error" -9223372036854775809

echo -e "${BOLD}--- DUPLICATES ---"
test_output "42 42" "Error" 42 42
test_output "0 0" "Error" 0 0
test_output "+0 -0" "Error" +0 -0
test_output "+00 +000" "Error" +00 +000
test_output "-5 -5" "Error" -5 -5
test_output "+1 +01" "Error" +1 +01

echo -e "${BOLD}--- INVALIDS CHARACTERS ---"
test_output "42a" "Error" 42a
test_output "a42" "Error" a42
test_output "a42a" "Error" a42a
test_output "\"42 a\"" "Error" "42 a"
test_output "42.5" "Error" 42.5
test_output "42,5" "Error" 42,5

echo -e "${BOLD}--- MISPLACED SIGNS ---"
test_output "+-0" "Error" "+-0"
test_output "-+42 1" "Error" -+42 1
test_output "1+2" "Error" 1+2
test_output "42+42" "Error" 42+42
test_output "42-42" "Error" 42-42
test_output "\"76 87\"+34" "Error" "76 87"+34
test_output "\"42         +\"" "Error" "42         +"
test_output "+" "Error" +
test_output "-" "Error" -

echo -e "${BLUE}╔═════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║	         ${title_final}              ${BLUE}║${NC}"
echo -e "${BLUE}╚═════════════════════════════════════════╝${NC}"
echo ""

# Affichage du résultat final
percentage=$((passed_tests * 100 / total_tests))
if [ $passed_tests -eq $total_tests ]; then
	echo -e "${GREEN}✓ Tous les tests sont passés ! ${passed_tests}/${total_tests} (${percentage}%)${NC}"
else
	echo -e "${RED}✗ Tests réussis: ${passed_tests}/${total_tests} (${percentage}%)${NC}"
fi
