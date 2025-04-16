#include <gtest/gtest.h>
#include <platform.h>

#include "util.h"


#define TEST_COMPILE(src) DO(test_compile(src, "verify"))

#define TEST_ERRORS_1(src, err1) \
  { const char* errs[] = {err1, NULL}; \
    DO(test_expected_errors(src, "verify", errs)); }


class DontcareTest : public PassTest
{};


TEST_F(DontcareTest, TypeCantBeDontcare)
{
  const char* src =
    "class C\n"
    "  let x: _";

  TEST_ERRORS_1(src, "can't use '_' as a type name");
}


TEST_F(DontcareTest, ComplexTypeCantBeDontcare)
{
  const char* src =
    "class C\n"
    "  let x: (_ | None)";

  TEST_ERRORS_1(src, "can't use '_' as a type name");
}


TEST_F(DontcareTest, CanAssignToDontcare)
{
  const char* src =
    "class C\n"
    "  fun f() =>\n"
    "    _ = None";

  TEST_COMPILE(src);
}


TEST_F(DontcareTest, CanAssignToDontcareDeclInfer)
{
  const char* src =
    "class C\n"
    "  fun f() =>\n"
    "    let _ = None";

  TEST_COMPILE(src);
}


TEST_F(DontcareTest, CanAssignToDontcareDeclWithType)
{
  const char* src =
    "class C\n"
    "  fun f() =>\n"
    "    let _: None = None";

  TEST_COMPILE(src);
}


TEST_F(DontcareTest, CannotAssignFromDontcare)
{
  const char* src =
    "class C\n"
    "  fun f() =>\n"
    "    let x = _";

  TEST_ERRORS_1(src, "can't read from '_'");
}


TEST_F(DontcareTest, CannotChainAssignDontcare)
{
  const char* src =
    "class C\n"
    "  fun f() =>\n"
    "    _ = _ = None";

  TEST_ERRORS_1(src, "can't read from '_'");
}


TEST_F(DontcareTest, CannotCallMethodOnDontcare)
{
  const char* src =
    "class C\n"
    "  fun f() =>\n"
    "    _.foo()";

  TEST_ERRORS_1(src, "can't read from '_'");
}


TEST_F(DontcareTest, CanUseDontcareNamedCapture)
{
  const char* src =
    "class C\n"
    "  fun f(x: None) =>\n"
    "    match x\n"
    "    | let _: None => None\n"
    "    end";

  TEST_COMPILE(src);
}


TEST_F(DontcareTest, CannotUseDontcareNamedCaptureNoType)
{
  const char* src =
    "class C\n"
    "  fun f(x: None) =>\n"
    "    match x\n"
    "    | let _ => None\n"
    "    end";

  TEST_ERRORS_1(src, "capture types cannot be inferred");
}


TEST_F(DontcareTest, CanUseDontcareInTupleLHS)
{
  const char* src =
    "class C\n"
    "  fun f(x: None) =>\n"
    "    (let a, _) = (None, None)";

  TEST_COMPILE(src);
}


TEST_F(DontcareTest, CannotUseDontcareInTupleRHS)
{
  const char* src =
    "class C\n"
    "  fun f(x: None) =>\n"
    "    (let a, let b) = (None, _)";

  TEST_ERRORS_1(src, "can't read from '_'");
}


TEST_F(DontcareTest, CannotUseDontcareAsArgumentInCaseExpression)
{
  // From issue #1922
  const char* src =
    "class C\n"
    "  new create(i: U32) => None\n"
    "  fun eq(that: C): Bool => false\n"

    "primitive Foo\n"
    "  fun apply(c: (C | None)) =>\n"
    "    match c\n"
    "    | C(_) => None\n"
    "    end";

  TEST_ERRORS_1(src, "can't read from '_'");
}


TEST_F(DontcareTest, CannotUseDontcareAsFunctionArgument)
{
  const char* src =
    "class C\n"
    "  fun f(x: U8) =>\n"
    "    f(_)";

  TEST_ERRORS_1(src, "can't read from '_'");
}

TEST_F(DontcareTest, CannotUseDontcareInCaseExpression)
{
  const char* src =
    "class C\n"
    "  fun c_ase(x: (I32 | None)): I32 =>\n"
    "    match x\n"
    "      | let x1: I32 => x1\n"
    "      | _ => 42\n"
    "    end";
  TEST_ERRORS_1(src, "can't have a case with `_` only, use an else clause");
}
