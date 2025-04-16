# Pony Standard Library Style Guide

This is a document describing the preferred practices for writing code for the Pony standard library. Other projects are free to use the same style, but you are free to use any style in other projects. The following conventions are meant to ensure consistency and readability of Pony code. Any of the following rules may be broken in situations where the recommended practice would diminish readability.

## Formatting

### Line Length

The maximum line length is 80 columns.

### Trailing Whitespace

No trailing whitespace at the end of lines.

### Indentation

Use 2 spaces for indentation, no hard tabs.

```pony
actor Main
  new create(env: Env) =>
    env.out.print("Hello, world!")
```

### Blank Lines

- One blank line is placed between top-level declarations such as classes, primitives, actors, etc.
- There is no blank lines between the class declaration and its first member or documentation.
- Fields have no blank lines between them.
- Functions are separated from other members by one line.

  ```pony
  // OK
  class Foo
    let bar: Bar
    let baz: Baz

    fun foo() =>
      // ...

    fun bar() =>
      // ...

  // OK
  class Foo
    """
    Some documentation
    """
    let bar: Bar

    fun foo() =>
      // ...

  // OK
  class Foo
    fun foo() =>
      // ...

  // Not OK
  class Foo

    let bar: Bar
    let baz: Baz
    fun foo() =>
      // ...
  ```

- Blank lines between __one-line__ functions or primitives may be omitted if they are related.

  ```pony
  primitive Red fun apply(): U32 => 0xFF0000FF
  primitive Green fun apply(): U32 => 0x00FF00FF
  primitive Blue fun apply(): U32 => 0x0000FFFF

  type Color is (Red | Green | Blue)
  ```

### Whitespace

- Use spaces around binary operators and after commas, colons, and semicolons. Do not put spaces around brackets or parentheses.

  ```pony
  let x: USize = 3

  x = x + (5 * x)

  (let a, let b) = ("a", "b")

  let ns = [as USize: 1; 2; 3]

  fun foo(i: USize, bar: USize = 0)

  foo(x where bar = y)
  ```

- The `not` operator is surrounded by spaces, but the `-` operator is not followed by a space.

  ```pony
  if not x then -a end
  ```

- Lambda expressions follow the rules above except that a space is placed before the closing brace only if the lambda is on one line.

  ```pony
  // OK
  {(a: USize, b: USize): USize => a + b }

  // OK
  {(a: USize, b: USize): USize =>
    a + b
  }

  // Not OK
  {(a: USize, b: USize): USize => a + b}

  // Not OK
  { (a: USize, b: USize): USize => a + b }

  // Not OK
  {(a: USize, b: USize): USize =>
    a + b }
  ```

- Normal rules apply to Lambda types.

  ```pony
  // OK
  type foo is {(USize, USize): USize} box

  // Not OK
  type foo is {(USize, USize): USize } box

  // Not OK
  type foo is { (USize, USize): USize } box
  ```

### Type Aliases

Align long union and intersection types with each type on a separate line starting with the `(`, `|`, or `&` symbols. In this case, every symbol must be separated by a single space or a newline.

```pony
// OK
type Signed is (I8 | I16 | I32 | I64 | I128)

// OK
type Signed is
  ( I8
  | I16
  | I32
  | I64
  | I128 )

// OK
type Signed is
  ( I8
  | I16
  | I32
  | I64
  | I128
  )

// Not OK
type Signed is ( I8
              | I16
              | I32
              | I64
              | I128 )

// Not OK
type Signed is
  (I8
  |I16
  |I32
  |I64
  |I128)
```

### Array Literals

Multiline arrays generally have a newline between each entry, though logical exceptions exist (such as tables).

```pony
// OK
let ns = [as USize: 1; 2; 3]

// OK
let strs = ["a"; "b"; "c"]

// OK
let ns =
  [ as USize:
    1
    2
    3 ]

// OK
let ns =
  [ as USize:
    1
    2
    3
  ]

// Not OK
let ns =
  [as USize:
   1
   2
   3
  ]

// Not OK
let ns = [ as USize:
    1
    2
    3
]

// Not OK
let ns = [ as USize:
          1
          2
          3 ]
```

### Control Structures

- Control structures are aligned so that their keywords (if, else, for, try, end, etc.) are at the same indentation level.

  ```pony
  if cond1 then e1
  elseif cond2 then e2
  else e3
  end

  if cond1 then
    e1
  elseif cond2 then
    e2
  else
    e3
  end

  for name in ["Bob"; "Fred"; "Sarah"].values() do
    env.out.print(name)
  end
  ```

- Small expressions may be placed on a single line.

  ```pony
  if cond then e1 else e2 end
  ```

- Match expression cases are __not__ indented.

  ```pony
  match (x, y)
  | (None, _) => "none"
  | (let s: String, 2) => s + " two"
  | (let s: String, 3) => s + " three"
  | (let s: String, let u: U32) if u > 14 => s + " other big integer"
  | (let s: String, _) => s + " other small integer"
  else "something else"
  end

  match alive
  | true =>
    Debug.err("Beep boop!")
    this.forever()
  | false =>
    Debug.err("Ugah!")
    None
  end
  ```

- Match expressions __may not__ be on a single line.

  ```pony
  // OK
  match x
  | let n: U8 => n.string()
  else "0"
  end

  // Not OK
  match x | let n: U8 => n.string() else "0" end
  ```

### Assignment

Assignment of a multiline expression is indented below the `=` symbol.

```pony
// OK
var x =
  if friendly then
    "Hello"
  else
    false
  end

// OK
let output =
  recover String(
    file_name.size()
      + file_linenum.size()
      + file_linepos.size()
      + msg.size()
      + 4)
  end

// Not OK
var x = if friendly then
  "Hello"
else
  false
end
```

### Method Declarations

- Partial functions are denoted with a `?` separated from other symbols by one space.

  ```pony
  // OK
  fun foo(): Foo^ ? =>
  // ...

  // OK
  fun foo() ? =>
  // ...

  // Not OK
  fun foo(): Foo^? =>
  // ...

  // Not OK
  fun foo()? =>
  // ...
  ```

- Multiline function parameters are each listed on a separate line. The return type preceded by a `:` is placed at the same indentation level followed by a question mark (if the function is partial). The `=>` is placed on a separate line between the parameter list and the function body at the same indentation level as the `fun` keyword. These rules also apply to FFI function declarations.

  ```pony
  // OK
  fun find(
    value: A!,
    offset: USize = 0,
    nth: USize = 0,
    predicate: {(box->A!, box->A!): Bool} val =
      {(l: box->A!, r: box->A!): Bool => l is r })
    : USize ?
  =>
    // ...

  // OK
  fun tag _init(typ': ValueType, default': (Value | None))
    : (ValueType, Value, Bool) ?
  =>
    // ...

  // OK
  @pony_asio_event_create[AsioEventID](
    owner: AsioEventNotify,
    fd: U32,
    flags: U32,
    nsec: U64,
    noisy: Bool)

  // Not OK
  fun find(
           value: A!,
           offset: USize = 0,
           nth: USize = 0,
           predicate: {(box->A!, box->A!): Bool} val =
             {(l: box->A!, r: box->A!): Bool => l is r })
           : USize ?
           =>
    // ...
  ```

### Function Calls

- No spaces are placed around the `.` symbol, but the `.>` symbol is spaced like an infix operator.

  ```pony
  // OK
  Iter[I64](input.values()).skip(2).next()

  // OK
  output .> append(file_name) .> append(":") .> append(msg)

  // Not OK
  Iter[I64](input . values()) . skip(2) . next()

  // Not OK
  output.>append(file_name).>append(":").>append(msg)
  ```

- Explicit partial calls are postfixed with '?' operator without whitespace in between.

  ```pony
  // OK
  [as U8: 0; 1; 1].apply(0)?

  // not OK
  let newVal = myHashMap.insert("key", "value") ?
  ```

- Multiple function calls should generally be aligned so that each call is placed on a separate line indented below the initial object.

  ```pony
  // OK
  Iter[I64](input.values())
    .take_while({(x: I64): Bool ? => error })
    .collect(Array[I64]))

  // OK
  output
    .> append(file_name)
    .> append(":")
    .> append(msg)

  // Not OK
  Iter[I64](input.values()).take_while({(x: I64): Bool ? => error })
    .collect(Array[I64]))

  // Not OK
  output
  .> append(file_name)
  .> append(":")
  .> append(msg)
  ```

- Function arguments mostly follow the same rules as arguments in method declarations. However, all arguments may be placed on the following line with an additional level of indentation if all arguments would fit on that line. Otherwise, arguments must be placed on individual lines. These rules also apply to FFI calls. A `where` keyword and the following arguments may all exist on their own line.

  ```pony
  // OK
  h.assert_true(Iter[I64](input.values()).any(is_positive))

  // OK
  Iter[String].chain(
    [input0.values(); input1.values(); input0.values()].values())

  // OK
  h.assert_eq[String](
    "   fmt   ",
    Format("fmt", FormatDefault, PrefixDefault, -1, 9, AlignCenter))

  // OK
  buf.append(Format.int[U32](
    high
    where fmt = FormatHexBare, width = 4))

  // Not OK
  @pony_asio_event_create(this, fd,
    AsioEvent.read_write_oneshot(), 0, true)

  // Not OK
  options.upsert(o.spec().name(),
                 o,
                 {(x, n) => x._append(n) })?
  ```

### Type Parameters and Constraints

Multiline type parameters are each listed on a separate line. Type constraints will start on the next line beginning with the `is` keyword. Complex type constraints follow the rules described in [Type Aliases](#type-aliases).

```pony
// OK
type Map[
  K: (mut.Hashable val & Equatable[K]),
  V: Any #share]
  is HashMap[K, V, mut.HashEq[K]]

// OK
class Flags[
  A: Flag[B] val, B: (Unsigned & Integer[B] val) = U64]
  is Comparable[Flags[A, B] box]

// OK
type BinaryHeapPriority[A: Comparable[A] #read]
  is ( _BinaryHeapPriority[A]
    & (MinHeapPriority[A] | MaxHeapPriority[A]) )

// OK
fun ref zip4[B, C, D, E](
  i2: Iterator[B],
  i3: Iterator[C],
  i4: Iterator[D],
  i5: Iterator[E])
  : Iter[(A, B, C, D, E)]^
=>

// OK
fun div_checked[
  T: (SignedInteger[T, U] val & Signed),
  U: UnsignedInteger[U] val](
  x: T,
  y: T)
  : (T, Bool)
=>

// Not OK
primitive HashEq64
  [A: (Hashable64 #read & Equatable[A] #read)] is HashFunction64[A]

// Not OK
class Flags[A: Flag[B] val,
            B: (Unsigned & Integer[B] val) = U64]
  is Comparable[Flags[A, B] box]

// Not OK
class val _MapCollisions[K: Any #share, V: Any #share,
  H: mut.HashFunction[K] val]

// Not OK
fun mod_checked
  [T: (SignedInteger[T, U] val & Signed), U: UnsignedInteger[U] val](
  x: T,
  y: T)
  : (T, Bool)
=>

```

## Naming

- `CamelCase` is used for types and `snake_case` is used for field, function, and variable names.

- Acronyms (HTTP, JSON, XML) in types are uppercase.

  ```pony
  // OK
  primitive URLEncode

  // OK
  type TCPConnectionAuth is (AmbientAuth | NetAuth | TCPAuth | TCPConnectAuth)

  // OK
  let url = URL.valid("https://www.ponylang.io/")

  // Not OK
  class JsonDoc
  ```

- The file name of Pony source files should be based on the name of the *principal type* defined in that file.
  - The *principal type* in a file is the type that makes up the bulk of the significant lines of code in the file or is conceptually more important or fundamental than all other types in the file. For example, if a file defines a trait type and a group of small class types that all provide that trait, then the trait type should be considered the *principal type*.
  - If there are multiple types defined in the file which all have equal significance and a shared name prefix, then the shared prefix should be used as the *principal type name*. For example, a file that defines `PacketFoo`, `PacketBar`, and `PacketBaz` types should use `Packet` as the *principal type name*, even if no `Packet` type is defined.
  - If there are multiple significant types defined in the file which do not have a shared name prefix, then this should be taken as a hint that these types should probably be defined in separate files instead of together in one file.

- The *file name* should be directly derived from the *principal type name* using a consistent reproducible scheme of case conversion.
  - The *file name* should be the "snake case" version of the *principal type name*. That is, each word in the *principal type name* (as defined by transitions from lowercase to uppercase letters) should be separated with the underscore character (`_`) and lowercased to generate the *file name*. For example, a file that defines the `ContentsLog` type should be named `contents_log.pony`.
  - If the *principal type* is a private type (its name beginning with an underscore character), then the *file name* should also be prefixed with an underscore character to highlight the fact that it defines a private type. For example, a file that defines the `_ClientConnection` type should be named `_client_connection.pony`.
  - If the *principal type* name contains an initialism (a sequence of uppercase letters with no lowercase letters between them), then the entire initialism should be considered as a single word when converting to snake case. Note that if there is another word following the initialism, its first letter will also be uppercase, but should not be considered part of the sequence of uppercase letters that form the initialism. For example, a file that defines the `SSLContext` type should be named `ssl_context.pony`.

- A Pony package name is derived from the name of the directory which contains its source files. Package names, and therefore the corresponding directory names, should use `snake_case`.

## Documentation

### Public Functions and Types

Public functions and types must include a triple-quoted docstring unless it is self-explanatory to anyone with the most basic knowledge of the domain. Markdown is used for formatting. The `"""` tokens are placed on their own lines, even when the entire docstring could fit on a single line with the `"""` tokens.

```pony
primitive Format
  """
  Provides functions for generating formatted strings.
  * fmt. Format to use.
  * prefix. Prefix to use.
  * prec. Precision to use. The exact meaning of this depends on the type,
  but is generally the number of characters used for all, or part, of the
  string. A value of -1 indicates that the default for the type should be
  used.
  * width. The minimum number of characters that will be in the produced
  string. If necessary the string will be padded with the fill character to
  make it long enough.
  * align. Specify whether fill characters should be added at the beginning or
  end of the generated string, or both.
  * fill: The character to pad a string with if is is shorter than width.
  """
```

### Package-level documentation

Package-level documentation should be placed in a file called `<PACKAGE>.pony` within a triple-quoted docstring at the top of the file. This same file may contain additional content if such organization makes sense for the package.

## Comments

Single line comments will have exactly one space between the `//` token and the beginning of the comment message. This single space may only be omitted if the comment only contains valid Pony code. Single line comments that continue a previous comment have the same spacing requirements. No such restrictions are placed on multiline comments between the `/*` and `*/` tokens.

```pony
// if `data` is 1 cacheline or less in size
// copy it into the existing `_current` array
// to coalesce multiple tiny arrays
// into a single bigger array
```

## Testing

### Ordering

Tests should be ordered alphabetically (within reason) separated into sections based on platform inclusion/exclusion criteria. First, list tests that run on all platforms, next list tests which include/exclude one platform, and lastly list tests which include/exclude multiple platforms. Sections should have an increasing number of inclusions/exclusions therefore if you have a section including only one platform, the next section should be tests excluding only that platform. When considering multiple platforms, list them alphabetically between sections and within sections. The set of known platforms recognized by `ifdef` can be found in `Platform` within `builtin`.

```pony
actor Main is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    // Tests below include all systems and are listed alphabetically
    test(_TestOnAllSystemsA)
    test(_TestOnAllSystemsB)
    test(_TestOnAllSystemsC)

    // Tests below include only bsd and are listed alphabetically
    ifdef bsd then
      test(_TestOnBsdA)
      test(_TestOnBsdB)
      test(_TestOnBsdC)
    end

    // Tests below exclude bsd and are listed alphabetically
    ifdef not bsd then
      test(_TestOnAllSystemsExceptBsdA)
      test(_TestOnAllSystemsExceptBsdB)
      test(_TestOnAllSystemsExceptBsdC)
    end

    // Tests below include only osx and are listed alphabetically
    ifdef osx then
      test(_TestOnOsxA)
      test(_TestOnOsxB)
      test(_TestOnOsxC)
    end

    // Tests below exclude osx and are listed alphabetically
    ifdef not osx then
      test(_TestOnAllSystemsExceptOsxA)
      test(_TestOnAllSystemsExceptOsxB)
      test(_TestOnAllSystemsExceptOsxC)
    end

    // Tests below include only windows and are listed alphabetically
    ifdef windows then
      test(_TestOnWindowsA)
      test(_TestOnWindowsB)
      test(_TestOnWindowsC)
    end

    // Tests below exclude windows and are listed alphabetically
    ifdef not windows then
      test(_TestOnAllSystemsExceptWindowsA)
      test(_TestOnAllSystemsExceptWindowsB)
      test(_TestOnAllSystemsExceptWindowsC)
    end

    // Tests below exclude bsd/windows and are listed alphabetically
    ifdef not bsd or not windows then
      test(_TestOnAllSystemsExceptBsdOrWindowsA)
      test(_TestOnAllSystemsExceptBsdOrWindowsB)
      test(_TestOnAllSystemsExceptBsdOrWindowsC)
    end

    // Tests below exclude osx/windows and are listed alphabetically
    ifdef not osx or not windows then
      test(_TestOnAllSystemsExceptOsxOrWindowsA)
      test(_TestOnAllSystemsExceptOsxOrWindowsB)
      test(_TestOnAllSystemsExceptOsxOrWindowsC)
    end

    // Tests below exclude bsd/osx/windows and are listed alphabetically
    ifdef not bsd or not osx or not windows then
      test(_TestOnAllSystemsExceptBsdOrOsxOrWindowsA)
      test(_TestOnAllSystemsExceptBsdOrOsxOrWindowsB)
      test(_TestOnAllSystemsExceptBsdOrOsxOrWindowsC)
    end
```

It can sometimes make more sense to not use alphabetical ordering -- such as when using a generic test builder -- in such circumstances breaking alphabetical ordering is allowed.

```pony
actor Main is TestList
  new create(env: Env) => PonyTest(env, this)
  new make() => None

  fun tag tests(test: PonyTest) =>
    // Tests below include all systems and are listed in increasing type argument size
    test(_TestOnAllSystemsWithBuilder[U8]())
    test(_TestOnAllSystemsWithBuilder[U16]())
    test(_TestOnAllSystemsWithBuilder[U32]())
    test(_TestOnAllSystemsWithBuilder[U64]())
    test(_TestOnAllSystemsWithBuilder[U128]())
```
