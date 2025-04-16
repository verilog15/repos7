#ifndef TOKEN_H
#define TOKEN_H

#include <platform.h>

#include "lexint.h"
#include "source.h"
#include "../libponyrt/pony.h"
#include <stdbool.h>
#include <stddef.h>

PONY_EXTERN_C_BEGIN

typedef struct token_t token_t;

typedef struct token_signature_t token_signature_t;

typedef enum token_id
{
  TK_EOF,
  TK_LEX_ERROR,
  TK_NONE,

  // Literals
  TK_TRUE,
  TK_FALSE,
  TK_STRING,
  TK_INT,
  TK_FLOAT,
  TK_ID,

  // Symbols
  TK_LBRACE,
  TK_RBRACE,
  TK_LPAREN,
  TK_RPAREN,
  TK_LSQUARE,
  TK_RSQUARE,
  TK_BACKSLASH,

  TK_COMMA,
  TK_ARROW,
  TK_DBLARROW,
  TK_DOT,
  TK_TILDE,
  TK_CHAIN,
  TK_COLON,
  TK_SEMI,
  TK_ASSIGN,

  TK_PLUS,
  TK_PLUS_TILDE,
  TK_MINUS,
  TK_MINUS_TILDE,
  TK_MULTIPLY,
  TK_MULTIPLY_TILDE,
  TK_DIVIDE,
  TK_DIVIDE_TILDE,
  TK_REM,
  TK_REM_TILDE,
  TK_MOD,
  TK_MOD_TILDE,
  TK_AT,
  TK_AT_LBRACE,

  TK_LSHIFT,
  TK_LSHIFT_TILDE,
  TK_RSHIFT,
  TK_RSHIFT_TILDE,

  TK_LT,
  TK_LT_TILDE,
  TK_LE,
  TK_LE_TILDE,
  TK_GE,
  TK_GE_TILDE,
  TK_GT,
  TK_GT_TILDE,

  TK_EQ,
  TK_EQ_TILDE,
  TK_NE,
  TK_NE_TILDE,

  TK_PIPE,
  TK_ISECTTYPE,
  TK_EPHEMERAL,
  TK_ALIASED,
  TK_SUBTYPE,

  TK_QUESTION,
  TK_UNARY_MINUS,
  TK_UNARY_MINUS_TILDE,
  TK_ELLIPSIS,
  TK_CONSTANT,

  // Newline symbols, only used by lexer and parser
  TK_LPAREN_NEW,
  TK_LSQUARE_NEW,
  TK_MINUS_NEW,
  TK_MINUS_TILDE_NEW,

  // Keywords
  TK_COMPILE_INTRINSIC,

  TK_USE,
  TK_TYPE,
  TK_INTERFACE,
  TK_TRAIT,
  TK_PRIMITIVE,
  TK_STRUCT,
  TK_CLASS,
  TK_ACTOR,
  TK_OBJECT,
  TK_LAMBDA,
  TK_BARELAMBDA,

  TK_AS,
  TK_IS,
  TK_ISNT,

  TK_VAR,
  TK_LET,
  TK_EMBED,
  TK_DONTCARE,
  TK_NEW,
  TK_FUN,
  TK_BE,

  TK_ISO,
  TK_TRN,
  TK_REF,
  TK_VAL,
  TK_BOX,
  TK_TAG,

  TK_CAP_READ,
  TK_CAP_SEND,
  TK_CAP_SHARE,
  TK_CAP_ALIAS,
  TK_CAP_ANY,

  TK_THIS,
  TK_RETURN,
  TK_BREAK,
  TK_CONTINUE,
  TK_CONSUME,
  TK_RECOVER,

  TK_IF,
  TK_IFDEF,
  TK_IFTYPE,
  TK_IFTYPE_SET,
  TK_THEN,
  TK_ELSE,
  TK_ELSEIF,
  TK_END,
  TK_WHILE,
  TK_DO,
  TK_REPEAT,
  TK_UNTIL,
  TK_FOR,
  TK_IN,
  TK_MATCH,
  TK_WHERE,
  TK_TRY,
  TK_TRY_NO_CHECK,
  TK_WITH,
  TK_ERROR,
  TK_COMPILE_ERROR,

  TK_NOT,
  TK_AND,
  TK_OR,
  TK_XOR,

  TK_DIGESTOF,
  TK_ADDRESS,
  TK_LOCATION,

  // Abstract tokens which don't directly appear in the source
  TK_PROGRAM,
  TK_PACKAGE,
  TK_MODULE,

  TK_MEMBERS,
  TK_FVAR,
  TK_FLET,
  TK_FFIDECL,
  TK_FFICALL,

  TK_IFDEFAND,
  TK_IFDEFOR,
  TK_IFDEFNOT,
  TK_IFDEFFLAG,

  TK_PROVIDES,
  TK_UNIONTYPE,
  TK_TUPLETYPE,
  TK_NOMINAL,
  TK_THISTYPE,
  TK_FUNTYPE,
  TK_LAMBDATYPE,
  TK_BARELAMBDATYPE,
  TK_DONTCARETYPE,
  TK_INFERTYPE,
  TK_ERRORTYPE,

  TK_LITERAL, // A literal expression whose type is not yet inferred
  TK_LITERALBRANCH, // Literal branch of a control structure
  TK_OPERATORLITERAL, // Operator function access to a literal

  TK_TYPEPARAMS,
  TK_TYPEPARAM,
  TK_PARAMS,
  TK_PARAM,
  TK_TYPEARGS,
  TK_VALUEFORMALPARAM,
  TK_VALUEFORMALARG,
  TK_POSITIONALARGS,
  TK_NAMEDARGS,
  TK_NAMEDARG,
  TK_UPDATEARG,
  TK_LAMBDACAPTURES,
  TK_LAMBDACAPTURE,

  TK_SEQ,
  TK_QUALIFY,
  TK_CALL,
  TK_TUPLE,
  TK_ARRAY,
  TK_CASES,
  TK_CASE,
  TK_MATCH_CAPTURE,
  TK_MATCH_DONTCARE,

  TK_REFERENCE,
  TK_PACKAGEREF,
  TK_TYPEREF,
  TK_TYPEPARAMREF,
  TK_NEWREF,
  TK_NEWBEREF,
  TK_BEREF,
  TK_FUNREF,
  TK_FVARREF,
  TK_FLETREF,
  TK_EMBEDREF,
  TK_TUPLEELEMREF,
  TK_VARREF,
  TK_LETREF,
  TK_PARAMREF,
  TK_DONTCAREREF,
  TK_NEWAPP,
  TK_BEAPP,
  TK_FUNAPP,
  TK_BECHAIN,
  TK_FUNCHAIN,

  TK_ANNOTATION,

  TK_DISPOSING_BLOCK,

  // Pseudo tokens that never actually exist
  TK_NEWLINE,  // Used by parser macros
  TK_FLATTEN,  // Used by parser macros for tree building

  // Token types for testing
  TK_TEST_NO_SEQ,
  TK_TEST_SEQ_SCOPE,
  TK_TEST_TRY_NO_CHECK,
  TK_TEST_ALIASED,
  TK_TEST_UPDATEARG,
  TK_TEST_EXTRA
} token_id;


/** Create a new token.
  * The created token must be freed later with token_free().
  */
token_t* token_new(token_id id);

/** Create a duplicate of the given token.
  * The duplicate must be freed later with token_free().
  */
token_t* token_dup(token_t* token);

/** Create a duplicate of the given token and set the ID.
  * The duplicate must be freed later with token_free().
  * This is equivalent to calling token_dup() followed by token_set_id().
  */
token_t* token_dup_new_id(token_t* token, token_id id);

/** Free the given token.
  * The token argument may be NULL.
  */
void token_free(token_t* token);

/// Set the token as read-only.
void token_freeze(token_t* token);

/// Get a pony_type_t for token_t. Should only be used for signature computation.
pony_type_t* token_signature_pony_type();

/// Get a pony_type_t for a docstring token_t. Should only be used for signature
/// computation.
pony_type_t* token_docstring_signature_pony_type();

/// Get a pony_type_t for token_t. Should only be used for serialisation.
pony_type_t* token_pony_type();


// Read accessors

/// Report the given token's ID
token_id token_get_id(token_t* token);

/** Report the given token's literal value.
 * Only valid for TK_STRING and TK_ID tokens.
 * The returned string must not be deleted and is valid for the lifetime of the
 * token.
 */
const char* token_string(token_t* token);

/** Report the given token's literal string length.
  * Only valid for TK_STRING and TK_ID tokens.
  */
size_t token_string_len(token_t* token);

/// Report the given token's literal value. Only valid for TK_FLOAT tokens.
double token_float(token_t* token);

/// Report the given token's literal value. Only valid for TK_INT tokens.
lexint_t* token_int(token_t* token);

/** Return a string for printing the given token.
 * The returned string must not be deleted and is valid for the lifetime of the
 * token.
 */
const char* token_print(token_t* token);

/** Return a string for printing the given token (escaping ", \, and NULL).
 * The returned string should be deleted when the caller is done with it.
 */
char* token_print_escaped(token_t* token);

/** Return a string to describe the given token id.
* The returned string must not be deleted and is valid indefinitely.
*/
const char* token_id_desc(token_id id);

/// Report the source the given token was loaded from
source_t* token_source(token_t* token);

/// Report the line number the given token was found at
size_t token_line_number(token_t* token);

/// Report the position within the line that the given token was found at
size_t token_line_position(token_t* token);

/// Report whether debug info should be generated.
bool token_debug(token_t* token);


// Write accessors

/** Set the ID of the given token to the specified value.
  * Must not used to change tokens to TK_ID or from TK_INT or TK_FLOAT.
  */
void token_set_id(token_t* token, token_id id);

/** Set the given token's literal value.
  * Only valid for TK_STRING and TK_ID tokens.
  * The given string will be interned and hence only needs to be valid for the
  * duration of this call.
  * If the given string is nul terminated then 0 may be passed for length, in
  * which case strlen will be called on the string.
  */
void token_set_string(token_t* token, const char* value, size_t length);

/// Set the given token's literal value. Only valid for TK_FLOAT tokens.
void token_set_float(token_t* token, double value);

/// Set the given token's literal value. Only valid for TK_INT tokens.
void token_set_int(token_t* token, lexint_t* value);

/// Set the given token's position within its source file and optionally the
/// source file.
/// Set source to NULL to keep current file.
void token_set_pos(token_t* token, source_t* source, size_t line, size_t pos);

/// Set whether debug info should be generated.
void token_set_debug(token_t* token, bool state);

PONY_EXTERN_C_END
#endif
