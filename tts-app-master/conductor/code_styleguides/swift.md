# Swift Code Style Guide (Google Style)

This guide summarizes key Swift style guidelines from Google's official Swift Style Guide, emphasizing practical rules for new projects.

## 1. Source File Basics

### File Names
*   **Naming Convention:** Source files should describe their primary entity.
    *   A file containing a single type `MyType` is named `MyType.swift`.
    *   A file extending `MyType` for `MyProtocol` conformance is named `MyType+MyProtocol.swift`.
    *   For multiple extensions or functionality, use `MyType+Additions.swift`.
    *   For related declarations not scoped under a common type, use a descriptive name (e.g., `Math.swift`).
*   **Encoding:** Source files are encoded in UTF-8.
*   **Whitespace:** Only Unicode horizontal space (U+0020) is used for whitespace. Tab characters are not used for indentation.

### Special Escape Sequences
*   Use special escape sequences (`\t`, `\n`, `\r`, `\"`, `\'`, `\\`, `\0`) instead of Unicode escape sequences (e.g., `\u{000a}`).

### String Literals
*   Avoid mixing Unicode code points written literally and Unicode escape sequences (`\u{????}`) in the same string. Either use literal Unicode characters or 7-bit ASCII with Unicode escape sequences.

## 2. Source File Structure

### File Comments
*   Optional for files with a single abstraction (documentation comment on the abstraction is sufficient).
*   Allowed for files with multiple abstractions to document the grouping.

### Import Statements
*   Import only the top-level modules needed.
*   Prefer importing whole modules over individual declarations or submodules, unless importing the whole module pollutes the global namespace or a submodule provides unique functionality.
*   Import statements are not line-wrapped.
*   **Ordering:**
    1.  Module/submodule imports not under test.
    2.  Individual declaration imports (`class`, `enum`, `func`, `struct`, `var`).
    3.  Modules imported with `@testable` (only in test sources).
    *   Each group should be ordered lexicographically with one blank line between groups.

### Type, Variable, and Function Declarations
*   Generally, one top-level type per file, especially for large declarations. Exceptions for related types (e.g., a class and its delegate protocol).
*   Maintain a logical order for members within a type. Avoid chronological ordering.
*   Use `// MARK:` comments to describe logical groupings of members.

### Overloaded Declarations
*   Overloaded initializers, subscripts, or functions with the same base name should appear sequentially without other code in between.

### Extensions
*   Use extensions to organize functionality. Maintain a logical organizational structure.

## 3. General Formatting

### Column Limit
*   **100 characters.** Line-wrap any line exceeding this limit.
*   **Exceptions:** Long URLs in comments, import statements, and tool-generated code.

### Braces
*   **K&R style:** No line break before the opening brace `{`.
*   Line break after opening brace, except for closures (signature on same line if it fits, then line break after `in`) or empty blocks (`{}`).
*   Line break before closing brace, except for empty blocks.
*   Line break after closing brace if it terminates a statement or declaration body.
*   `else` blocks: `} else {` with both braces on the same line.

### Semicolons
*   **Not used** to terminate or separate statements. Only allowed inside string literals or comments.

### One Statement Per Line
*   At most one statement per line, followed by a line break.
*   Exceptions: Lines ending with a block containing zero or one statements (e.g., `guard let value = value else { return 0 }`).
*   Exercise judgment for single-line conditionals; prefer multi-line for significant logic.

### Line-Wrapping
*   If a declaration, statement, or expression fits on one line, keep it on one line.
*   Comma-delimited lists are either entirely horizontal or entirely vertical.
    *   Horizontal: No line breaks.
    *   Vertical: Line break before the first element and after each element.
*   Continuation lines starting with an unbreakable token sequence are indented at the same level as the original line.
*   Continuation lines in vertically-oriented comma-delimited lists are indented `+2` from the original line.
*   When an open curly brace `{` follows a line-wrapped declaration/expression, it's on the same line as the final continuation line, unless that line is indented `+2`, in which case the brace is on its own line.

### Horizontal Whitespace
*   **Single space only** in the following places (beyond language requirements):
    *   Separating reserved words (`if`, `guard`, `while`, `switch`) from an expression starting with `(`.
    *   Before any closing `}` that follows code on the same line, before any open `{`, and after any open `{` followed by code on the same line.
    *   On both sides of binary or ternary operators, assignment (`=`), protocol composition (`&`), and the function return arrow (`->`).
*   **No space:**
    *   On either side of the dot (`.`) for member access.
    *   On either side of range operators (`..<`, `...`).
*   **After, but not before, the comma (`,`)** in parameter lists, tuple/array/dictionary literals.
*   **After, but not before, the colon (`:`)** in:
    *   Superclass/protocol conformance lists and generic constraints.
    *   Function argument labels and tuple element labels.
    *   Variable/property declarations with explicit types.
    *   Shorthand dictionary type names.
    *   Dictionary literals.
*   At least two spaces before and exactly one space after the double slash (`//`) for end-of-line comments.
*   Outside, but not inside, the brackets of array/dictionary literals and parentheses of tuple literals.

### Horizontal Alignment
*   **Forbidden**, except for obviously tabular data where readability would be harmed without it.

### Vertical Whitespace
*   **Single blank line:**
    *   Between consecutive members of a type (properties, initializers, methods, enum cases, nested types).
        *   Optional between two consecutive stored properties or enum cases that fit on one line, or between closely related properties.
    *   As needed between statements to organize code into logical subsections.
    *   Optionally before the first member or after the last member of a type.
*   Multiple blank lines are permitted but not encouraged; use consistently if used.

### Parentheses
*   **Not used** around the top-most expression following `if`, `guard`, `while`, or `switch`.
*   Optional grouping parentheses are omitted only when there's no reasonable chance of misinterpretation and they don't improve readability.

## 4. Formatting Specific Constructs

### Non-Documentation Comments
*   Always use double-slash format (`//`), never C-style block format (`/* ... */`).

### Properties
*   Local variables are declared close to their first use to minimize scope.
*   Each `let` or `var` statement declares exactly one variable (except for tuple destructuring).

### Switch Statements
*   `case` statements are indented at the same level as the `switch`.
*   Statements inside `case` blocks are indented `+2` spaces from the `case` level.

### Enum Cases
*   Generally, one case per line.
*   Comma-delimited form allowed only if no associated/raw values, all fit on one line, and meanings are obvious.
*   If all cases are `indirect`, declare the `enum` itself as `indirect`.
*   Empty parentheses are never present for cases without associated values.
*   Cases should follow a logical ordering (e.g., numerical, then lexicographical if no other logic).

### Trailing Closures
*   Avoid overloading functions where only the trailing closure argument name differs.
*   If a function call has multiple closure arguments, none use trailing closure syntax; all are labeled and nested.
*   If a function has a single, final closure argument, always use trailing closure syntax, unless it resolves ambiguity or parsing errors.
*   When a function called with trailing closure syntax takes no other arguments, empty parentheses `()` after the function name are never present.

### Trailing Commas
*   **Required** in array and dictionary literals when each element is on its own line for cleaner diffs.

### Numeric Literals
*   Recommended (but not required) to use underscore `_` separators for readability in long numeric literals (e.g., `1_000`, `0x_FF_FF`).
*   Do not group digits if the literal is an opaque identifier without meaningful numeric value.

### Attributes
*   Parameterized attributes (e.g., `@available(...)`) are on their own line, lexicographically ordered, and indented at the same level as the declaration.
*   Attributes without parameters (e.g., `@IBOutlet`) can be on the same line if they fit without wrapping the declaration. Otherwise, place on their own line.

## 5. Naming

### Apple's API Style Guidelines
*   Follow Apple's official Swift naming and API design guidelines.

### Naming Conventions Are Not Access Control
*   Prefer restricted access control (`internal`, `fileprivate`, `private`) for information hiding over naming conventions (e.g., leading underscore).

### Identifiers
*   Generally, use only 7-bit ASCII characters. Unicode identifiers are allowed if they have clear, legitimate meaning in the problem domain and are well understood by the team.

### Initializers
*   Initializer arguments corresponding to stored properties should have the same name as the property. Use `self.` to disambiguate during assignment.

### Static and Class Properties
*   Static/class properties returning instances of the declaring type are not suffixed with the type name (e.g., `UIColor.red` instead of `UIColor.redColor`).

### Global Constants
*   Use `lowerCamelCase`. Avoid Hungarian notation (e.g., `g` or `k` prefixes) or `SCREAMING_SNAKE_CASE`.

### Delegate Methods
*   Follow Cocoa's protocol naming conventions for delegate methods.
    *   First argument is always the delegate's source object.
    *   Methods returning `Void` (notifications): base name is source type + indicative verb phrase (e.g., `scrollViewDidBeginScrolling(_:)`).
    *   Methods returning `Bool` (assertions): base name is source type + indicative/conditional verb phrase (e.g., `scrollViewShouldScrollToTop(_:)`).
    *   Methods returning other values (queries): base name is noun phrase describing property, argument labeled with preposition (e.g., `numberOfSections(in:)`).
    *   For methods with additional arguments: base name is source type, second argument labeled with indicative verb phrase (for `Void` return) or noun phrase (for other returns).

## 6. Programming Practices

### Compiler Warnings
*   Code should compile without warnings. Remove easily fixable warnings. Deprecation warnings are a reasonable exception if immediate migration is not possible.

### Initializers
*   Use Swift's synthesized memberwise initializer for `struct`s when suitable.
*   Never call `ExpressibleBy*Literal` initializers directly.
*   Omit `.init` in direct calls to initializers using the literal type name (e.g., `MyType(arguments)` instead of `MyType.init(arguments)`).

### Properties
*   Omit the `get` block for read-only computed properties; directly nest the body inside the property declaration.

### Types with Shorthand Names
*   Use shorthand forms for arrays (`[Element]`), dictionaries (`[Key: Value]`), and optionals (`Wrapped?`) whenever possible.
*   `Void` return type in function declarations (`func`) is omitted.
*   Empty argument lists are always `()`, never `Void`.

### Optional Types
*   Avoid sentinel values (e.g., `-1` for "not found"). Use `Optional` to convey absence of a value or a non-error result.
*   Use `Optional` for error scenarios with a single, obvious failure state.

---
