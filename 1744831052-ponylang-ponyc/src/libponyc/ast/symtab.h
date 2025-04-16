#ifndef SYMTAB_H
#define SYMTAB_H

#include <platform.h>
#include "../../libponyrt/ds/hash.h"

PONY_EXTERN_C_BEGIN

typedef struct ast_t ast_t;
typedef struct errors_t errors_t;

typedef enum
{
  SYM_NONE,
  SYM_NOCASE,
  SYM_DEFINED,
  SYM_UNDEFINED,
  SYM_CONSUMED,
  SYM_CONSUMED_SAME_EXPR,
  SYM_FFIDECL,
  SYM_ERROR
} sym_status_t;

typedef struct symbol_t
{
  const char* name;
  ast_t* def;
  sym_status_t status;
  size_t branch_count;
} symbol_t;

DECLARE_HASHMAP_SERIALISE(symtab, symtab_t, symbol_t);

bool is_type_name(const char* name);

symtab_t* symtab_new();

symtab_t* symtab_dup(symtab_t* symtab);

void symtab_free(symtab_t* symtab);

bool symtab_add(symtab_t* symtab, const char* name, ast_t* def,
  sym_status_t status);

ast_t* symtab_find(symtab_t* symtab, const char* name, sym_status_t* status);

ast_t* symtab_find_case(symtab_t* symtab, const char* name,
  sym_status_t* status);

sym_status_t symtab_get_status(symtab_t* symtab, const char* name);

void symtab_set_status(symtab_t* symtab, const char* name,
  sym_status_t status);

void symtab_inherit_status(symtab_t* dst, symtab_t* src);

void symtab_inherit_branch(symtab_t* dst, symtab_t* src);

bool symtab_can_merge_public(symtab_t* dst, symtab_t* src);

bool symtab_merge_public(symtab_t* dst, symtab_t* src);

bool symtab_check_all_defined(symtab_t* symtab, errors_t* errors);

pony_type_t* symbol_pony_type();

PONY_EXTERN_C_END

#endif
