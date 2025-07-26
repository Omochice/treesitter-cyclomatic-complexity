# Test fixtures for Python complexity calculation

# Simple function (CC: 1)
def simple_function():
    return 42

# Function with if statement (CC: 2)
def function_with_if(x):
    if x > 0:
        return x
    return 0

# Function with elif (CC: 3)
def function_with_elif(x):
    if x > 0:
        return "positive"
    elif x < 0:
        return "negative"
    else:
        return "zero"

# Function with loops (CC: 3)
def function_with_loops(items):
    for item in items:
        print(item)
    
    i = 0
    while i < len(items):
        print(f"Index {i}: {items[i]}")
        i += 1

# Function with try-except (CC: 4)
def function_with_try_except():
    try:
        result = risky_operation()
        return result
    except ValueError:
        return None
    except Exception as e:
        print(f"Error: {e}")
        return None

# Function with list comprehension and conditional (CC: 2)
def function_with_comprehension(items):
    if not items:
        return []
    
    return [item for item in items if item > 0]

# Function with with statement (CC: 2)
def function_with_with(filename):
    if not filename:
        return None
    
    with open(filename, 'r') as f:
        return f.read()

# Async function (CC: 3)
async def async_function():
    try:
        result = await some_async_operation()
        if result:
            return result
    except Exception:
        return None

# Function with boolean operators (CC: 3)
def function_with_boolean_ops(a, b, c):
    return a and b or c

# Complex function (CC: 8)
def complex_function(data):
    if not data:
        return None
    
    result = []
    for item in data:
        if item.get('type') == 'special':
            try:
                processed = process_item(item)
                if processed and processed.get('valid'):
                    result.append(processed)
                else:
                    continue
            except Exception as e:
                print(f"Processing failed: {e}")
                continue
        else:
            result.append(item)
    
    return result

# Function with nested conditions (CC: 5)
def function_with_nested_conditions(a, b, c):
    if a:
        if b:
            if c:
                return "all true"
            else:
                return "c false"
        else:
            return "b false"
    return "a false"

# Function with conditional expression (CC: 2)
def function_with_ternary(x):
    return x if x > 0 else -x

# Generator function (CC: 3)
def generator_function(items):
    for item in items:
        if item % 2 == 0:
            yield item * 2

# Class method (CC: 2)
class MyClass:
    def method_function(self, value):
        if value > 0:
            return value * 2
        return 0
    
    @staticmethod
    def static_method():
        return "static"
    
    @classmethod
    def class_method(cls):
        return cls.__name__

# Decorator function (CC: 2)
def decorator_function(func):
    def wrapper(*args, **kwargs):
        if args:
            return func(*args, **kwargs)
        return None
    return wrapper