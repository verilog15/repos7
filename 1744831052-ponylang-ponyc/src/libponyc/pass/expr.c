#include "expr.h"
#include "../expr/literal.h"
#include "../expr/reference.h"
#include "../expr/operator.h"
#include "../expr/postfix.h"
#include "../expr/call.h"
#include "../expr/control.h"
#include "../expr/match.h"
#include "../expr/array.h"
#include "../expr/ffi.h"
#include "../expr/lambda.h"
#include "../type/assemble.h"
#include "../type/lookup.h"
#include "../type/subtype.h"
#include "ponyassert.h"

static bool is_numeric_primitive(const char* name)
{
  if(name == stringtab("U8") ||
     name == stringtab("I8") ||
     name == stringtab("U16") ||
     name == stringtab("I16") ||
     name == stringtab("U32") ||
     name == stringtab("I32") ||
     name == stringtab("U64") ||
     name == stringtab("I64") ||
     name == stringtab("U128") ||
     name == stringtab("I128") ||
     name == stringtab("ULong") ||
     name == stringtab("ILong") ||
     name == stringtab("USize") ||
     name == stringtab("ISize") ||
     name == stringtab("F32") ||
     name == stringtab("F64"))
    return true;
  return false;
}

bool is_result_needed(ast_t* ast)
{
  ast_t* parent = ast_parent(ast);

  switch(ast_id(parent))
  {
    case TK_SEQ:
      // If we're not the last element, we don't need the result.
      if(ast_sibling(ast) != NULL)
        return false;

      return is_result_needed(parent);

    case TK_IF:
    case TK_IFDEF:
    case TK_WHILE:
    case TK_MATCH:
      // Condition needed, body/else needed only if parent needed.
      if(ast_child(parent) == ast)
        return true;

      return is_result_needed(parent);

    case TK_IFTYPE:
      // Sub/supertype not needed, body needed only if parent needed.
      if((ast_child(parent) == ast) || (ast_childidx(parent, 1) == ast))
        return false;

      return is_result_needed(parent);

    case TK_REPEAT:
      // Cond needed, body/else needed only if parent needed.
      if(ast_childidx(parent, 1) == ast)
        return true;

      return is_result_needed(parent);

    case TK_CASE:
      // Pattern, guard needed, body needed only if parent needed
      if(ast_childidx(parent, 2) != ast)
        return true;

      return is_result_needed(parent);

    case TK_CASES:
    case TK_IFTYPE_SET:
    case TK_TRY:
    case TK_TRY_NO_CHECK:
    case TK_RECOVER:
    case TK_DISPOSING_BLOCK:
      // Only if parent needed.
      return is_result_needed(parent);

    case TK_NEW:
    {
      // Only if it is a numeric primitive constructor.
      ast_t* type = ast_childidx(parent, 4);
      pony_assert(ast_id(type) == TK_NOMINAL);
      const char* pkg_name = ast_name(ast_child(type));
      const char* type_name = ast_name(ast_childidx(type, 1));
      if(pkg_name == stringtab("$0")) // Builtin package.
        return is_numeric_primitive(type_name);
      return false;
    }

    case TK_BE:
      // Result of a behaviour isn't needed.
      return false;

    case TK_BECHAIN:
    case TK_FUNCHAIN:
      // Result of the receiver expression is needed if the chain result is
      // needed
      if(ast_childidx(parent, 0) == ast)
        return is_result_needed(parent);

      // Result of a chained method isn't needed.
      return false;

    default: {}
  }

  // All others needed.
  return true;
}

bool is_method_result(typecheck_t* t, ast_t* ast)
{
  if(ast == t->frame->method_body)
    return true;

  ast_t* parent = ast_parent(ast);

  switch(ast_id(parent))
  {
    case TK_SEQ:
      // More expressions in a sequence means we're not the result.
      if(ast_sibling(ast) != NULL)
        return false;
      break;

    case TK_IF:
    case TK_WHILE:
    case TK_MATCH:
    case TK_IFDEF:
      // The condition is not the result.
      if(ast_child(parent) == ast)
        return false;
      break;

    case TK_IFTYPE:
      // The subtype and the supertype are not the result.
    case TK_FOR:
      // The index variable and collection are not the result.
    case TK_CASE:
      // The pattern and the guard are not the result.
      if((ast_child(parent) == ast) || (ast_childidx(parent, 1) == ast))
        return false;
      break;

    case TK_REPEAT:
      // The condition is not the result.
      if(ast_childidx(parent, 1) == ast)
        return false;
      break;


    case TK_CASES:
    case TK_IFTYPE_SET:
    case TK_RECOVER:
    case TK_TUPLE:
      // These can be results.
      break;

    case TK_TRY:
    case TK_TRY_NO_CHECK:
      // The then block is not the result.
      if(ast_childidx(parent, 2) == ast)
        return false;
      break;

    case TK_DISPOSING_BLOCK:
      // The dispose block is not the result.
      if(ast_childidx(parent, 1) == ast)
        return false;
      break;

    default:
      // Other expressions are not results.
      return false;
  }

  return is_method_result(t, parent);
}

bool is_method_return(typecheck_t* t, ast_t* ast)
{
  ast_t* parent = ast_parent(ast);

  if(ast_id(parent) == TK_SEQ)
  {
    parent = ast_parent(parent);

    if(ast_id(parent) == TK_RETURN)
      return true;
  }

  return is_method_result(t, ast);
}

bool is_typecheck_error(ast_t* type)
{
  if(type == NULL)
    return true;

  if(ast_id(type) == TK_INFERTYPE || ast_id(type) == TK_ERRORTYPE)
    return true;

  return false;
}

static ast_t* find_tuple_type(pass_opt_t* opt, ast_t* ast, size_t child_count)
{
  if((ast_id(ast) == TK_TUPLETYPE) && (ast_childcount(ast) == child_count))
    return ast;

  switch(ast_id(ast))
  {
    // For a union or intersection type, go for the first member in the
    // type that is a tupletype with the right number of elements.
    // We won't handle cases where there are multiple options with the
    // right number of elements and one of the later options is correct.
    // TODO: handle this using astlist_t.
    case TK_UNIONTYPE:
    case TK_ISECTTYPE:
    {
      ast_t* member_type = ast_child(ast);
      while(member_type != NULL)
      {
        ast_t* member_tuple_type =
          find_tuple_type(opt, member_type, child_count);

        if(member_tuple_type != NULL)
          return member_tuple_type;

        member_type = ast_sibling(member_type);
      }
      break;
    }

    // For an arrow type, just dig into the RHS.
    case TK_ARROW:
      return find_tuple_type(opt, ast_childlast(ast), child_count);

    case TK_TYPEPARAMREF: break; // TODO

    default:
      break;
  }

  return NULL;
}

ast_t* find_antecedent_type(pass_opt_t* opt, ast_t* ast, bool* is_recovered)
{
  ast_t* parent = ast_parent(ast);

  switch(ast_id(parent))
  {
    // For the right side of an assignment, find the type of the left side.
    case TK_ASSIGN:
    {
      AST_GET_CHILDREN(parent, lhs, rhs);
      if(rhs != ast)
        return NULL;

      return ast_type(lhs);
    }

    // For a parameter default value expression, use the type of the parameter.
    case TK_PARAM:
    case TK_LAMBDACAPTURE:
    {
      AST_GET_CHILDREN(parent, id, type, deflt);
      pony_assert(ast == deflt);
      return type;
    }

    // For an array literal expression, use the element type if specified.
    case TK_ARRAY:
    {
      AST_GET_CHILDREN(parent, type, seq);
      pony_assert(ast == seq);

      if(ast_id(type) == TK_NONE)
        return NULL;

      return type;
    }
      break;

    // For an argument, find the type of the corresponding parameter.
    case TK_POSITIONALARGS:
    {
      // Get the type signature of the function call.
      ast_t* receiver = ast_child(ast_parent(parent));
      ast_t* funtype = ast_type(receiver);
      if(is_typecheck_error(funtype))
        return funtype;

      // If this is a call to a callable object instead of a function reference,
      // we need to use the funtype of the apply method of the object.
      if(ast_id(funtype) != TK_FUNTYPE)
      {
        deferred_reification_t* fun = lookup(opt, receiver, funtype,
          stringtab("apply"));

        if(fun == NULL)
          return NULL;

        if((ast_id(fun->ast) != TK_BE) && (ast_id(fun->ast) != TK_FUN))
        {
          deferred_reify_free(fun);
          return NULL;
        }

        ast_t* r_fun = deferred_reify_method_def(fun, fun->ast, opt);
        funtype = type_for_fun(r_fun);
        ast_free_unattached(r_fun);
        deferred_reify_free(fun);
      }

      AST_GET_CHILDREN(funtype, cap, t_params, params, ret_type);

      // Find the parameter type corresponding to this specific argument.
      ast_t* arg = ast_child(parent);
      ast_t* param = ast_child(params);
      while((arg != NULL) && (param != NULL))
      {
        if(arg == ast)
          return ast_childidx(param, 1);

        arg = ast_sibling(arg);
        param = ast_sibling(param);
      }

      // We didn't find a match.
      return NULL;
    }

    // For an argument, find the type of the corresponding parameter.
    case TK_NAMEDARG:
    case TK_UPDATEARG:
    {
      // Get the type signature of the function call.
      ast_t* receiver = ast_child(ast_parent(ast_parent(parent)));
      ast_t* funtype = ast_type(receiver);
      if(is_typecheck_error(funtype))
        return funtype;
      pony_assert(ast_id(funtype) == TK_FUNTYPE);
      AST_GET_CHILDREN(funtype, cap, t_params, params, ret_type);

      // Find the parameter type corresponding to this named argument.
      const char* name = ast_name(ast_child(parent));
      ast_t* param = ast_child(params);
      while(param != NULL)
      {
        if(ast_name(ast_child(param)) == name)
          return ast_childidx(param, 1);

        param = ast_sibling(param);
      }

      // We didn't find a match.
      return NULL;
    }

    // For a function body, use the declared return type of the function.
    case TK_FUN:
    {
      ast_t* body = ast_childidx(parent, 6);
      (void)body;
      pony_assert(ast == body);

      ast_t* ret_type = ast_childidx(parent, 4);
      if(ast_id(ret_type) == TK_NONE)
        return NULL;

      return ret_type;
    }

    // For the last expression in a sequence, recurse to the parent.
    // If the given expression is not the last one, it is uninferable.
    case TK_SEQ:
    {
      if(ast_childlast(parent) == ast)
        return find_antecedent_type(opt, parent, is_recovered);

      // If this sequence is an array literal, every child uses the LHS type.
      if(ast_id(ast_parent(parent)) == TK_ARRAY)
        return find_antecedent_type(opt, parent, is_recovered);

      return NULL;
    }

    // For a tuple expression, take the nth element of the upper LHS type.
    case TK_TUPLE:
    {
      ast_t* antecedent = find_antecedent_type(opt, parent, is_recovered);
      if(antecedent == NULL)
        return NULL;

      // Dig through the LHS type until we find a tuple type.
      antecedent = find_tuple_type(opt, antecedent, ast_childcount(parent));
      if(antecedent == NULL)
        return NULL;
      pony_assert(ast_id(antecedent) == TK_TUPLETYPE);

      // Find the element of the LHS type that corresponds to our element.
      ast_t* elem = ast_child(parent);
      ast_t* type_elem = ast_child(antecedent);
      while((elem != NULL) && (type_elem != NULL))
      {
        if(elem == ast)
          return type_elem;

        elem = ast_sibling(elem);
        type_elem = ast_sibling(type_elem);
      }

      break;
    }

    // For a return statement, recurse to the method body that contains it.
    case TK_RETURN:
    {
      ast_t* body = opt->check.frame->method_body;
      if(body == NULL)
        return NULL;

      return find_antecedent_type(opt, body, is_recovered);
    }

    // For a break statement, recurse to the loop body that contains it.
    case TK_BREAK:
    {
      ast_t* body = opt->check.frame->loop_body;
      if(body == NULL)
        return NULL;

      return find_antecedent_type(opt, body, is_recovered);
    }

    // For a recover block, note the recovery and move on to the parent.
    case TK_RECOVER:
    {
      if(is_recovered != NULL)
        *is_recovered = true;

      return find_antecedent_type(opt, parent, is_recovered);
    }

    case TK_IF:
    case TK_IFDEF:
    case TK_IFTYPE:
    case TK_IFTYPE_SET:
    case TK_THEN:
    case TK_ELSE:
    case TK_WHILE:
    case TK_REPEAT:
    case TK_MATCH:
    case TK_CASES:
    case TK_CASE:
    case TK_TRY:
    case TK_TRY_NO_CHECK:
    case TK_DISPOSING_BLOCK:
    case TK_CALL:
      return find_antecedent_type(opt, parent, is_recovered);

    default:
      break;
  }

  return NULL;
}

static void fold_union(pass_opt_t* opt, ast_t** astp)
{
  ast_t* ast = *astp;

  ast_t* child = ast_child(ast);

  while(child != NULL)
  {
    ast_t* next = ast_sibling(child);
    bool remove = false;

    while(next != NULL)
    {
      if(is_subtype(next, child, NULL, opt))
      {
        ast_t* tmp = next;
        next = ast_sibling(next);
        ast_remove(tmp);
      } else if(is_subtype(child, next, NULL, opt)) {
        remove = true;
        break;
      } else {
        next = ast_sibling(next);
      }
    }

    if(remove)
    {
      ast_t* tmp = child;
      child = ast_sibling(child);
      ast_remove(tmp);
    } else {
      child = ast_sibling(child);
    }
  }

  child = ast_child(ast);

  if(ast_sibling(child) == NULL)
    ast_replace(astp, child);
}

ast_result_t pass_pre_expr(ast_t** astp, pass_opt_t* options)
{
  ast_t* ast = *astp;

  switch(ast_id(ast))
  {
    case TK_ARRAY: return expr_pre_array(options, astp);
    case TK_IFDEFNOT:
    case TK_IFDEFAND:
    case TK_IFDEFOR:
    case TK_IFDEFFLAG:
      // Don't look in guards for use commands to avoid false type errors
      if((ast_parent(ast) != NULL) && (ast_id(ast_parent(ast)) == TK_USE))
        return AST_IGNORE;
      break;
    default: {}
  }

  return AST_OK;
}

ast_result_t pass_expr(ast_t** astp, pass_opt_t* options)
{
  ast_t* ast = *astp;
  bool r = true;

  switch(ast_id(ast))
  {
    case TK_PRIMITIVE:
    case TK_STRUCT:
    case TK_CLASS:
    case TK_ACTOR:
    case TK_TRAIT:
    case TK_INTERFACE:  r = expr_provides(options, ast); break;
    case TK_NOMINAL:    r = expr_nominal(options, astp); break;
    case TK_FVAR:
    case TK_FLET:
    case TK_EMBED:      r = expr_field(options, ast); break;
    case TK_PARAM:      r = expr_param(options, ast); break;
    case TK_NEW:
    case TK_BE:
    case TK_FUN:        r = expr_fun(options, ast); break;
    case TK_SEQ:        r = expr_seq(options, ast); break;
    case TK_VAR:
    case TK_LET:        r = expr_local(options, ast); break;
    case TK_BREAK:      r = expr_break(options, ast); break;
    case TK_RETURN:     r = expr_return(options, ast); break;
    case TK_IS:
    case TK_ISNT:       r = expr_identity(options, ast); break;
    case TK_ASSIGN:     r = expr_assign(options, ast); break;
    case TK_CONSUME:    r = expr_consume(options, ast); break;
    case TK_RECOVER:    r = expr_recover(options, ast); break;
    case TK_DOT:        r = expr_dot(options, astp); break;
    case TK_TILDE:      r = expr_tilde(options, astp); break;
    case TK_CHAIN:      r = expr_chain(options, astp); break;
    case TK_QUALIFY:    r = expr_qualify(options, astp); break;
    case TK_CALL:       r = expr_call(options, astp); break;
    case TK_IFDEF:
    case TK_IF:         r = expr_if(options, ast); break;
    case TK_IFTYPE_SET: r = expr_iftype(options, ast); break;
    case TK_WHILE:      r = expr_while(options, ast); break;
    case TK_REPEAT:     r = expr_repeat(options, ast); break;
    case TK_TRY_NO_CHECK:
    case TK_TRY:        r = expr_try(options, ast); break;
    case TK_DISPOSING_BLOCK:
                        r = expr_disposing_block(options, ast); break;
    case TK_MATCH:      r = expr_match(options, ast); break;
    case TK_CASES:      r = expr_cases(options, ast); break;
    case TK_CASE:       r = expr_case(options, ast); break;
    case TK_MATCH_CAPTURE:
                        r = expr_match_capture(options, ast); break;
    case TK_TUPLE:      r = expr_tuple(options, ast); break;
    case TK_ARRAY:      r = expr_array(options, astp); break;

    case TK_DONTCAREREF:
                        r = expr_dontcareref(options, ast); break;
    case TK_TYPEREF:    r = expr_typeref(options, astp); break;
    case TK_VARREF:
    case TK_LETREF:     r = expr_localref(options, ast); break;
    case TK_PARAMREF:   r = expr_paramref(options, ast); break;

    case TK_THIS:       r = expr_this(options, ast); break;
    case TK_TRUE:
    case TK_FALSE:      r = expr_literal(options, ast, "Bool"); break;
    case TK_COMPILE_INTRINSIC:
                        r = expr_compile_intrinsic(options, ast); break;
    case TK_LOCATION:   r = expr_location(options, ast); break;
    case TK_ADDRESS:    r = expr_addressof(options, ast); break;
    case TK_DIGESTOF:   r = expr_digestof(options, ast); break;

    case TK_AS:
      if(!expr_as(options, astp))
        return AST_FATAL;
      break;

    case TK_OBJECT:
      if(!expr_object(options, astp))
        return AST_FATAL;
      break;

    case TK_LAMBDA:
    case TK_BARELAMBDA:
      if(!expr_lambda(options, astp))
        return AST_FATAL;
      break;

    case TK_UNIONTYPE:
      fold_union(options, astp);
      break;

    case TK_INT:
      // Integer literals can be integers or floats
      make_literal_type(ast);
      break;

    case TK_FLOAT:
      make_literal_type(ast);
      break;

    case TK_STRING:
      if(ast_id(ast_parent(ast)) == TK_PACKAGE)
        return AST_OK;

      r = expr_literal(options, ast, "String");
      break;

    case TK_FFICALL:
      r = expr_ffi(options, ast);

    default: {}
  }

  if(!r)
  {
    pony_assert(errors_get_count(options->check.errors) > 0);
    return AST_ERROR;
  }

  // If the ast's type is a union type, we may need to fold it here.
  ast_t* type = ast_type(*astp);
  if(type && (ast_id(type) == TK_UNIONTYPE))
    fold_union(options, &type);

  // Can't use ast here, it might have changed
  symtab_t* symtab = ast_get_symtab(*astp);

  if(symtab != NULL && !symtab_check_all_defined(symtab, options->check.errors))
    return AST_ERROR;

  return AST_OK;
}
