#include "call.h"
#include "../ast/id.h"
#include "../pkg/package.h"
#include "../type/lookup.h"
#include "ponyassert.h"


static bool check_partial_function_call(pass_opt_t* opt, ast_t* ast)
{
  pony_assert((ast_id(ast) == TK_FUNREF) || (ast_id(ast) == TK_FUNCHAIN) ||
    (ast_id(ast) == TK_NEWREF));
  AST_GET_CHILDREN(ast, receiver, method);

  // Receiver might be wrapped in another funref/newref
  // if the method had type parameters for qualification.
  if(ast_id(receiver) == ast_id(ast))
    AST_GET_CHILDREN_NO_DECL(receiver, receiver, method);

  // Look up the TK_CALL parent (or grandparent).
  ast_t* call = ast_parent(ast);
  if(ast_id(call) == TK_ADDRESS) // for bare method references.
    return true;
  if(ast_id(call) != TK_CALL)
    call = ast_parent(call);
  pony_assert(ast_id(call) == TK_CALL);
  ast_t* call_error = ast_childidx(call, 3);
  pony_assert(ast_id(call_error) == TK_QUESTION ||
    ast_id(call_error) == TK_NONE || ast_id(call_error) == TK_DONTCARE);

  // Look up the original method definition for this method call.
  deferred_reification_t* method_def = lookup_try(opt, receiver, ast_type(receiver),
    ast_name(method), true); // allow private types
  ast_t* method_ast = method_def->ast;
  deferred_reify_free(method_def);

  pony_assert(ast_id(method_ast) == TK_FUN || ast_id(method_ast) == TK_BE ||
    ast_id(method_ast) == TK_NEW);

  // If the receiver is a reference with a hygienic id, it's a sugared call,
  // and we should skip the check for partiality at the call site.
  bool skip_partial_check = false;
  if((ast_child(receiver) != NULL) && (ast_id(ast_child(receiver)) == TK_ID) &&
    is_name_internal_test(ast_name(ast_child(receiver)))
    )
    skip_partial_check = true;

  // If the method definition containing the call site had its body inherited
  // from a trait, we don't want to check partiality of the call site here -
  // it should only be checked in the context of the original trait.
  ast_t* body_donor = (ast_t*)ast_data(opt->check.frame->method);
  if((body_donor != NULL) && (ast_id(body_donor) == TK_TRAIT))
    skip_partial_check = true;

  // Verify that the call partiality matches that of the method.
  bool r = true;
  ast_t* method_error = ast_childidx(method_ast, 5);
  if(ast_id(method_error) == TK_QUESTION)
  {
    ast_seterror(ast);

    if((ast_id(call_error) != TK_QUESTION) && !skip_partial_check) {
      ast_error(opt->check.errors, call_error,
        "call is not partial but the method is - " \
        "a question mark is required after this call");
      ast_error_continue(opt->check.errors, method_error,
        "method is here");
      r = false;
    }
  } else {
    if((ast_id(call_error) == TK_QUESTION) && !skip_partial_check) {
      ast_error(opt->check.errors, call_error,
        "call is partial but the method is not - " \
        "this question mark should be removed");
      ast_error_continue(opt->check.errors, method_error,
        "method is here");
      r = false;
    }
  }

  return r;
}

static bool check_partial_ffi_call(pass_opt_t* opt, ast_t* ast)
{
  pony_assert(ast_id(ast) == TK_FFICALL);
  AST_GET_CHILDREN(ast, call_name, call_ret_typeargs, args, named_args, call_error);

  // The expr pass (expr_ffi) should have stored the declaration here, if found.
  ast_t* decl = (ast_t*)ast_data(ast);

  if(decl == NULL) {
    if(ast_id(call_error) == TK_QUESTION)
      ast_seterror(ast);
  } else {
    pony_assert(ast_id(decl) == TK_FFIDECL);
    AST_GET_CHILDREN(decl, decl_name, decl_ret_typeargs, params, named_params,
      decl_error);

    // Verify that the call partiality matches that of the declaration.
    if(ast_id(decl_error) == TK_QUESTION)
    {
      ast_seterror(ast);

      if(ast_id(call_error) != TK_QUESTION) {
        ast_error(opt->check.errors, call_error,
          "call is not partial but the declaration is - " \
          "a question mark is required after this call");
        ast_error_continue(opt->check.errors, decl_error,
          "declaration is here");
        return false;
      }
    } else {
      if(ast_id(call_error) == TK_QUESTION) {
        ast_error(opt->check.errors, call_error,
          "call is partial but the declaration is not - " \
          "this question mark should be removed");
        ast_error_continue(opt->check.errors, decl_error,
          "declaration is here");
        return false;
      }
    }
  }

  return true;
}

bool verify_function_call(pass_opt_t* opt, ast_t* ast)
{
  pony_assert((ast_id(ast) == TK_FUNREF) || (ast_id(ast) == TK_FUNCHAIN) ||
    (ast_id(ast) == TK_NEWREF));

  ast_inheritflags(ast);
  ast_setmightsend(ast);

  if(!check_partial_function_call(opt, ast))
    return false;

  return true;
}

bool verify_behaviour_call(pass_opt_t* opt, ast_t* ast)
{
  (void)opt;
  pony_assert((ast_id(ast) == TK_BEREF) || (ast_id(ast) == TK_BECHAIN) ||
    (ast_id(ast) == TK_NEWBEREF));

  ast_inheritflags(ast);
  ast_setsend(ast);

  return true;
}

bool verify_ffi_call(pass_opt_t* opt, ast_t* ast)
{
  pony_assert(ast_id(ast) == TK_FFICALL);

  if(!package_allow_ffi(&opt->check))
  {
    ast_error(opt->check.errors, ast, "this package isn't allowed to do C FFI");
    return false;
  }

  ast_inheritflags(ast);

  if(!check_partial_ffi_call(opt, ast))
    return false;

  return true;
}
