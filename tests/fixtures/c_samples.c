// Test fixtures for C complexity calculation

#include <stdio.h>
#include <stdlib.h>

// Simple function (CC: 1)
int simple_function() {
    return 42;
}

// Function with if statement (CC: 2)
int function_with_if(int x) {
    if (x > 0) {
        return x;
    }
    return 0;
}

// Function with switch statement (CC: 4)
char* function_with_switch(int value) {
    switch (value) {
        case 1:
            return "one";
        case 2:
            return "two";
        default:
            return "unknown";
    }
}

// Function with loops (CC: 4)
void function_with_loops(int* items, int size) {
    for (int i = 0; i < size; i++) {
        printf("%d\n", items[i]);
    }
    
    int j = 0;
    while (j < size) {
        printf("Index %d: %d\n", j, items[j]);
        j++;
    }
    
    int k = 0;
    do {
        printf("Value: %d\n", items[k]);
        k++;
    } while (k < size);
}

// Function with ternary operator (CC: 2)
int function_with_ternary(int x) {
    return x > 0 ? x : -x;
}

// Function with logical operators (CC: 3)
int function_with_logical_ops(int a, int b, int c) {
    return (a && b) || c;
}

// Complex function (CC: 7)
int* complex_function(int* data, int size, int* result_size) {
    if (!data || size <= 0) {
        *result_size = 0;
        return NULL;
    }
    
    int* result = malloc(size * sizeof(int));
    int count = 0;
    
    for (int i = 0; i < size; i++) {
        if (data[i] > 0) {
            if (data[i] % 2 == 0) {
                result[count] = data[i] * 2;
                count++;
            } else {
                result[count] = data[i];
                count++;
            }
        }
    }
    
    *result_size = count;
    return result;
}

// Function with nested conditions (CC: 4)
int function_with_nested_conditions(int a, int b, int c) {
    if (a > 0) {
        if (b > 0) {
            if (c > 0) {
                return a + b + c;
            }
        }
    }
    return 0;
}

// Function with goto (CC: 3)
int function_with_goto(int x) {
    if (x < 0) {
        goto error;
    }
    
    if (x == 0) {
        goto zero_case;
    }
    
    return x * 2;
    
error:
    return -1;
    
zero_case:
    return 0;
}

// Recursive function (CC: 2)
int factorial(int n) {
    if (n <= 1) {
        return 1;
    }
    return n * factorial(n - 1);
}

// Function pointer example (CC: 2)
int apply_operation(int x, int (*operation)(int)) {
    if (operation) {
        return operation(x);
    }
    return x;
}

// Main function (CC: 3)
int main() {
    int value = 10;
    
    if (value > 0) {
        printf("Positive: %d\n", value);
    } else {
        printf("Non-positive: %d\n", value);
    }
    
    return 0;
}