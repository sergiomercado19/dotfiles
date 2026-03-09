#!/usr/bin/env bash

# Unit tests for install.sh
# Run with: bash install.test.sh

# Don't use set -e for tests as we're testing failure cases
set +e

# Test framework variables
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Colors for test output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test helpers
assert_equals() {
    local expected="$1"
    local actual="$2"
    local message="${3:-Assertion failed}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [ "$expected" = "$actual" ]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} ${message}"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} ${message}"
        echo -e "  Expected: ${expected}"
        echo -e "  Actual:   ${actual}"
        return 1
    fi
}

assert_contains() {
    local haystack="$1"
    local needle="$2"
    local message="${3:-String should contain substring}"

    TESTS_RUN=$((TESTS_RUN + 1))

    if [[ "$haystack" == *"$needle"* ]]; then
        TESTS_PASSED=$((TESTS_PASSED + 1))
        echo -e "${GREEN}✓${NC} ${message}"
        return 0
    else
        TESTS_FAILED=$((TESTS_FAILED + 1))
        echo -e "${RED}✗${NC} ${message}"
        echo -e "  Haystack: ${haystack}"
        echo -e "  Needle:   ${needle}"
        return 1
    fi
}

# Source the functions from install.sh (but don't run main)
source_install_functions() {
    local install_script="$HOME/.local/share/chezmoi/install.sh"
    # Source everything except:
    # - Line 3: set -e
    # - Line 116: print_step "Detected OS:"
    # - Last line: main call
    source <(sed -e '3d' -e '116d' "$install_script" | head -n -1)
    # Ensure set +e is active for tests
    set +e
}

# ============================================================================
# Test: Configuration Variables
# ============================================================================
test_configuration_defaults() {
    echo ""
    echo -e "${BLUE}Testing: Configuration Defaults${NC}"

    unset GITHUB_USERNAME
    source_install_functions

    assert_equals "sergiomercado19" "$GITHUB_USERNAME" "Default GitHub username should be sergiomercado19"
    assert_contains "$DOTFILES_REPO_SSH" "git@github.com:sergiomercado19/dotfiles.git" "SSH repo URL should contain default username"
    assert_contains "$DOTFILES_REPO_HTTPS" "https://github.com/sergiomercado19/dotfiles.git" "HTTPS repo URL should contain default username"
}

test_configuration_custom_username() {
    echo ""
    echo -e "${BLUE}Testing: Configuration Custom Username${NC}"

    export GITHUB_USERNAME="testuser"
    source_install_functions

    assert_equals "testuser" "$GITHUB_USERNAME" "GitHub username should be testuser"
    assert_contains "$DOTFILES_REPO_SSH" "git@github.com:testuser/dotfiles.git" "SSH repo URL should contain custom username"
    assert_contains "$DOTFILES_REPO_HTTPS" "https://github.com/testuser/dotfiles.git" "HTTPS repo URL should contain custom username"

    unset GITHUB_USERNAME
}

# ============================================================================
# Test: Helper Functions
# ============================================================================
test_command_exists() {
    echo ""
    echo -e "${BLUE}Testing: command_exists()${NC}"

    source_install_functions

    command_exists bash
    assert_equals "0" "$?" "command_exists should return 0 for existing command (bash)"

    command_exists this_command_definitely_does_not_exist_12345
    assert_equals "1" "$?" "command_exists should return 1 for non-existing command"
}

test_print_functions() {
    echo ""
    echo -e "${BLUE}Testing: Print Functions${NC}"

    source_install_functions

    local output
    output=$(print_step "test message" 2>&1)
    assert_contains "$output" "test message" "print_step should output the message"

    output=$(print_success "success message" 2>&1)
    assert_contains "$output" "success message" "print_success should output the message"

    output=$(print_warning "warning message" 2>&1)
    assert_contains "$output" "warning message" "print_warning should output the message"

    output=$(print_error "error message" 2>&1)
    assert_contains "$output" "error message" "print_error should output the message"

    output=$(print_progress "progress message" 2>&1)
    assert_contains "$output" "progress message" "print_progress should output the message"
}

# ============================================================================
# Test: check_dependencies()
# ============================================================================
test_check_dependencies() {
    echo ""
    echo -e "${BLUE}Testing: check_dependencies()${NC}"

    source_install_functions

    # Test with all dependencies present
    command_exists() {
        case "$1" in
            curl|tee)
                return 0
                ;;
            *)
                return 1
                ;;
        esac
    }

    local output
    output=$(check_dependencies 2>&1)
    assert_contains "$output" "All required dependencies present" "Should show success message when all deps present"

    # Test with missing dependency
    command_exists() {
        case "$1" in
            curl)
                return 1
                ;;
            *)
                return 0
                ;;
        esac
    }

    # Mock exit to prevent script termination
    exit() {
        echo "EXIT_CALLED_WITH_CODE_$1"
        return "$1"
    }

    output=$(check_dependencies 2>&1 || true)
    assert_contains "$output" "Missing required dependencies" "Should show error when deps missing"
    assert_contains "$output" "curl" "Should list missing dependency"
}

# ============================================================================
# Test: verify_installation()
# ============================================================================
test_verify_installation() {
    echo ""
    echo -e "${BLUE}Testing: verify_installation()${NC}"

    source_install_functions

    # Test with existing tool and version
    command_exists() {
        return 0
    }

    local output
    output=$(verify_installation "test_tool" "echo 'v1.0.0'" 2>&1)
    assert_contains "$output" "test_tool verified" "Should show verification message"
    assert_contains "$output" "v1.0.0" "Should show version"

    # Test with existing tool without version
    output=$(verify_installation "test_tool" "" 2>&1)
    assert_contains "$output" "test_tool verified" "Should show verification message without version"

    # Test with missing tool
    command_exists() {
        return 1
    }

    output=$(verify_installation "missing_tool" "" 2>&1)
    assert_contains "$output" "verification failed" "Should show failure message for missing tool"
}

# ============================================================================
# Test: OS Detection
# ============================================================================
test_os_detection() {
    echo ""
    echo -e "${BLUE}Testing: OS Detection${NC}"

    # Test Linux detection
    OSTYPE="linux-gnu"
    source_install_functions
    assert_equals "linux" "$OS" "Should detect Linux OS"

    # Test macOS detection
    OSTYPE="darwin20"
    source_install_functions
    assert_equals "macos" "$OS" "Should detect macOS"
}

# ============================================================================
# Main Test Runner
# ============================================================================
run_all_tests() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║     install.sh Unit Test Suite        ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"

    # Configuration tests
    test_configuration_defaults
    test_configuration_custom_username

    # Helper function tests
    test_command_exists
    test_print_functions

    # Dependency and verification tests
    test_check_dependencies
    test_verify_installation

    # OS detection test
    test_os_detection

    # Print summary
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║          Test Summary                  ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "Total Tests:  ${TESTS_RUN}"
    echo -e "${GREEN}Passed:       ${TESTS_PASSED}${NC}"

    if [ $TESTS_FAILED -gt 0 ]; then
        echo -e "${RED}Failed:       ${TESTS_FAILED}${NC}"
        echo ""
        exit 1
    else
        echo -e "Failed:       ${TESTS_FAILED}"
        echo ""
        echo -e "${GREEN}All tests passed! ✓${NC}"
        exit 0
    fi
}

# Run tests (guard against multiple execution)
if [ -z "$TEST_RUNNER_EXECUTED" ]; then
    export TEST_RUNNER_EXECUTED=1
    run_all_tests
fi
