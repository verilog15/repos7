#include "gencall.h"
#include "genoperator.h"
#include "genreference.h"
#include "genexpr.h"
#include "gendesc.h"
#include "genfun.h"
#include "genname.h"
#include "genopt.h"
#include "gentrace.h"
#include "../pkg/platformfuns.h"
#include "../type/cap.h"
#include "../type/subtype.h"
#include "../ast/stringtab.h"
#include "../pass/expr.h"
#include "../../libponyrt/mem/pool.h"
#include "../../libponyrt/mem/heap.h"
#include "ponyassert.h"
#include <string.h>

typedef struct call_tuple_indices_t
{
  size_t* data;
  size_t count;
  size_t alloc;
} call_tuple_indices_t;

static void tuple_indices_init(call_tuple_indices_t* ti)
{
  ti->data = (size_t*)ponyint_pool_alloc_size(4 * sizeof(size_t));
  ti->count = 0;
  ti->alloc = 4;
}

static void tuple_indices_destroy(call_tuple_indices_t* ti)
{
  ponyint_pool_free_size(ti->alloc * sizeof(size_t), ti->data);
  ti->data = NULL;
  ti->count = 0;
  ti->alloc = 0;
}

static void tuple_indices_push(call_tuple_indices_t* ti, size_t idx)
{
  if(ti->count == ti->alloc)
  {
    size_t old_alloc = ti->alloc * sizeof(size_t);
    ti->data =
      (size_t*)ponyint_pool_realloc_size(old_alloc, old_alloc * 2, ti->data);
    ti->alloc *= 2;
  }
  ti->data[ti->count++] = idx;
}

static size_t tuple_indices_pop(call_tuple_indices_t* ti)
{
  pony_assert(ti->count > 0);

  return ti->data[--ti->count];
}

struct ffi_decl_t
{
  LLVMValueRef func;
  // First declaration encountered
  ast_t* decl;
  // First call encountered
  ast_t* call;
};

static size_t ffi_decl_hash(ffi_decl_t* d)
{
  return ponyint_hash_ptr(d->func);
}

static bool ffi_decl_cmp(ffi_decl_t* a, ffi_decl_t* b)
{
  return a->func == b->func;
}

static void ffi_decl_free(ffi_decl_t* d)
{
  POOL_FREE(ffi_decl_t, d);
}

DEFINE_HASHMAP(ffi_decls, ffi_decls_t, ffi_decl_t, ffi_decl_hash, ffi_decl_cmp,
  ffi_decl_free);

static LLVMValueRef invoke_fun(compile_t* c, LLVMTypeRef fun_type,
  LLVMValueRef fun, LLVMValueRef* args, int count, const char* ret, bool setcc)
{
  if(fun == NULL)
    return NULL;

  LLVMBasicBlockRef this_block = LLVMGetInsertBlock(c->builder);
  LLVMBasicBlockRef then_block = LLVMInsertBasicBlockInContext(c->context,
    this_block, "invoke");
  LLVMMoveBasicBlockAfter(then_block, this_block);
  LLVMBasicBlockRef else_block = c->frame->invoke_target;

  LLVMValueRef invoke = LLVMBuildInvoke2(c->builder, fun_type, fun, args, count,
    then_block, else_block, ret);

  if(setcc)
    LLVMSetInstructionCallConv(invoke, c->callconv);

  LLVMPositionBuilderAtEnd(c->builder, then_block);
  return invoke;
}

static bool special_case_operator(compile_t* c, ast_t* ast,
  LLVMValueRef *value, bool short_circuit, bool native128)
{
  AST_GET_CHILDREN(ast, postfix, positional, named, question);
  AST_GET_CHILDREN(postfix, left, method);

  ast_t* right = ast_child(positional);
  const char* name = ast_name(method);
  bool special_case = true;
  *value = NULL;

  codegen_debugloc(c, ast);

  if(name == c->str_add)
    *value = gen_add(c, left, right, true);
  else if(name == c->str_sub)
    *value = gen_sub(c, left, right, true);
  else if((name == c->str_mul) && native128)
    *value = gen_mul(c, left, right, true);
  else if((name == c->str_div) && native128)
    *value = gen_div(c, left, right, true);
  else if((name == c->str_rem) && native128)
    *value = gen_rem(c, left, right, true);
  else if(name == c->str_neg)
    *value = gen_neg(c, left, true);
  else if(name == c->str_add_unsafe)
    *value = gen_add(c, left, right, false);
  else if(name == c->str_sub_unsafe)
    *value = gen_sub(c, left, right, false);
  else if((name == c->str_mul_unsafe) && native128)
    *value = gen_mul(c, left, right, false);
  else if((name == c->str_div_unsafe) && native128)
    *value = gen_div(c, left, right, false);
  else if((name == c->str_rem_unsafe) && native128)
    *value = gen_rem(c, left, right, false);
  else if(name == c->str_neg_unsafe)
    *value = gen_neg(c, left, false);
  else if((name == c->str_and) && short_circuit)
    *value = gen_and_sc(c, left, right);
  else if((name == c->str_or) && short_circuit)
    *value = gen_or_sc(c, left, right);
  else if((name == c->str_and) && !short_circuit)
    *value = gen_and(c, left, right);
  else if((name == c->str_or) && !short_circuit)
    *value = gen_or(c, left, right);
  else if(name == c->str_xor)
    *value = gen_xor(c, left, right);
  else if(name == c->str_not)
    *value = gen_not(c, left);
  else if(name == c->str_shl)
    *value = gen_shl(c, left, right, true);
  else if(name == c->str_shr)
    *value = gen_shr(c, left, right, true);
  else if(name == c->str_shl_unsafe)
    *value = gen_shl(c, left, right, false);
  else if(name == c->str_shr_unsafe)
    *value = gen_shr(c, left, right, false);
  else if(name == c->str_eq)
    *value = gen_eq(c, left, right, true);
  else if(name == c->str_ne)
    *value = gen_ne(c, left, right, true);
  else if(name == c->str_lt)
    *value = gen_lt(c, left, right, true);
  else if(name == c->str_le)
    *value = gen_le(c, left, right, true);
  else if(name == c->str_ge)
    *value = gen_ge(c, left, right, true);
  else if(name == c->str_gt)
    *value = gen_gt(c, left, right, true);
  else if(name == c->str_eq_unsafe)
    *value = gen_eq(c, left, right, false);
  else if(name == c->str_ne_unsafe)
    *value = gen_ne(c, left, right, false);
  else if(name == c->str_lt_unsafe)
    *value = gen_lt(c, left, right, false);
  else if(name == c->str_le_unsafe)
    *value = gen_le(c, left, right, false);
  else if(name == c->str_ge_unsafe)
    *value = gen_ge(c, left, right, false);
  else if(name == c->str_gt_unsafe)
    *value = gen_gt(c, left, right, false);
  else
    special_case = false;

  codegen_debugloc(c, NULL);
  return special_case;
}

static LLVMValueRef special_case_platform(compile_t* c, ast_t* ast)
{
  AST_GET_CHILDREN(ast, postfix, positional, named, question);
  AST_GET_CHILDREN(postfix, receiver, method);

  const char* method_name = ast_name(method);
  bool is_target;

  if(os_is_target(method_name, c->opt->release, &is_target, c->opt))
    return LLVMConstInt(c->i1, is_target ? 1 : 0, false);

  ast_error(c->opt->check.errors, ast, "unknown Platform setting");
  return NULL;
}

static bool special_case_call(compile_t* c, ast_t* ast, LLVMValueRef* value)
{
  AST_GET_CHILDREN(ast, postfix, positional, named, question);

  if((ast_id(postfix) != TK_FUNREF) || (ast_id(named) != TK_NONE))
    return false;

  AST_GET_CHILDREN(postfix, receiver, method);
  ast_t* receiver_type = deferred_reify(c->frame->reify, ast_type(receiver),
    c->opt);

  const char* name = NULL;

  if(ast_id(receiver_type) == TK_NOMINAL)
  {
    AST_GET_CHILDREN(receiver_type, package, id);

    if(ast_name(package) == c->str_builtin)
      name = ast_name(id);
  }

  ast_free_unattached(receiver_type);

  if(name == NULL)
    return false;

  if(name == c->str_Bool)
    return special_case_operator(c, ast, value, true, true);

  if((name == c->str_I8) ||
    (name == c->str_I16) ||
    (name == c->str_I32) ||
    (name == c->str_I64) ||
    (name == c->str_ILong) ||
    (name == c->str_ISize) ||
    (name == c->str_U8) ||
    (name == c->str_U16) ||
    (name == c->str_U32) ||
    (name == c->str_U64) ||
    (name == c->str_ULong) ||
    (name == c->str_USize) ||
    (name == c->str_F32) ||
    (name == c->str_F64)
    )
  {
    return special_case_operator(c, ast, value, false, true);
  }

  if((name == c->str_I128) || (name == c->str_U128))
  {
    bool native128 = target_is_native128(c->opt->triple);
    return special_case_operator(c, ast, value, false, native128);
  }

  if(name == c->str_Platform)
  {
    *value = special_case_platform(c, ast);
    return true;
  }

  return false;
}

static LLVMValueRef dispatch_function(compile_t* c, reach_type_t* t,
  reach_method_t* m, LLVMValueRef l_value)
{
  compile_method_t* c_m = (compile_method_t*)m->c_method;

  if(t->bare_method == m)
    return l_value;

  switch(t->underlying)
  {
    case TK_UNIONTYPE:
    case TK_ISECTTYPE:
    case TK_INTERFACE:
    case TK_TRAIT:
    {
      pony_assert(t->bare_method == NULL);

      // Get the function from the vtable.
      LLVMValueRef func = gendesc_vtable(c, gendesc_fetch(c, l_value),
        m->vtable_index);

      return func;
    }

    case TK_PRIMITIVE:
    case TK_STRUCT:
    case TK_CLASS:
    case TK_ACTOR:
    {
      // Static, get the actual function.
      return c_m->func;
    }

    default: {}
  }

  pony_assert(0);
  return NULL;
}

static bool call_needs_receiver(ast_t* postfix, reach_type_t* t)
{
  switch(ast_id(postfix))
  {
    case TK_NEWREF:
    case TK_NEWBEREF:
      // No receiver if a new primitive.
      if(((compile_type_t*)t->c_type)->primitive != NULL)
        return false;

      // No receiver if a new Pointer or NullablePointer.
      if(is_pointer(t->ast) || is_nullable_pointer(t->ast))
        return false;

      return true;

    // Always generate the receiver, even for bare function calls. This ensures
    // that side-effects always happen.
    default:
      return true;
  }
}

static void set_descriptor(compile_t* c, reach_type_t* t, LLVMValueRef value)
{
  if(t->underlying == TK_STRUCT)
    return;

  compile_type_t* c_t = (compile_type_t*) t->c_type;

  LLVMValueRef desc_ptr = LLVMBuildStructGEP2(c->builder, c_t->structure,
    value, 0, "");
  LLVMBuildStore(c->builder, c_t->desc, desc_ptr);
}

// This function builds a stack of indices such that for an AST nested in an
// arbitrary number of tuples, the stack will contain the indices of the
// successive members to traverse when going from the top-level tuple to the
// AST. If the AST isn't in a tuple, the stack stays empty.
static ast_t* make_tuple_indices(call_tuple_indices_t* ti, ast_t* ast)
{
  ast_t* current = ast;
  ast_t* parent = ast_parent(current);
  while((parent != NULL) && (ast_id(parent) != TK_ASSIGN) &&
    (ast_id(parent) != TK_CALL))
  {
    if(ast_id(parent) == TK_TUPLE)
    {
      size_t index = 0;
      ast_t* child = ast_child(parent);
      while(current != child)
      {
        ++index;
        child = ast_sibling(child);
      }
      tuple_indices_push(ti, index);
    }
    current = parent;
    parent = ast_parent(current);
  }

  return parent;
}

static ast_t* find_embed_constructor_receiver(ast_t* call)
{
  call_tuple_indices_t tuple_indices = {NULL, 0, 4};
  tuple_indices_init(&tuple_indices);

  ast_t* parent = make_tuple_indices(&tuple_indices, call);
  ast_t* fieldref = NULL;

  if((parent != NULL) && (ast_id(parent) == TK_ASSIGN))
  {
    // Traverse the LHS of the assignment looking for what our constructor call
    // is assigned to.
    ast_t* current = ast_child(parent);
    while((ast_id(current) == TK_TUPLE) || (ast_id(current) == TK_SEQ))
    {
      parent = current;
      if(ast_id(current) == TK_TUPLE)
      {
        // If there are no indices left, we're destructuring a tuple.
        // Errors in those cases have already been catched by the expr
        // pass.
        if(tuple_indices.count == 0)
          break;

        size_t index = tuple_indices_pop(&tuple_indices);
        current = ast_childidx(parent, index);
      } else {
        current = ast_childlast(parent);
      }
    }

    if(ast_id(current) == TK_EMBEDREF)
      fieldref = current;
  }

  tuple_indices_destroy(&tuple_indices);
  return fieldref;
}

static LLVMValueRef gen_constructor_receiver(compile_t* c, reach_type_t* t,
  ast_t* call)
{
  ast_t* fieldref = find_embed_constructor_receiver(call);

  if(fieldref != NULL)
  {
    LLVMValueRef receiver = gen_fieldptr(c, fieldref);
    set_descriptor(c, t, receiver);
    return receiver;
  } else {
    return gencall_alloc(c, t, call);
  }
}

static void set_method_external_interface(reach_type_t* t, const char* name,
  uint32_t vtable_index)
{
  size_t i = HASHMAP_BEGIN;
  reach_type_t* sub;

  while((sub = reach_type_cache_next(&t->subtypes, &i)) != NULL)
  {
    reach_method_name_t* n = reach_method_name(sub, name);

    if(n == NULL)
      continue;

    size_t j = HASHMAP_BEGIN;
    reach_method_t* m;

    while((m = reach_mangled_next(&n->r_mangled, &j)) != NULL)
    {
      if(m->vtable_index == vtable_index)
      {
        compile_method_t* c_m = (compile_method_t*)m->c_method;
        LLVMSetFunctionCallConv(c_m->func, LLVMCCallConv);
        LLVMSetLinkage(c_m->func, LLVMExternalLinkage);
        break;
      }
    }
  }
}

LLVMValueRef gen_funptr(compile_t* c, ast_t* ast)
{
  pony_assert((ast_id(ast) == TK_FUNREF) || (ast_id(ast) == TK_BEREF));
  AST_GET_CHILDREN(ast, receiver, method);
  ast_t* typeargs = NULL;

  // Dig through function qualification.
  switch(ast_id(receiver))
  {
    case TK_BEREF:
    case TK_FUNREF:
      typeargs = method;
      AST_GET_CHILDREN_NO_DECL(receiver, receiver, method);
      break;

    default: {}
  }

  // Generate the receiver.
  LLVMValueRef value = gen_expr(c, receiver);

  // Get the receiver type.
  ast_t* type = deferred_reify(c->frame->reify, ast_type(receiver), c->opt);
  reach_type_t* t = reach_type(c->reach, type);
  pony_assert(t != NULL);

  const char* name = ast_name(method);
  token_id cap = cap_dispatch(type);
  reach_method_t* m = reach_method(t, cap, name, typeargs);
  LLVMValueRef funptr = dispatch_function(c, t, m, value);

  ast_free_unattached(type);

  if((m->cap != TK_AT) && (c->linkage != LLVMExternalLinkage))
  {
    // We must reset the function linkage and calling convention since we're
    // passing a function pointer to a FFI call. Bare methods always use the
    // external linkage and the C calling convention so we don't need to process
    // them.
    switch(t->underlying)
    {
      case TK_PRIMITIVE:
      case TK_STRUCT:
      case TK_CLASS:
      case TK_ACTOR:
      {
        compile_method_t* c_m = (compile_method_t*)m->c_method;
        LLVMSetFunctionCallConv(c_m->func, LLVMCCallConv);
        LLVMSetLinkage(c_m->func, LLVMExternalLinkage);
        break;
      }
      case TK_UNIONTYPE:
      case TK_ISECTTYPE:
      case TK_INTERFACE:
      case TK_TRAIT:
        set_method_external_interface(t, name, m->vtable_index);
        break;
      default:
        pony_assert(0);
        break;
    }
  }

  return funptr;
}

void gen_send_message(compile_t* c, reach_method_t* m, LLVMValueRef args[],
  ast_t* args_ast)
{
  // Allocate the message, setting its size and ID.
  compile_method_t* c_m = (compile_method_t*)m->c_method;
  size_t msg_size = (size_t)LLVMABISizeOfType(c->target_data, c_m->msg_type);

  size_t params_buf_size = (m->param_count + 3) * sizeof(LLVMTypeRef);
  LLVMTypeRef* param_types =
    (LLVMTypeRef*)ponyint_pool_alloc_size(params_buf_size);
  LLVMGetStructElementTypes(c_m->msg_type, param_types);
  size_t args_buf_size = (m->param_count + 1) * sizeof(LLVMValueRef);
  LLVMValueRef* cast_args =
    (LLVMValueRef*)ponyint_pool_alloc_size(args_buf_size);
  size_t arg_types_buf_size = m->param_count * sizeof(ast_t*);
  ast_t** arg_types = (ast_t**)ponyint_pool_alloc_size(arg_types_buf_size);

  ast_t* arg_ast = ast_child(args_ast);

  deferred_reification_t* reify = c->frame->reify;

  for(size_t i = 0; i < m->param_count; i++)
  {
    arg_types[i] = deferred_reify(reify, ast_type(arg_ast), c->opt);
    cast_args[i+1] = gen_assign_cast(c, param_types[i+3], args[i+1],
      arg_types[i]);
    arg_ast = ast_sibling(arg_ast);
  }

  LLVMValueRef msg_args[5];

  msg_args[0] = LLVMConstInt(c->i32, ponyint_pool_index(msg_size), false);
  msg_args[1] = LLVMConstInt(c->i32, m->vtable_index, false);
  LLVMValueRef msg = gencall_runtime(c, "pony_alloc_msg", msg_args, 2, "");
  LLVMValueRef md = LLVMMDNodeInContext(c->context, NULL, 0);
  LLVMSetMetadataStr(msg, "pony.msgsend", md);

  for(unsigned int i = 0; i < m->param_count; i++)
  {
    LLVMValueRef arg_ptr = LLVMBuildStructGEP2(c->builder, c_m->msg_type, msg,
      i + 3, "");
    LLVMBuildStore(c->builder, cast_args[i+1], arg_ptr);
  }

  // Trace while populating the message contents.
  bool need_trace = false;

  for(size_t i = 0; i < m->param_count; i++)
  {
    if(gentrace_needed(c, arg_types[i], m->params[i].ast))
    {
      need_trace = true;
      break;
    }
  }

  LLVMValueRef ctx = codegen_ctx(c);

  if(need_trace)
  {
    LLVMValueRef gc = gencall_runtime(c, "pony_gc_send", &ctx, 1, "");
    LLVMSetMetadataStr(gc, "pony.msgsend", md);

    for(size_t i = 0; i < m->param_count; i++)
    {
      gentrace(c, ctx, args[i+1], cast_args[i+1], arg_types[i],
        m->params[i].ast);
    }

    gc = gencall_runtime(c, "pony_send_done", &ctx, 1, "");
    LLVMSetMetadataStr(gc, "pony.msgsend", md);
  }

  // Send the message.
  msg_args[0] = ctx;
  msg_args[1] = args[0];
  msg_args[2] = msg;
  msg_args[3] = msg;
  msg_args[4] = LLVMConstInt(c->i1, 1, false);
  LLVMValueRef send;

  if(ast_id(m->fun->ast) == TK_NEW)
    send = gencall_runtime(c, "pony_sendv_single", msg_args, 5, "");
  else
    send = gencall_runtime(c, "pony_sendv", msg_args, 5, "");

  LLVMSetMetadataStr(send, "pony.msgsend", md);

  ponyint_pool_free_size(params_buf_size, param_types);
  ponyint_pool_free_size(args_buf_size, cast_args);

  for(size_t i = 0; i < m->param_count; i++)
    ast_free_unattached(arg_types[i]);

  ponyint_pool_free_size(arg_types_buf_size, arg_types);
}

static bool contains_boxable(ast_t* type)
{
  switch(ast_id(type))
  {
    case TK_TUPLETYPE:
      return true;

    case TK_NOMINAL:
      return is_machine_word(type);

    case TK_UNIONTYPE:
    case TK_ISECTTYPE:
    {
      ast_t* child = ast_child(type);
      while(child != NULL)
      {
        if(contains_boxable(child))
          return true;

        child = ast_sibling(child);
      }

      return false;
    }

    default:
      pony_assert(0);
      return false;
  }
}

static bool can_inline_message_send(reach_type_t* t, reach_method_t* m,
  const char* method_name)
{
  switch(t->underlying)
  {
    case TK_UNIONTYPE:
    case TK_ISECTTYPE:
    case TK_INTERFACE:
    case TK_TRAIT:
      break;

    default:
      pony_assert(0);
      return false;
  }

  size_t i = HASHMAP_BEGIN;
  reach_type_t* sub;
  while((sub = reach_type_cache_next(&t->subtypes, &i)) != NULL)
  {
    reach_method_t* m_sub = reach_method(sub, m->cap, method_name, m->typeargs);

    if(m_sub == NULL)
      continue;

    switch(sub->underlying)
    {
      case TK_CLASS:
      case TK_PRIMITIVE:
        return false;

      case TK_ACTOR:
        if(ast_id(m_sub->fun->ast) == TK_FUN)
          return false;
        break;

      default: {}
    }

    pony_assert(m->param_count == m_sub->param_count);
    for(size_t i = 0; i < m->param_count; i++)
    {
      // If the param is a boxable type for us and an unboxable type for one of
      // our subtypes, that subtype will take that param as boxed through an
      // interface. In order to correctly box the value the actual function to
      // call must be resolved through name mangling, therefore we can't inline
      // the message send.
      reach_type_t* param = m->params[i].type;
      reach_type_t* sub_param = m_sub->params[i].type;
      if(param->can_be_boxed)
      {
        if(!sub_param->can_be_boxed)
          return false;

        if(param->underlying == TK_TUPLETYPE)
        {
          ast_t* child = ast_child(param->ast);
          while(child != NULL)
          {
            if(contains_boxable(child))
              return false;

            child = ast_sibling(child);
          }
        }
      }
    }
  }

  return true;
}

LLVMValueRef gen_call(compile_t* c, ast_t* ast)
{
  // Special case calls.
  LLVMValueRef special;

  if(special_case_call(c, ast, &special))
    return special;

  AST_GET_CHILDREN(ast, postfix, positional, named, question);
  AST_GET_CHILDREN(postfix, receiver, method);
  ast_t* typeargs = NULL;

  deferred_reification_t* reify = c->frame->reify;

  // Dig through function qualification.
  switch(ast_id(receiver))
  {
    case TK_NEWREF:
    case TK_NEWBEREF:
    case TK_BEREF:
    case TK_FUNREF:
    case TK_BECHAIN:
    case TK_FUNCHAIN:
      typeargs = deferred_reify(reify, method, c->opt);
      AST_GET_CHILDREN_NO_DECL(receiver, receiver, method);
      break;

    default: {}
  }

  // Get the receiver type.
  const char* method_name = ast_name(method);
  ast_t* type = deferred_reify(reify, ast_type(receiver), c->opt);
  reach_type_t* t = reach_type(c->reach, type);
  pony_assert(t != NULL);

  token_id cap = cap_dispatch(type);
  reach_method_t* m = reach_method(t, cap, method_name, typeargs);

  ast_free_unattached(type);
  ast_free_unattached(typeargs);

  // Generate the arguments.
  size_t count = m->param_count + 1;
  size_t buf_size = count * sizeof(void*);

  LLVMValueRef* args = (LLVMValueRef*)ponyint_pool_alloc_size(buf_size);
  ast_t* arg = ast_child(positional);
  int i = 1;

  while(arg != NULL)
  {
    LLVMValueRef value = gen_expr(c, arg);

    if(value == NULL)
    {
      ponyint_pool_free_size(buf_size, args);
      return NULL;
    }

    args[i] = value;
    arg = ast_sibling(arg);
    i++;
  }

  bool is_new_call = false;

  // Generate the receiver. Must be done after the arguments because the args
  // could change things in the receiver expression that must be accounted for.
  if(call_needs_receiver(postfix, t))
  {
    switch(ast_id(postfix))
    {
      case TK_NEWREF:
      case TK_NEWBEREF:
        args[0] = gen_constructor_receiver(c, t, ast);
        is_new_call = true;
        break;

      case TK_BEREF:
      case TK_FUNREF:
      case TK_BECHAIN:
      case TK_FUNCHAIN:
        args[0] = gen_expr(c, receiver);
        break;

      default:
        pony_assert(0);
        return NULL;
    }
  } else {
    // Use a null for the receiver type.
    args[0] = LLVMConstNull(((compile_type_t*)t->c_type)->use_type);
  }

  // Static or virtual dispatch.
  LLVMValueRef func = dispatch_function(c, t, m, args[0]);
  LLVMTypeRef func_type = ((compile_method_t*)m->c_method)->func_type;

  bool is_message = false;

  if((ast_id(postfix) == TK_NEWBEREF) || (ast_id(postfix) == TK_BEREF) ||
    (ast_id(postfix) == TK_BECHAIN))
  {
    switch(t->underlying)
    {
      case TK_ACTOR:
        is_message = true;
        break;

      case TK_UNIONTYPE:
      case TK_ISECTTYPE:
      case TK_INTERFACE:
      case TK_TRAIT:
        if(m->cap == TK_TAG)
          is_message = can_inline_message_send(t, m, method_name);
        break;

      default: {}
    }
  }

  bool bare = m->cap == TK_AT;
  LLVMValueRef r = NULL;

  if(is_message)
  {
    // If we're sending a message, trace and send here instead of calling the
    // sender to trace the most specific types possible.
    codegen_debugloc(c, ast);
    gen_send_message(c, m, args, positional);
    codegen_debugloc(c, NULL);
    switch(ast_id(postfix))
    {
      case TK_NEWREF:
      case TK_NEWBEREF:
        r = args[0];
        break;

      default:
        r = c->none_instance;
        break;
    }
  } else {
    LLVMTypeRef* params = (LLVMTypeRef*)ponyint_pool_alloc_size(buf_size);
    LLVMGetParamTypes(func_type, params + (bare ? 1 : 0));

    // We also need to cast the rest of the arguments, using the same casting
    // semantics as assignment.
    arg = ast_child(positional);
    i = 1;

    while(arg != NULL)
    {
      ast_t* arg_type = deferred_reify(reify, ast_type(arg), c->opt);
      args[i] = gen_assign_cast(c, params[i], args[i], arg_type);
      ast_free_unattached(arg_type);
      arg = ast_sibling(arg);
      i++;
    }

    uintptr_t arg_offset = 0;
    if(bare)
    {
      arg_offset = 1;
      i--;
    }

    if(func != NULL)
    {
      // If we can error out and we have an invoke target, generate an invoke
      // instead of a call.
      codegen_debugloc(c, ast);

      if(ast_canerror(ast) && (c->frame->invoke_target != NULL))
        r = invoke_fun(c, func_type, func, args + arg_offset, i, "", !bare);
      else
        r = codegen_call(c, func_type, func, args + arg_offset, i, !bare);

      if(is_new_call)
      {
        LLVMValueRef md = LLVMMDNodeInContext(c->context, NULL, 0);
        LLVMSetMetadataStr(r, "pony.newcall", md);
      }

      codegen_debugloc(c, NULL);
      ponyint_pool_free_size(buf_size, params);
    }
  }

  // Bare methods with None return type return void, special case a None return
  // value.
  if(bare && is_none(m->result->ast))
    r = c->none_instance;

  // Class constructors return void, expression result is the receiver.
  if(((ast_id(postfix) == TK_NEWREF) || (ast_id(postfix) == TK_NEWBEREF)) &&
     (t->underlying == TK_CLASS))
    r = args[0];

  // Chained methods forward their receiver.
  if((ast_id(postfix) == TK_BECHAIN) || (ast_id(postfix) == TK_FUNCHAIN))
    r = args[0];

  ponyint_pool_free_size(buf_size, args);
  return r;
}

LLVMValueRef gen_pattern_eq(compile_t* c, ast_t* pattern, LLVMValueRef r_value)
{
  // This is used for structural equality in pattern matching.
  ast_t* pattern_type = deferred_reify(c->frame->reify, ast_type(pattern),
    c->opt);

  if(ast_id(pattern_type) == TK_NOMINAL)
  {
    AST_GET_CHILDREN(pattern_type, package, id);

    // Special case equality on primitive types.
    if(ast_name(package) == c->str_builtin)
    {
      const char* name = ast_name(id);

      if((name == c->str_Bool) ||
        (name == c->str_I8) ||
        (name == c->str_I16) ||
        (name == c->str_I32) ||
        (name == c->str_I64) ||
        (name == c->str_I128) ||
        (name == c->str_ILong) ||
        (name == c->str_ISize) ||
        (name == c->str_U8) ||
        (name == c->str_U16) ||
        (name == c->str_U32) ||
        (name == c->str_U64) ||
        (name == c->str_U128) ||
        (name == c->str_ULong) ||
        (name == c->str_USize) ||
        (name == c->str_F32) ||
        (name == c->str_F64)
        )
      {
        ast_free_unattached(pattern_type);
        return gen_eq_rvalue(c, pattern, r_value, true);
      }
    }
  }

  // Generate the receiver.
  LLVMValueRef l_value = gen_expr(c, pattern);
  reach_type_t* t = reach_type(c->reach, pattern_type);
  pony_assert(t != NULL);

  // Static or virtual dispatch.
  token_id cap = cap_dispatch(pattern_type);
  reach_method_t* m = reach_method(t, cap, c->str_eq, NULL);
  LLVMValueRef func = dispatch_function(c, t, m, l_value);

  ast_free_unattached(pattern_type);

  if(func == NULL)
    return NULL;

  // Call the function. We know it isn't partial.
  LLVMTypeRef func_type = LLVMGlobalGetValueType(func);
  LLVMValueRef args[2];
  args[0] = l_value;
  args[1] = r_value;

  codegen_debugloc(c, pattern);
  LLVMValueRef result = codegen_call(c, func_type, func, args, 2, true);
  codegen_debugloc(c, NULL);

  return result;
}

static LLVMTypeRef ffi_return_type(compile_t* c, reach_type_t* t,
  bool intrinsic)
{
  compile_type_t* c_t = (compile_type_t*)t->c_type;

  if(t->underlying == TK_TUPLETYPE)
  {
    (void)intrinsic;
    pony_assert(intrinsic);

    // Can't use the named type. Build an unnamed type with the same elements.
    unsigned int count = LLVMCountStructElementTypes(c_t->use_type);
    size_t buf_size = count * sizeof(LLVMTypeRef);
    LLVMTypeRef* e_types = (LLVMTypeRef*)ponyint_pool_alloc_size(buf_size);
    LLVMGetStructElementTypes(c_t->use_type, e_types);

    ast_t* child = ast_child(t->ast);
    size_t i = 0;

    while(child != NULL)
    {
      // A Bool in an intrinsic tuple return type is an i1.
      if(is_bool(child))
        e_types[i] = c->i1;

      child = ast_sibling(child);
      i++;
    }

    LLVMTypeRef r_type = LLVMStructTypeInContext(c->context, e_types, count,
      false);
    ponyint_pool_free_size(buf_size, e_types);
    return r_type;
  } else if(is_none(t->ast_cap)) {
    return c->void_type;
  } else {
    return c_t->use_type;
  }
}

static LLVMValueRef declare_ffi(compile_t* c, const char* f_name,
  reach_type_t* t, ast_t* args, bool intrinsic)
{
  bool is_varargs = false;
  ast_t* last_arg = ast_childlast(args);
  int param_count = (int)ast_childcount(args);

  if((last_arg != NULL) && (ast_id(last_arg) == TK_ELLIPSIS))
  {
    is_varargs = true;
    param_count--;
  }

  size_t buf_size = 0;
  LLVMTypeRef* f_params = NULL;
  // Don't allocate argument list if all arguments are optional
  if(param_count != 0)
  {
    buf_size = param_count * sizeof(LLVMTypeRef);
    f_params = (LLVMTypeRef*)ponyint_pool_alloc_size(buf_size);
    param_count = 0;

    ast_t* arg = ast_child(args);

    deferred_reification_t* reify = c->frame->reify;

    while((arg != NULL) && (ast_id(arg) != TK_ELLIPSIS))
    {
      ast_t* p_type = ast_type(arg);

      if(p_type == NULL)
        p_type = ast_childidx(arg, 1);

      p_type = deferred_reify(reify, p_type, c->opt);
      reach_type_t* pt = reach_type(c->reach, p_type);
      pony_assert(pt != NULL);
      f_params[param_count++] = ((compile_type_t*)pt->c_type)->use_type;
      ast_free_unattached(p_type);
      arg = ast_sibling(arg);
    }
  }

  LLVMTypeRef r_type = ffi_return_type(c, t, intrinsic);
  LLVMTypeRef f_type = LLVMFunctionType(r_type, f_params, param_count, is_varargs);
  LLVMValueRef func = LLVMAddFunction(c->module, f_name, f_type);

  if(f_params != NULL)
    ponyint_pool_free_size(buf_size, f_params);

  return func;
}

static void report_ffi_type_err(compile_t* c, ffi_decl_t* decl, ast_t* ast,
  const char* name)
{
  ast_error(c->opt->check.errors, ast,
    "conflicting calls for FFI function: %s have incompatible types",
    name);

  if(decl != NULL)
  {
    ast_error_continue(c->opt->check.errors, decl->decl, "first declaration is "
      "here");
    ast_error_continue(c->opt->check.errors, decl->call, "first call is here");
  }
}

static LLVMValueRef cast_ffi_arg(compile_t* c, ffi_decl_t* decl, ast_t* ast,
  LLVMValueRef arg, LLVMTypeRef param, const char* name)
{
  if(arg == NULL)
    return NULL;

  LLVMTypeRef arg_type = LLVMTypeOf(arg);

  if(param == arg_type)
    return arg;

  if((LLVMABISizeOfType(c->target_data, param) !=
    LLVMABISizeOfType(c->target_data, arg_type)))
  {
    report_ffi_type_err(c, decl, ast, name);
    return NULL;
  }

  switch(LLVMGetTypeKind(param))
  {
    case LLVMPointerTypeKind:
      if(LLVMGetTypeKind(arg_type) == LLVMIntegerTypeKind)
        return LLVMBuildIntToPtr(c->builder, arg, param, "");
      else
        return arg;

    case LLVMIntegerTypeKind:
      if(LLVMGetTypeKind(arg_type) == LLVMPointerTypeKind)
        return LLVMBuildPtrToInt(c->builder, arg, param, "");

      break;

    case LLVMStructTypeKind:
      pony_assert(LLVMGetTypeKind(arg_type) == LLVMStructTypeKind);
      return arg;

    default: {}
  }

  pony_assert(false);
  return NULL;
}

LLVMValueRef gen_ffi(compile_t* c, ast_t* ast)
{
  AST_GET_CHILDREN(ast, id, typeargs, args, named_args, can_err);
  bool err = (ast_id(can_err) == TK_QUESTION);

  // Get the function name, +1 to skip leading @
  const char* f_name = ast_name(id) + 1;

  deferred_reification_t* reify = c->frame->reify;

  // Get the return type.
  ast_t* type = deferred_reify(reify, ast_type(ast), c->opt);
  reach_type_t* t = reach_type(c->reach, type);
  pony_assert(t != NULL);
  ast_free_unattached(type);

  // Get the function. First check if the name is in use by a global and error
  // if it's the case.
  ffi_decl_t* ffi_decl;
  bool is_func = false;
  LLVMValueRef func = LLVMGetNamedGlobal(c->module, f_name);

  if(func == NULL)
  {
    func = LLVMGetNamedFunction(c->module, f_name);
    is_func = true;
  }

  if(func == NULL)
  {
    // Prototypes are mandatory, the declaration is already stored.
    ast_t* decl = (ast_t*)ast_data(ast);
    pony_assert(decl != NULL);

    bool is_intrinsic = (!strncmp(f_name, "llvm.", 5) || !strncmp(f_name, "internal.", 9));
    AST_GET_CHILDREN(decl, decl_id, decl_ret, decl_params, decl_named_params, decl_err);
    err = (ast_id(decl_err) == TK_QUESTION);
    func = declare_ffi(c, f_name, t, decl_params, is_intrinsic);

    size_t index = HASHMAP_UNKNOWN;

#ifndef PONY_NDEBUG
    ffi_decl_t k;
    k.func = func;

    ffi_decl = ffi_decls_get(&c->ffi_decls, &k, &index);
    pony_assert(ffi_decl == NULL);
#endif

    ffi_decl = POOL_ALLOC(ffi_decl_t);
    ffi_decl->func = func;
    ffi_decl->decl = decl;
    ffi_decl->call = ast;

    ffi_decls_putindex(&c->ffi_decls, ffi_decl, index);
  } else {
    ffi_decl_t k;
    k.func = func;
    size_t index = HASHMAP_UNKNOWN;

    ffi_decl = ffi_decls_get(&c->ffi_decls, &k, &index);

    if((ffi_decl == NULL) && (!is_func || LLVMHasMetadataStr(func, "pony.abi")))
    {
      ast_error(c->opt->check.errors, ast, "cannot use '%s' as an FFI name: "
        "name is already in use by the internal ABI", f_name);
      return NULL;
    }

    pony_assert(is_func);
  }

  // Generate the arguments.
  int count = (int)ast_childcount(args);
  size_t buf_size = count * sizeof(LLVMValueRef);
  LLVMValueRef* f_args = (LLVMValueRef*)ponyint_pool_alloc_size(buf_size);

  LLVMTypeRef f_type = LLVMGlobalGetValueType(func);
  LLVMTypeRef* f_params = NULL;
  bool vararg = (LLVMIsFunctionVarArg(f_type) != 0);

  if(!vararg)
  {
    if(count != (int)LLVMCountParamTypes(f_type))
    {
      ast_error(c->opt->check.errors, ast,
        "conflicting declarations for FFI function: declarations have an "
        "incompatible number of parameters");

      if(ffi_decl != NULL)
        ast_error_continue(c->opt->check.errors, ffi_decl->decl, "first "
          "declaration is here");

      return NULL;
    }

    f_params = (LLVMTypeRef*)ponyint_pool_alloc_size(buf_size);
    LLVMGetParamTypes(f_type, f_params);
  }

  ast_t* arg = ast_child(args);

  for(int i = 0; i < count; i++)
  {
    f_args[i] = gen_expr(c, arg);

    if(!vararg)
      f_args[i] = cast_ffi_arg(c, ffi_decl, ast, f_args[i], f_params[i],
        "parameters");

    if(f_args[i] == NULL)
    {
      ponyint_pool_free_size(buf_size, f_args);
      return NULL;
    }

    arg = ast_sibling(arg);
  }

  // If we can error out and we have an invoke target, generate an invoke
  // instead of a call.
  LLVMValueRef result;
  codegen_debugloc(c, ast);

  if(err && (c->frame->invoke_target != NULL))
    result = invoke_fun(c, f_type, func, f_args, count, "", false);
  else
    result = LLVMBuildCall2(c->builder, f_type, func, f_args, count, "");

  codegen_debugloc(c, NULL);
  ponyint_pool_free_size(buf_size, f_args);

  if(!vararg)
    ponyint_pool_free_size(buf_size, f_params);

  compile_type_t* c_t = (compile_type_t*)t->c_type;

  // Special case a None return value, which is used for void functions.
  bool isnone = is_none(t->ast);
  bool isvoid = LLVMGetReturnType(f_type) == c->void_type;

  if(isnone && isvoid)
  {
    result = c_t->instance;
  } else if(isnone != isvoid) {
    report_ffi_type_err(c, ffi_decl, ast, "return values");
    return NULL;
  }

  result = cast_ffi_arg(c, ffi_decl, ast, result, c_t->use_type,
    "return values");
  result = gen_assign_cast(c, c_t->use_type, result, t->ast_cap);

  return result;
}

LLVMValueRef gencall_runtime(compile_t* c, const char *name,
  LLVMValueRef* args, int count, const char* ret)
{
  LLVMValueRef func = LLVMGetNamedFunction(c->module, name);
  LLVMTypeRef func_type = LLVMGlobalGetValueType(func);

  pony_assert(func != NULL);

  return LLVMBuildCall2(c->builder, func_type, func, args, count, ret);
}

LLVMValueRef gencall_create(compile_t* c, reach_type_t* t, ast_t* call)
{
  compile_type_t* c_t = (compile_type_t*)t->c_type;

  // If it's statically known that the calling actor can't possibly capture a
  // reference to the new actor, because the result value of the constructor
  // call is discarded at the immediate syntax level, we can make certain
  // optimizations related to the actor reference count and the cycle detector.
  bool no_inc_rc = call && !is_result_needed(call);

  LLVMValueRef args[3];
  args[0] = codegen_ctx(c);
  args[1] = c_t->desc;
  args[2] = LLVMConstInt(c->i1, no_inc_rc ? 1 : 0, false);

  return gencall_runtime(c, "pony_create", args, 3, "");
}

LLVMValueRef gencall_alloc(compile_t* c, reach_type_t* t, ast_t* call)
{
  compile_type_t* c_t = (compile_type_t*)t->c_type;

  // Do nothing for primitives.
  if(c_t->primitive != NULL)
    return NULL;

  // Do nothing for Pointer and NullablePointer.
  if(is_pointer(t->ast) || is_nullable_pointer(t->ast))
    return NULL;

  // Use the global instance if we have one.
  if(c_t->instance != NULL)
    return c_t->instance;

  if(t->underlying == TK_ACTOR)
    return gencall_create(c, t, call);

  return gencall_allocstruct(c, t);
}

LLVMValueRef gencall_allocstruct(compile_t* c, reach_type_t* t)
{
  // We explicitly want a boxed version.
  // Allocate the object.
  LLVMValueRef args[3];
  args[0] = codegen_ctx(c);

  LLVMValueRef result;
  compile_type_t* c_t = (compile_type_t*)t->c_type;

  size_t size = c_t->abi_size;
  if(size == 0)
    size = 1;

  if(size <= HEAP_MAX)
  {
    uint32_t index = ponyint_heap_index(size);
    args[1] = LLVMConstInt(c->i32, index, false);
    if(c_t->final_fn == NULL)
      result = gencall_runtime(c, "pony_alloc_small", args, 2, "");
    else
      result = gencall_runtime(c, "pony_alloc_small_final", args, 2, "");
  } else {
    args[1] = LLVMConstInt(c->intptr, size, false);
    if(c_t->final_fn == NULL)
      result = gencall_runtime(c, "pony_alloc_large", args, 2, "");
    else
      result = gencall_runtime(c, "pony_alloc_large_final", args, 2, "");
  }

  set_descriptor(c, t, result);

  return result;
}

void gencall_error(compile_t* c)
{
  LLVMValueRef func = LLVMGetNamedFunction(c->module, "pony_error");
  LLVMTypeRef func_type = LLVMGlobalGetValueType(func);

  if(c->frame->invoke_target != NULL)
    invoke_fun(c, func_type, func, NULL, 0, "", false);
  else
    LLVMBuildCall2(c->builder, func_type, func, NULL, 0, "");

  LLVMBuildUnreachable(c->builder);
}

void gencall_memcpy(compile_t* c, LLVMValueRef dst, LLVMValueRef src,
  LLVMValueRef n)
{
  LLVMValueRef func = LLVMMemcpy(c->module, target_is_ilp32(c->opt->triple));
  LLVMTypeRef func_type = LLVMGlobalGetValueType(func);

  LLVMValueRef args[4];
  args[0] = dst;
  args[1] = src;
  args[2] = n;
  args[3] = LLVMConstInt(c->i1, 0, false);
  LLVMBuildCall2(c->builder, func_type, func, args, 4, "");
}

void gencall_memmove(compile_t* c, LLVMValueRef dst, LLVMValueRef src,
  LLVMValueRef n)
{
  LLVMValueRef func = LLVMMemmove(c->module, target_is_ilp32(c->opt->triple));
  LLVMTypeRef func_type = LLVMGlobalGetValueType(func);

  LLVMValueRef args[5];
  args[0] = dst;
  args[1] = src;
  args[2] = n;
  args[3] = LLVMConstInt(c->i1, 0, false);
  LLVMBuildCall2(c->builder, func_type, func, args, 4, "");
}

void gencall_lifetime_start(compile_t* c, LLVMValueRef ptr, LLVMTypeRef type)
{
  LLVMValueRef func = LLVMLifetimeStart(c->module, c->ptr);
  LLVMTypeRef func_type = LLVMGlobalGetValueType(func);
  size_t size = (size_t)LLVMABISizeOfType(c->target_data, type);

  LLVMValueRef args[2];
  args[0] = LLVMConstInt(c->i64, size, false);
  args[1] = ptr;
  LLVMBuildCall2(c->builder, func_type, func, args, 2, "");
}

void gencall_lifetime_end(compile_t* c, LLVMValueRef ptr, LLVMTypeRef type)
{
  LLVMValueRef func = LLVMLifetimeEnd(c->module, c->ptr);
  LLVMTypeRef func_type = LLVMGlobalGetValueType(func);
  size_t size = (size_t)LLVMABISizeOfType(c->target_data, type);

  LLVMValueRef args[2];
  args[0] = LLVMConstInt(c->i64, size, false);
  args[1] = ptr;
  LLVMBuildCall2(c->builder, func_type, func, args, 2, "");
}
