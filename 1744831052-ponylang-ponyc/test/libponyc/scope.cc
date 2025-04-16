#include <gtest/gtest.h>
#include <platform.h>

#include <ast/ast.h>
#include <pass/scope.h>
#include <ast/stringtab.h>
#include <pass/pass.h>
#include <pkg/package.h>
#include <pkg/use.h>

#include "util.h"


#define TEST_COMPILE(src) DO(test_compile(src, "scope"))
#define TEST_ERROR(src) DO(test_error(src, "scope"))


class ScopeTest : public PassTest
{};


TEST_F(ScopeTest, Actor)
{
  const char* src = "actor Foo";

  TEST_COMPILE(src);

  ASSERT_ID(TK_ACTOR, lookup_type("Foo"));
  ASSERT_EQ(1, ref_count(package, "Foo"));
}


TEST_F(ScopeTest, Class)
{
  const char* src = "class Foo";

  TEST_COMPILE(src);

  ASSERT_ID(TK_CLASS, lookup_type("Foo"));
  ASSERT_EQ(1, ref_count(package, "Foo"));
}


TEST_F(ScopeTest, Primitive)
{
  const char* src = "primitive Foo";

  TEST_COMPILE(src);

  ASSERT_ID(TK_PRIMITIVE, lookup_type("Foo"));
  ASSERT_EQ(1, ref_count(package, "Foo"));
}


TEST_F(ScopeTest, Trait)
{
  const char* src = "trait Foo";

  TEST_COMPILE(src);

  ASSERT_ID(TK_TRAIT, lookup_type("Foo"));
  ASSERT_EQ(1, ref_count(package, "Foo"));
}


TEST_F(ScopeTest, Interface)
{
  const char* src = "interface Foo";

  TEST_COMPILE(src);

  ASSERT_ID(TK_INTERFACE, lookup_type("Foo"));
  ASSERT_EQ(1, ref_count(package, "Foo"));
}


TEST_F(ScopeTest, TypeAlias)
{
  const char* src = "type Foo is Bar";

  TEST_COMPILE(src);

  ASSERT_ID(TK_TYPE, lookup_type("Foo"));
  ASSERT_EQ(1, ref_count(package, "Foo"));
}


TEST_F(ScopeTest, VarField)
{
  const char* src = "class C var foo: U32";

  TEST_COMPILE(src);

  ASSERT_ID(TK_FVAR, lookup_member("C", "foo"));
  ASSERT_EQ(1, ref_count(package, "foo"));
}


TEST_F(ScopeTest, LetField)
{
  const char* src = "class C let foo: U32";

  TEST_COMPILE(src);

  ASSERT_ID(TK_FLET, lookup_member("C", "foo"));
  ASSERT_EQ(1, ref_count(package, "foo"));
}


TEST_F(ScopeTest, Be)
{
  const char* src = "actor A be foo() => None";

  TEST_COMPILE(src);

  ASSERT_ID(TK_BE, lookup_member("A", "foo"));
  ASSERT_EQ(1, ref_count(package, "foo"));
}


TEST_F(ScopeTest, New)
{
  const char* src = "actor A new foo() => None";

  TEST_COMPILE(src);

  ASSERT_ID(TK_NEW, lookup_member("A", "foo"));
  ASSERT_EQ(1, ref_count(package, "foo"));
}


TEST_F(ScopeTest, Fun)
{
  const char* src = "actor A fun foo() => None";

  TEST_COMPILE(src);

  ASSERT_ID(TK_FUN, lookup_member("A", "foo"));
  ASSERT_EQ(1, ref_count(package, "foo"));
}


TEST_F(ScopeTest, FunParam)
{
  const char* src = "actor A fun foo(bar: U32) => None";

  TEST_COMPILE(src);

  ast_t* foo = lookup_member("A", "foo");
  ASSERT_ID(TK_FUN, foo);
  ASSERT_ID(TK_PARAM, lookup_in(foo, "bar"));
  ASSERT_EQ(1, ref_count(package, "bar"));
}


TEST_F(ScopeTest, TypeParam)
{
  const char* src = "actor A fun foo[T]() => None";

  TEST_COMPILE(src);

  ast_t* foo = lookup_member("A", "foo");
  ASSERT_ID(TK_FUN, foo);
  ASSERT_ID(TK_TYPEPARAM, lookup_in(foo, "T"));
  ASSERT_EQ(1, ref_count(package, "T"));
}


TEST_F(ScopeTest, Local)
{
  const char* src = "actor A fun foo() => var bar: U32 = 3";

  TEST_COMPILE(src);

  ast_t* foo = lookup_member("A", "foo");
  ASSERT_ID(TK_FUN, foo);
  ASSERT_ID(TK_VAR, lookup_in(foo, "bar"));
  ASSERT_EQ(1, ref_count(package, "bar"));
}


TEST_F(ScopeTest, MultipleLocals)
{
  const char* src =
    "actor A\n"
    "  fun wombat() =>\n"
    "    (var foo: Type1, var bar: Type2, let aardvark: Type3)";

  TEST_COMPILE(src);

  ast_t* wombat = lookup_member("A", "wombat");
  ASSERT_ID(TK_FUN, wombat);

  ASSERT_ID(TK_VAR, lookup_in(wombat, "foo"));
  ASSERT_ID(TK_VAR, lookup_in(wombat, "bar"));
  ASSERT_ID(TK_LET, lookup_in(wombat, "aardvark"));

  ASSERT_EQ(1, ref_count(package, "foo"));
  ASSERT_EQ(1, ref_count(package, "bar"));
  ASSERT_EQ(1, ref_count(package, "aardvark"));
}


TEST_F(ScopeTest, NestedLocals)
{
  const char* src =
    "actor A\n"
    "  fun wombat() =>"
    "    (var foo: Type1, (var bar: Type2, let aardvark: Type3))";

  TEST_COMPILE(src);

  ast_t* wombat = lookup_member("A", "wombat");
  ASSERT_ID(TK_FUN, wombat);

  ASSERT_ID(TK_VAR, lookup_in(wombat, "foo"));
  ASSERT_ID(TK_VAR, lookup_in(wombat, "bar"));
  ASSERT_ID(TK_LET, lookup_in(wombat, "aardvark"));

  ASSERT_EQ(1, ref_count(package, "foo"));
  ASSERT_EQ(1, ref_count(package, "bar"));
  ASSERT_EQ(1, ref_count(package, "aardvark"));
}


TEST_F(ScopeTest, SameScopeNameClash)
{
  const char* src1 =
    "actor A\n"
    "  fun foo() =>\n"
    "    var bar1: U32 = 3\n"
    "    var bar2: U32 = 4";

  TEST_COMPILE(src1);

  const char* src2 =
    "actor A\n"
    "  fun foo() =>\n"
    "    var bar: U32 = 3\n"
    "    var bar: U32 = 4";

  TEST_ERROR(src2);
}


TEST_F(ScopeTest, ParentScopeNameClash)
{
  const char* src1 =
    "actor A\n"
    "  fun foo(foo2:U32) => 3";

  TEST_COMPILE(src1);

  const char* src2 =
    "actor A\n"
    "  fun foo(foo:U32) => 3";

  TEST_ERROR(src2);
}


TEST_F(ScopeTest, SiblingScopeNoClash)
{
  const char* src =
    "actor A1\n"
    "  fun foo(foo2:U32) => 3\n"
    "actor A2\n"
    "  fun foo(foo2:U32) => 3";

  TEST_COMPILE(src);
}


TEST_F(ScopeTest, Package)
{
  const char* src = "actor A";

  DO(test_compile(src, "import"));

  // Builtin types go in the module symbol table
  ASSERT_ID(TK_PRIMITIVE, lookup_in(module, "U32"));
  ASSERT_EQ(1, ref_count(package, "U32"));
}


TEST_F(ScopeTest, CanShadowDontcare)
{
  const char* src =
    "actor A\n"
    "  fun foo() =>\n"
    "    var _: None\n"
    "    var _: None";

  TEST_COMPILE(src);
}


TEST_F(ScopeTest, MethodOverloading)
{
  const char* src =
    "actor A\n"
    "  fun foo() => None\n"
    "  fun foo(a: None) => None";

  TEST_ERROR(src);
}


/*
TEST_F(ScopeTest, Use)
{
  const char* src =
    "use \n"
    "actor A";

  TEST_COMPILE(src);

  // Builtin types go in the module symbol table
  WALK_TREE(module);
  LOOKUP("U32", TK_PRIMITIVE);

  ASSERT_EQ(1, ref_count(package, "U32"));
}


TEST_F(ScopeTest, Use)
{
  const char* tree =
    "(program{scope} (package{scope} (module{scope}"
    "  (use{def start} x \"test\" x))))";

  const char* used_package =
    "class Foo";

  package_add_magic("test", used_package);

  DO(build(tree));
  ASSERT_EQ(AST_OK, run_scope());

  // Use imported types go in the module symbol table
  ast_t* module = find_sub_tree(ast, TK_MODULE);
  symtab_t* module_symtab = ast_get_symtab(module);
  ASSERT_NE((void*)NULL, symtab_find(module_symtab, stringtab("Foo"), NULL));
}


TEST_F(ScopeTest, UseAs)
{
  const char* tree =
    "(program{scope} (package{scope} (module{scope}"
    "  (use{def start} (id bar) \"test\" x))))";

  const char* used_package =
    "class Foo";

  package_add_magic("test", used_package);

  DO(build(tree));
  ASSERT_EQ(AST_OK, run_scope());

  // Use imported types go in the module symbol table
  ast_t* module = find_sub_tree(ast, TK_MODULE);
  symtab_t* module_symtab = ast_get_symtab(module);
  ASSERT_NE((void*)NULL, symtab_find(module_symtab, stringtab("bar"), NULL));
  ASSERT_EQ((void*)NULL, symtab_find(module_symtab, stringtab("Foo"), NULL));
}


TEST_F(ScopeTest, UseConditionTrue)
{
  const char* tree =
    "(program{scope} (package{scope} (module{scope}"
    "  (use x \"test\" (reference (id debug))))))";

  const char* used_package =
    "class Foo";

  package_add_magic("test", used_package);

  DO(build(tree));
  ASSERT_EQ(AST_OK, run_scope());

  // Use imported types go in the module symbol table
  ast_t* module = find_sub_tree(ast, TK_MODULE);
  symtab_t* module_symtab = ast_get_symtab(module);
  ASSERT_NE((void*)NULL, symtab_find(module_symtab, stringtab("Foo"), NULL));
}


TEST_F(ScopeTest, UseConditionFalse)
{
  const char* tree =
    "(program{scope} (package{scope} (module{scope}"
    "  (use x \"test\" (call x x (. (reference (id debug)) (id op_not)))))))";

  const char* used_package =
    "class Foo";

  package_add_magic("test", used_package);

  DO(build(tree));
  ASSERT_EQ(AST_OK, run_scope());

  // Nothing should be imported
  ast_t* module = find_sub_tree(ast, TK_MODULE);
  symtab_t* module_symtab = ast_get_symtab(module);
  ASSERT_EQ((void*)NULL, symtab_find(module_symtab, stringtab("Foo"), NULL));
}
*/
