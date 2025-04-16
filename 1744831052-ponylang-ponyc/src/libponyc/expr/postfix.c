#include "postfix.h"
#include "reference.h"
#include "literal.h"
#include "call.h"
#include "../ast/id.h"
#include "../pkg/package.h"
#include "../pass/expr.h"
#include "../pass/names.h"
#include "../type/alias.h"
#include "../type/reify.h"
#include "../type/assemble.h"
#include "../type/lookup.h"
#include "ponyassert.h"
#include <string.h>
#include <stdlib.h>

static bool is_method_called(pass_opt_t* opt, ast_t* ast)
{
  ast_t* parent = ast_parent(ast);

  switch(ast_id(parent))
  {
    case TK_QUALIFY:
      return is_method_called(opt, parent);

    case TK_CALL:
    case TK_ADDRESS:
      return true;

    default: {}
  }

  ast_error(opt->check.errors, ast,
    "can't reference a method without calling it");
  return false;
}

static bool constructor_type(pass_opt_t* opt, ast_t* ast, token_id cap,
  ast_t* type, ast_t** resultp)
{
  switch(ast_id(type))
  {
    case TK_NOMINAL:
    {
      ast_t* def = (ast_t*)ast_data(type);

      switch(ast_id(def))
      {
        case TK_PRIMITIVE:
        case TK_STRUCT:
        case TK_CLASS:
          ast_setid(ast, TK_NEWREF);
          break;

        case TK_ACTOR:
          ast_setid(ast, TK_NEWBEREF);
          break;

        case TK_TYPE:
          ast_error(opt->check.errors, ast,
            "can't call a constructor on a type alias: %s",
            ast_print_type(type));
          return false;

        case TK_INTERFACE:
          ast_error(opt->check.errors, ast,
            "can't call a constructor on an interface: %s",
            ast_print_type(type));
          return false;

        case TK_TRAIT:
          ast_error(opt->check.errors, ast,
            "can't call a constructor on a trait: %s",
            ast_print_type(type));
          return false;

        default:
          pony_assert(0);
          return false;
      }
      return true;
    }

    case TK_TYPEPARAMREF:
    {
      // Alter the return type of the method.
      type = ast_dup(type);

      AST_GET_CHILDREN(type, tid, tcap, teph);
      ast_setid(tcap, cap);
      ast_setid(teph, TK_EPHEMERAL);
      ast_replace(resultp, type);

      // This could this be an actor.
      ast_setid(ast, TK_NEWBEREF);
      return true;
    }

    case TK_ARROW:
    {
      AST_GET_CHILDREN(type, left, right);
      return constructor_type(opt, ast, cap, right, resultp);
    }

    case TK_UNIONTYPE:
    {
      ast_error(opt->check.errors, ast,
        "can't call a constructor on a type union: %s",
        ast_print_type(type));
      return false;
    }

    case TK_ISECTTYPE:
    {
      ast_error(opt->check.errors, ast,
        "can't call a constructor on a type intersection: %s",
        ast_print_type(type));
      return false;
    }

    default: {}
  }

  pony_assert(0);
  return false;
}

static bool method_access(pass_opt_t* opt, ast_t* ast, ast_t* method)
{
  AST_GET_CHILDREN(method, cap, id, typeparams, params, result);

  switch(ast_id(method))
  {
    case TK_NEW:
    {
      AST_GET_CHILDREN(ast, left, right);
      ast_t* type = ast_type(left);

      if(is_typecheck_error(type))
        return false;

      if(!constructor_type(opt, ast, ast_id(cap), type, &result))
        return false;

      break;
    }

    case TK_BE:
      ast_setid(ast, TK_BEREF);
      break;

    case TK_FUN:
      ast_setid(ast, TK_FUNREF);
      break;

    default:
      pony_assert(0);
      return false;
  }

  ast_settype(ast, type_for_fun(method));

  return is_method_called(opt, ast);
}

static bool type_access(pass_opt_t* opt, ast_t** astp)
{
  ast_t* ast = *astp;

  // Left is a typeref, right is an id.
  ast_t* left = ast_child(ast);
  ast_t* right = ast_sibling(left);
  ast_t* type = ast_type(left);

  if(is_typecheck_error(type))
    return false;

  pony_assert(ast_id(left) == TK_TYPEREF);
  pony_assert(ast_id(right) == TK_ID);

  deferred_reification_t* find = lookup(opt, ast, type, ast_name(right));

  if(find == NULL)
    return false;

  ast_t* r_find = find->ast;

  switch(ast_id(r_find))
  {
    case TK_FUN:
      if(ast_id(ast_child(r_find)) != TK_AT)
        break;
      //fallthrough

    case TK_NEW:
      r_find = deferred_reify_method_def(find, r_find, opt);
      break;

    default:
      break;
  }

  bool ret = true;

  switch(ast_id(r_find))
  {
    case TK_TYPEPARAM:
      ast_error(opt->check.errors, right,
        "can't look up a typeparam on a type");
      ret = false;
      break;

    case TK_NEW:
      ret = method_access(opt, ast, r_find);
      break;

    case TK_FUN:
      if(ast_id(ast_child(r_find)) == TK_AT)
      {
        ret = method_access(opt, ast, r_find);
        break;
      }
      //fallthrough

    case TK_FVAR:
    case TK_FLET:
    case TK_EMBED:
    case TK_BE:
    {
      // Make this a lookup on a default constructed object.
      if(!strcmp(ast_name(right), "create"))
      {
        ast_error(opt->check.errors, right,
          "create is not a constructor on this type");
        return false;
      }

      ast_t* dot = ast_from(ast, TK_DOT);
      ast_add(dot, ast_from_string(ast, "create"));
      ast_swap(left, dot);
      ast_add(dot, left);

      ast_t* call = ast_from(ast, TK_CALL);
      ast_swap(dot, call);
      ast_add(call, ast_from(ast, TK_NONE)); // question
      ast_add(call, ast_from(ast, TK_NONE)); // named
      ast_add(call, ast_from(ast, TK_NONE)); // positional
      ast_add(call, dot);

      if(!expr_dot(opt, &dot))
        return false;

      if(!expr_call(opt, &call))
        return false;

      ret = expr_dot(opt, astp);
      break;
    }

    default:
      pony_assert(0);
      ret = false;
      break;
  }

  if(r_find != find->ast)
    ast_free_unattached(r_find);

  deferred_reify_free(find);
  return ret;
}

static bool make_tuple_index(ast_t** astp)
{
  ast_t* ast = *astp;
  const char* name = ast_name(ast);

  if(!is_name_private(name))
    return false;

  for(size_t i = 1; name[i] != '\0'; i++)
  {
    if((name[i] < '0') || (name[i] > '9'))
      return false;
  }

  size_t index = strtol(&name[1], NULL, 10) - 1;
  ast_t* node = ast_from_int(ast, index);
  ast_replace(astp, node);

  return true;
}

static bool tuple_access(pass_opt_t* opt, ast_t* ast)
{
  // Left is a postfix expression, right is a lookup name.
  ast_t* left = ast_child(ast);
  ast_t* right = ast_sibling(left);
  ast_t* type = ast_type(left);

  if(is_typecheck_error(type))
    return false;

  // Change the lookup name to an integer index.
  if(!make_tuple_index(&right))
  {
    ast_error(opt->check.errors, right,
      "lookup on a tuple must take the form _X, where X is an integer");
    return false;
  }

  // Make sure our index is in bounds.  make_tuple_index automatically shifts
  // from one indexed to zero, so we have to use -1 and >= for our comparisons.
  size_t right_idx = (size_t)ast_int(right)->low;
  size_t tuple_size = ast_childcount(type);

  if (right_idx == (size_t)-1)
  {
    ast_error(opt->check.errors, right,
      "tuples are one indexed not zero indexed. Did you mean _1?");
    return false;
  }
  else if (right_idx >= tuple_size)
  {
    ast_error(opt->check.errors, right, "tuple index " __zu " is out of "
      "valid range. Valid range is [1, " __zu "]", right_idx, tuple_size);
    return false;
  }

  type = ast_childidx(type, right_idx);
  pony_assert(type != NULL);

  ast_setid(ast, TK_TUPLEELEMREF);
  ast_settype(ast, type);
  return true;
}

static bool member_access(pass_opt_t* opt, ast_t* ast)
{
  // Left is a postfix expression, right is an id.
  AST_GET_CHILDREN(ast, left, right);
  pony_assert(ast_id(right) == TK_ID);
  ast_t* type = ast_type(left);

  if(is_typecheck_error(type))
    return false;

  deferred_reification_t* find = lookup(opt, ast, type, ast_name(right));

  if(find == NULL)
    return false;

  ast_t* r_find = find->ast;

  switch(ast_id(r_find))
  {
    case TK_FVAR:
    case TK_FLET:
    case TK_EMBED:
      r_find = deferred_reify(find, r_find, opt);
      break;

    case TK_NEW:
    case TK_BE:
    case TK_FUN:
      r_find = deferred_reify_method_def(find, r_find, opt);
      break;

    default:
      break;
  }

  bool ret = true;

  switch(ast_id(r_find))
  {
    case TK_TYPEPARAM:
      ast_error(opt->check.errors, right,
        "can't look up a typeparam on an expression");
      ret = false;
      break;

    case TK_FVAR:
      if(!expr_fieldref(opt, ast, r_find, TK_FVARREF))
        return false;
      break;

    case TK_FLET:
      if(!expr_fieldref(opt, ast, r_find, TK_FLETREF))
        return false;
      break;

    case TK_EMBED:
      if(!expr_fieldref(opt, ast, r_find, TK_EMBEDREF))
        return false;
      break;

    case TK_NEW:
    case TK_BE:
    case TK_FUN:
      ret = method_access(opt, ast, r_find);
      break;

    default:
      pony_assert(0);
      ret = false;
      break;
  }

  if(r_find != find->ast)
    ast_free_unattached(r_find);

  deferred_reify_free(find);

  return ret;
}

bool expr_qualify(pass_opt_t* opt, ast_t** astp)
{
  // Left is a postfix expression, right is a typeargs.
  // Qualified type references have already been handled in the refer pass,
  // so we know that this node should be treated like a qualified method call.
  ast_t* ast = *astp;
  pony_assert(ast_id(ast) == TK_QUALIFY);
  AST_GET_CHILDREN(ast, left, right);
  ast_t* type = ast_type(left);
  pony_assert(ast_id(right) == TK_TYPEARGS);

  if(is_typecheck_error(type))
    return false;

  switch(ast_id(left))
  {
    case TK_NEWREF:
    case TK_NEWBEREF:
    case TK_BEREF:
    case TK_FUNREF:
    case TK_NEWAPP:
    case TK_BEAPP:
    case TK_FUNAPP:
    case TK_BECHAIN:
    case TK_FUNCHAIN:
    {
      // Qualify the function.
      pony_assert(ast_id(type) == TK_FUNTYPE);
      ast_t* typeparams = ast_childidx(type, 1);

      if(!reify_defaults(typeparams, right, true, opt))
        return false;

      if(!check_constraints(left, typeparams, right, true, opt))
        return false;

      type = reify(type, typeparams, right, opt, true);
      typeparams = ast_childidx(type, 1);
      ast_replace(&typeparams, ast_from(typeparams, TK_NONE));

      ast_settype(ast, type);
      ast_setid(ast, ast_id(left));
      return true;
    }

    default: {}
  }

  // Otherwise, sugar as qualified call to .apply()
  ast_t* dot = ast_from(left, TK_DOT);
  ast_add(dot, ast_from_string(left, "apply"));
  ast_swap(left, dot);
  ast_add(dot, left);

  if(!expr_dot(opt, &dot))
    return false;

  return expr_qualify(opt, astp);
}

static bool entity_access(pass_opt_t* opt, ast_t** astp)
{
  ast_t* ast = *astp;

  // Left is a postfix expression, right is an id.
  ast_t* left = ast_child(ast);

  switch(ast_id(left))
  {
    case TK_TYPEREF:
      return type_access(opt, astp);

    default: {}
  }

  ast_t* type = ast_type(left);

  if(type == NULL)
    return false;

  if(!literal_member_access(ast, opt))
    return false;

  // Type already set by literal handler
  if(ast_type(ast) != NULL)
    return true;

  type = ast_type(left); // Literal handling may have changed lhs type
  pony_assert(type != NULL);

  if(ast_id(type) == TK_TUPLETYPE)
    return tuple_access(opt, ast);

  return member_access(opt, ast);
}

bool expr_dot(pass_opt_t* opt, ast_t** astp)
{
  return entity_access(opt, astp);
}

bool expr_tilde(pass_opt_t* opt, ast_t** astp)
{
  if(!entity_access(opt, astp))
    return false;

  ast_t* ast = *astp;

  if(ast_id(ast) == TK_TILDE && ast_type(ast) != NULL &&
    ast_id(ast_type(ast)) == TK_OPERATORLITERAL)
  {
    ast_error(opt->check.errors, ast,
      "can't do partial application on a literal number");
    return false;
  }

  switch(ast_id(ast))
  {
    case TK_NEWREF:
    case TK_NEWBEREF:
      ast_setid(ast, TK_NEWAPP);
      return true;

    case TK_BEREF:
      ast_setid(ast, TK_BEAPP);
      return true;

    case TK_FUNREF:
      ast_setid(ast, TK_FUNAPP);
      return true;

    case TK_TYPEREF:
      ast_error(opt->check.errors, ast,
        "can't do partial application on a package");
      return false;

    case TK_FVARREF:
    case TK_FLETREF:
    case TK_EMBEDREF:
      ast_error(opt->check.errors, ast,
        "can't do partial application of a field");
      return false;

    case TK_TUPLEELEMREF:
      ast_error(opt->check.errors, ast,
        "can't do partial application of a tuple element");
      return false;

    default: {}
  }

  pony_assert(0);
  return false;
}

bool expr_chain(pass_opt_t* opt, ast_t** astp)
{
  if(!entity_access(opt, astp))
    return false;

  ast_t* ast = *astp;

  switch(ast_id(ast))
  {
    case TK_BEREF:
      ast_setid(ast, TK_BECHAIN);
      return true;

    case TK_FUNREF:
      ast_setid(ast, TK_FUNCHAIN);
      return true;

    case TK_NEWREF:
    case TK_NEWBEREF:
      ast_error(opt->check.errors, ast,
        "can't do method chaining on a constructor");
      return false;

    case TK_TYPEREF:
      ast_error(opt->check.errors, ast,
        "can't do method chaining on a package");
      return false;

    case TK_FVARREF:
    case TK_FLETREF:
    case TK_EMBEDREF:
      ast_error(opt->check.errors, ast,
        "can't do method chaining on a field");
      return false;

    case TK_TUPLEELEMREF:
      ast_error(opt->check.errors, ast,
        "can't do method chaining on a tuple element");
      return false;

    default: {}
  }

  pony_assert(0);
  return false;
}
