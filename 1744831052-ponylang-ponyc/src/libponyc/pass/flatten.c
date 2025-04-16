#include "flatten.h"
#include "../type/alias.h"
#include "../type/assemble.h"
#include "../type/cap.h"
#include "../type/compattype.h"
#include "../type/subtype.h"
#include "../type/typeparam.h"
#include "../type/viewpoint.h"
#include "ponyassert.h"

static void flatten_typeexpr_element(ast_t* type, ast_t* elem, token_id id)
{
  if(ast_id(elem) != id)
  {
    ast_append(type, elem);
    return;
  }

  ast_t* child = ast_child(elem);

  while(child != NULL)
  {
    ast_append(type, child);
    child = ast_sibling(child);
  }

  ast_free_unattached(elem);
}

static ast_result_t flatten_union(pass_opt_t* opt, ast_t* ast)
{
  (void)opt;
  // Flatten unions without testing subtyping. This will be tested after the
  // traits pass, when we have full subtyping information.
  // If there are more than 2 children, this has already been flattened.
  if(ast_childcount(ast) > 2)
    return AST_OK;

  AST_EXTRACT_CHILDREN(ast, left, right);

  flatten_typeexpr_element(ast, left, TK_UNIONTYPE);
  flatten_typeexpr_element(ast, right, TK_UNIONTYPE);

  return AST_OK;
}

static ast_result_t flatten_isect(pass_opt_t* opt, ast_t* ast)
{
  (void)opt;
  // Flatten intersections without testing subtyping. This is to preserve any
  // type guarantees that an element in the intersection might make.
  // If there are more than 2 children, this has already been flattened.
  if(ast_childcount(ast) > 2)
    return AST_OK;

  AST_EXTRACT_CHILDREN(ast, left, right);
  flatten_typeexpr_element(ast, left, TK_ISECTTYPE);
  flatten_typeexpr_element(ast, right, TK_ISECTTYPE);

  return AST_OK;
}

bool constraint_contains_tuple(pass_opt_t* opt, ast_t* constraint, ast_t* scan)
{
  switch(ast_id(scan))
  {
    case TK_TUPLETYPE:
    {
      return true;
    }

    case TK_UNIONTYPE:
    {
      bool r = false;

      ast_t* child = ast_child(constraint);
      child = ast_sibling(child);

      while(child != NULL)
      {
        if(constraint_contains_tuple(opt, constraint, child))
          r = true;
        child = ast_sibling(child);
      }

      return r;
    }

    default: {}
  }

  return false;
}

ast_result_t flatten_typeparamref(pass_opt_t* opt, ast_t* ast)
{
  ast_t* cap_ast = cap_fetch(ast);
  token_id cap = ast_id(cap_ast);

  // It is possible that we have an illegal constraint using a tuple here.
  // It can happen due to an ordering of passes. We check for tuples in
  // constraints in syntax but if the tuple constraint is part of a type
  // alias, we don't see that tuple until we are in flatten.
  //
  // For example:
  //
  // type Blocksize is (U8, U32)
  // class Block[T: Blocksize]
  //
  // or
  //
  // type Blocksize is (None | (U8, U32))
  // class Block[T: Blocksize]
  //
  // We handle that case here with the an error message that is similar to
  // the one used in syntax.
  ast_t* constraint = typeparam_constraint(ast);
  if(constraint != NULL
    && constraint_contains_tuple(opt, constraint, constraint))
  {
    ast_error(opt->check.errors, constraint,
      "constraint contains a tuple; tuple types can't be used as type constraints");
    return AST_ERROR;
  }

  typeparam_set_cap(ast);

  token_id set_cap = ast_id(cap_ast);

  if((cap != TK_NONE) && (cap != set_cap))
  {
    ast_t* def = (ast_t*)ast_data(ast);
    ast_t* constraint = typeparam_constraint(ast);

    if(constraint != NULL)
    {
      ast_error(opt->check.errors, cap_ast, "can't specify a capability on a "
        "type parameter that differs from the constraint");
      ast_error_continue(opt->check.errors, constraint,
        "constraint definition is here");

      if(ast_parent(constraint) != def)
      {
        ast_error_continue(opt->check.errors, def,
          "type parameter definition is here");
      }
    } else {
      ast_error(opt->check.errors, cap_ast, "a type parameter with no "
        "constraint can only have #any as its capability");
      ast_error_continue(opt->check.errors, def,
        "type parameter definition is here");
    }

    return AST_ERROR;
  }

  return AST_OK;
}

static ast_result_t flatten_sendable_params(pass_opt_t* opt, ast_t* params)
{
  ast_t* param = ast_child(params);
  ast_result_t r = AST_OK;

  while(param != NULL)
  {
    AST_GET_CHILDREN(param, id, type, def);

    if(!sendable(type))
    {
      ast_error(opt->check.errors, param,
        "this parameter must be sendable (iso, val or tag)");
      r = AST_ERROR;
    }

    param = ast_sibling(param);
  }

  return r;
}

static ast_result_t flatten_constructor(pass_opt_t* opt, ast_t* ast)
{
  AST_GET_CHILDREN(ast, cap, id, typeparams, params, result, can_error, body,
    docstring);

  switch(ast_id(cap))
  {
    case TK_ISO:
    case TK_TRN:
    case TK_VAL:
      return flatten_sendable_params(opt, params);

    default: {}
  }

  return AST_OK;
}

static ast_result_t flatten_async(pass_opt_t* opt, ast_t* ast)
{
  AST_GET_CHILDREN(ast, cap, id, typeparams, params, result, can_error, body,
    docstring);

  return flatten_sendable_params(opt, params);
}

static ast_result_t flatten_arrow(pass_opt_t* opt, ast_t** astp)
{
  AST_GET_CHILDREN(*astp, left, right);

  switch(ast_id(left))
  {
    case TK_ISO:
    case TK_TRN:
    case TK_REF:
    case TK_VAL:
    case TK_BOX:
    case TK_TAG:
    case TK_THISTYPE:
    case TK_TYPEPARAMREF:
    {
      ast_t* r_ast = viewpoint_type(left, right);
      ast_replace(astp, r_ast);
      return AST_OK;
    }

    default: {}
  }

  ast_error(opt->check.errors, left,
    "only 'this', refcaps, and type parameters can be viewpoints");
  return AST_ERROR;
}

// Process the given provides type
static bool flatten_provided_type(pass_opt_t* opt, ast_t* provides_type,
  ast_t* error_at, ast_t* list_parent, ast_t** list_end)
{
  pony_assert(error_at != NULL);
  pony_assert(provides_type != NULL);
  pony_assert(list_parent != NULL);
  pony_assert(list_end != NULL);

  switch(ast_id(provides_type))
  {
    case TK_PROVIDES:
    case TK_ISECTTYPE:
      // Flatten all children
      for(ast_t* p = ast_child(provides_type); p != NULL; p = ast_sibling(p))
      {
        if(!flatten_provided_type(opt, p, error_at, list_parent, list_end))
          return false;
      }

      return true;

    case TK_NOMINAL:
    {
      // Check type is a trait or interface
      ast_t* def = (ast_t*)ast_data(provides_type);
      pony_assert(def != NULL);

      if(ast_id(def) != TK_TRAIT && ast_id(def) != TK_INTERFACE)
      {
        ast_error(opt->check.errors, error_at,
          "invalid provides type. Can only be interfaces, traits and intersects of those.");
        ast_error_continue(opt->check.errors, provides_type,
          "invalid type here");
        return false;
      }

      // Add type to new provides list
      ast_list_append(list_parent, list_end, provides_type);
      ast_setdata(*list_end, ast_data(provides_type));

      return true;
    }

    default:
      ast_error(opt->check.errors, error_at,
        "invalid provides type. Can only be interfaces, traits and intersects of those.");
      ast_error_continue(opt->check.errors, provides_type, "invalid type here");
      return false;
  }
}

// Flatten a provides type into a list, checking all types are traits or
// interfaces
static ast_result_t flatten_provides_list(pass_opt_t* opt, ast_t* provider,
  int index)
{
  pony_assert(provider != NULL);

  ast_t* provides = ast_childidx(provider, index);

  if(ast_id(provides) == TK_NONE)
    return AST_OK;

  ast_t* list = ast_from(provides, TK_PROVIDES);
  ast_t* list_end = NULL;

  if(!flatten_provided_type(opt, provides, provider, list, &list_end))
  {
    ast_free(list);
    return AST_ERROR;
  }

  ast_replace(&provides, list);
  return AST_OK;
}

ast_result_t pass_flatten(ast_t** astp, pass_opt_t* options)
{
  ast_t* ast = *astp;

  switch(ast_id(ast))
  {
    case TK_UNIONTYPE:
      return flatten_union(options, ast);

    case TK_ISECTTYPE:
      return flatten_isect(options, ast);

    case TK_NEW:
    {
      switch(ast_id(options->check.frame->type))
      {
        case TK_CLASS:
          return flatten_constructor(options, ast);

        case TK_ACTOR:
          return flatten_async(options, ast);

        default: {}
      }
      break;
    }

    case TK_BE:
      return flatten_async(options, ast);

    case TK_ARROW:
      return flatten_arrow(options, astp);

    case TK_TYPEPARAMREF:
      return flatten_typeparamref(options, ast);

    case TK_EMBED:
    {
      // An embedded field must have a known, class type.
      AST_GET_CHILDREN(ast, id, type, init);
      bool ok = true;

      if(ast_id(type) != TK_NOMINAL || is_pointer(type) || is_nullable_pointer(type))
        ok = false;

      ast_t* def = (ast_t*)ast_data(type);

      if(def == NULL)
      {
        ok = false;
      } else {
        switch(ast_id(def))
        {
          case TK_STRUCT:
          case TK_CLASS:
            break;

          default:
            ok = false;
            break;
        }
      }

      if(!ok)
      {
        ast_error(options->check.errors, type,
          "embedded fields must be classes or structs");
        return AST_ERROR;
      }

      if(cap_single(type) == TK_TAG)
      {
        ast_error(options->check.errors, type, "embedded fields cannot be tag");
        return AST_ERROR;
      }

      return AST_OK;
    }

    case TK_ACTOR:
    case TK_CLASS:
    case TK_STRUCT:
    case TK_PRIMITIVE:
    case TK_TRAIT:
    case TK_INTERFACE:
      return flatten_provides_list(options, ast, 3);

    default: {}
  }

  return AST_OK;
}
