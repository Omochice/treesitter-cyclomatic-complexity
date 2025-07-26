// Test fixtures for JavaScript complexity calculation

// Simple function (CC: 1)
function simpleFunction() {
  return 42;
}

// Arrow function (CC: 1)
const arrowFunction = () => {
  return 42;
}

// Function with if statement (CC: 2)
function functionWithIf(x) {
  if (x > 0) {
    return x;
  }
  return 0;
}

// Function with switch statement (CC: 4)
function functionWithSwitch(value) {
  switch (value) {
    case 1:
      return 'one';
    case 2:
      return 'two';
    default:
      return 'unknown';
  }
}

// Function with try-catch (CC: 3)
function functionWithTryCatch() {
  try {
    riskyOperation();
    return true;
  } catch (error) {
    console.error(error);
    return false;
  }
}

// Function with multiple loop types (CC: 4)
function functionWithLoops(items, obj) {
  for (let i = 0; i < items.length; i++) {
    console.log(items[i]);
  }
  
  for (const item of items) {
    console.log(item);
  }
  
  for (const key in obj) {
    console.log(key, obj[key]);
  }
  
  while (condition()) {
    action();
  }
}

// Function with ternary operator (CC: 2)
function functionWithTernary(x) {
  return x > 0 ? x : -x;
}

// Function with logical operators (CC: 3)
function functionWithLogicalOps(a, b, c) {
  return a && b || c;
}

// Complex function (CC: 8)
function complexFunction(data) {
  if (!data) {
    return null;
  }
  
  const result = [];
  for (const item of data) {
    if (item.type === 'special') {
      try {
        const processed = processItem(item);
        if (processed && processed.valid) {
          result.push(processed);
        }
      } catch (error) {
        console.error('Processing failed:', error);
      }
    } else {
      result.push(item);
    }
  }
  
  return result;
}

// Method in class (CC: 2)
class MyClass {
  methodFunction(value) {
    if (value > 0) {
      return value * 2;
    }
    return 0;
  }
  
  // Static method (CC: 1)
  static staticMethod() {
    return 'static';
  }
}

// Function expression (CC: 2)
const functionExpression = function(flag) {
  return flag ? 'yes' : 'no';
};

// Async function (CC: 3)
async function asyncFunction() {
  try {
    const result = await someAsyncOperation();
    return result;
  } catch (error) {
    return null;
  }
}