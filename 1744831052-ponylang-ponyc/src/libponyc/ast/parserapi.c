#include "parserapi.h"
#include "../../libponyrt/mem/pool.h"
#include "ponyassert.h"
#include <stdlib.h>
#include <stdio.h>


struct parser_t
{
  source_t* source;
  lexer_t* lexer;
  token_t* token;
  token_t* last_token;
  const char* last_matched;
  uint32_t next_flags;  // Data flags to set on the next token created
  bool free_last_token;
  bool failed;
  errors_t* errors;
  bool trace_enable;
};


static token_id current_token_id(parser_t* parser)
{
  return token_get_id(parser->token);
}


static void fetch_next_lexer_token(parser_t* parser, bool free_last_token)
{
  token_t* old_token = parser->token;
  token_t* new_token = lexer_next(parser->lexer);

  if(old_token != NULL && token_get_id(new_token) == TK_EOF)
  {
    // Use location of last token for EOF to get better error reporting
    token_set_pos(new_token, token_source(old_token),
      token_line_number(old_token), token_line_position(old_token));
  }

  if(old_token != NULL)
  {
    if(parser->free_last_token)
      token_free(parser->last_token);

    parser->free_last_token = free_last_token;
    parser->last_token = old_token;
  }

  parser->token = new_token;
}


static ast_t* consume_token(parser_t* parser)
{
  ast_t* ast = ast_token(parser->token);
  ast_setflag(ast, parser->next_flags);
  parser->next_flags = 0;
  fetch_next_lexer_token(parser, false);
  return ast;
}


static void consume_token_no_ast(parser_t* parser)
{
  fetch_next_lexer_token(parser, true);
}


static void syntax_error(parser_t* parser, const char* expected,
  ast_t* ast, const char* terminating)
{
  pony_assert(parser != NULL);
  pony_assert(expected != NULL);
  pony_assert(parser->token != NULL);

  if(parser->last_matched == NULL)
  {
    error(parser->errors, parser->source, token_line_number(parser->token),
      token_line_position(parser->token), "syntax error: no code found");
  }
  else
  {
    if(terminating == NULL)
    {
      error(parser->errors, parser->source, token_line_number(parser->token),
        token_line_position(parser->token),
        "syntax error: expected %s after %s", expected, parser->last_matched);
    }
    else
    {
      pony_assert(ast != NULL);
      ast_error(parser->errors, ast, "syntax error: unterminated %s",
        terminating);
      error_continue(parser->errors, parser->source,
        token_line_number(parser->token),
        token_line_position(parser->token),
        "expected terminating %s before here", expected);
    }
  }
}


// Standard build functions

static void default_builder(rule_state_t* state, ast_t* new_ast)
{
  pony_assert(state != NULL);
  pony_assert(new_ast != NULL);

  // Existing AST goes at the top

  if(ast_id(new_ast) == TK_FLATTEN)
  {
    // Add the children of the new node, not the node itself
    ast_t* new_child;

    while((new_child = ast_pop(new_ast)) != NULL)
      default_builder(state, new_child);

    ast_free(new_ast);
    return;
  }

  if(state->last_child == NULL)  // No valid last pointer
    ast_append(state->ast, new_ast);
  else  // Add new AST to end of children
    ast_add_sibling(state->last_child, new_ast);

  state->last_child = new_ast;
}


void infix_builder(rule_state_t* state, ast_t* new_ast)
{
  pony_assert(state != NULL);
  pony_assert(new_ast != NULL);

  // New AST goes at the top
  ast_add(new_ast, state->ast);
  state->ast = new_ast;
  state->last_child = NULL;
}


void infix_reverse_builder(rule_state_t* state, ast_t* new_ast)
{
  pony_assert(state != NULL);
  pony_assert(new_ast != NULL);

  // New AST goes at the top, existing goes on the right
  ast_append(new_ast, state->ast);
  state->ast = new_ast;

  // state->last_child is actually still valid, so leave it
}


static void annotation_builder(rule_state_t* state, ast_t* new_ast)
{
  pony_assert(state != NULL);
  pony_assert(new_ast != NULL);

  ast_setannotation(state->ast, new_ast);
}


// Functions called by macros

// Process any deferred token we have
static void process_deferred_ast(parser_t* parser, rule_state_t* state)
{
  pony_assert(parser != NULL);
  pony_assert(state != NULL);

  if(state->deferred)
  {
    token_t* deferred_token = token_new(state->deferred_id);
    token_set_pos(deferred_token, parser->source, state->line, state->pos);
    state->ast = ast_token(deferred_token);
    state->deferred = false;
  }
}


// Add the given AST to ours, handling deferment
static void add_ast(parser_t* parser, rule_state_t* state, ast_t* new_ast,
  builder_fn_t build_fn)
{
  pony_assert(parser != NULL);
  pony_assert(state != NULL);
  pony_assert(new_ast != NULL && new_ast != PARSE_ERROR);
  pony_assert(build_fn != NULL);

  process_deferred_ast(parser, state);

  if(state->ast == NULL)
  {
    // The new AST is our only AST so far
    state->ast = new_ast;
    state->last_child = NULL;
  }
  else
  {
    // Add the new AST to our existing AST
    build_fn(state, new_ast);
  }
}


// Add an AST node for the specified token, which may be deferred
void add_deferrable_ast(parser_t* parser, rule_state_t* state, token_id id,
  token_t* token_for_pos)
{
  if(token_for_pos == NULL)
    token_for_pos = parser->token;

  pony_assert(token_for_pos != NULL);

  if(!state->matched && state->ast == NULL && !state->deferred)
  {
    // This is the first AST node, defer creation
    state->deferred = true;
    state->deferred_id = id;
    state->line = token_line_number(token_for_pos);
    state->pos = token_line_position(token_for_pos);
    return;
  }

  add_ast(parser, state, ast_new(token_for_pos, id), default_builder);
}


// Ditch tokens until a legal one is found
// The token set must be TK_NONE terminated
static void ditch_restart(parser_t* parser, rule_state_t* state)
{
  pony_assert(parser != NULL);
  pony_assert(state != NULL);
  pony_assert(state->restart != NULL);

  if(parser->trace_enable)
    fprintf(stderr, "Rule %s: Attempting recovery:\n", state->fn_name);

  while(true)
  {
    token_id id = current_token_id(parser);

    for(const token_id* p = state->restart; *p != TK_NONE; p++)
    {
      if(*p == id)
      {
        // Legal token found
        if(parser->trace_enable)
          fprintf(stderr, "  recovered with %s\n", token_print(parser->token));

        return;
      }
    }

    // Current token is not in legal set, ditch it
    if(parser->trace_enable)
      fprintf(stderr, "  ignoring %d %s %s\n", id, lexer_print(id),
        token_print(parser->token));

    consume_token_no_ast(parser);
  }
}


// Propgate an error, handling AST tidy up and restart points
static ast_t* propogate_error(parser_t* parser, rule_state_t* state)
{
  pony_assert(parser != NULL);
  pony_assert(state != NULL);

  ast_free(state->ast);
  state->ast = NULL;
  parser->failed = true;

  if(state->restart == NULL)
  {
    if(parser->trace_enable)
      fprintf(stderr, "Rule %s: Propagate failure\n", state->fn_name);

    return PARSE_ERROR;
  }

  ditch_restart(parser, state);
  return NULL;
}


/* Process the result from finding a token or sub rule.
 * Args:
 *    new_ast AST generate from found token or sub rule, NULL for none.
 *    out_found reports whether an optional token was found. Only set on
 *      success. May be set to NULL if this information is not needed.
 *
 * Returns:
 *    PARSE_OK
 */
static ast_t* handle_found(parser_t* parser, rule_state_t* state,
  ast_t* new_ast, builder_fn_t build_fn, bool* out_found)
{
  pony_assert(parser != NULL);
  pony_assert(state != NULL);

  if(out_found != NULL)
    *out_found = true;

  if(!state->matched)
  {
    // First token / sub rule in rule was found
    if(parser->trace_enable)
      fprintf(stderr, "Rule %s: Matched\n", state->fn_name);

    state->matched = true;
  }

  if(new_ast != NULL)
    add_ast(parser, state, new_ast, build_fn);

  state->deflt_id = TK_LEX_ERROR;
  return PARSE_OK;
}


/* Process the result from not finding a token or sub rule.
* Args:
*    out_found reports whether an optional token was found. Only set on
*      success. May be set to NULL if this information is not needed.
*
* Returns:
 *    PARSE_OK if not error.
 *    PARSE_ERROR to propagate a lexer error.
 *    RULE_NOT_FOUND if current token is not is specified set.
*/
static ast_t* handle_not_found(parser_t* parser, rule_state_t* state,
  const char* desc, const char* terminating, bool* out_found)
{
  pony_assert(parser != NULL);
  pony_assert(state != NULL);
  pony_assert(desc != NULL);

  if(out_found != NULL)
    *out_found = false;

  if(state->deflt_id != TK_LEX_ERROR)
  {
    // Optional token / sub rule not found
    if(state->deflt_id != TK_EOF) // Default node is specified
      add_deferrable_ast(parser, state, state->deflt_id, parser->last_token);

    state->deflt_id = TK_LEX_ERROR;
    return PARSE_OK;
  }

  // Required token / sub rule not found

  if(!state->matched)
  {
    // Rule not matched
    if(parser->trace_enable)
      fprintf(stderr, "Rule %s: Not matched\n", state->fn_name);

    ast_free(state->ast);
    state->ast = NULL;
    return RULE_NOT_FOUND;
  }

  // Rule partially matched, error
  if(parser->trace_enable)
    fprintf(stderr, "Rule %s: Error\n", state->fn_name);

  syntax_error(parser, desc, state->ast, terminating);
  parser->failed = true;
  ast_free(state->ast);
  state->ast = NULL;

  if(state->restart == NULL)
    return PARSE_ERROR;

  // We have a restart point
  ditch_restart(parser, state);
  return NULL;
}


/* Check if current token matches any in given set and consume on match.
 * Args:
 *    terminating is the description of the structure this token terminates,
 *      NULL for none. Used only for error messages.
 *    id_set is a TK_NONE terminated list.
 *    make_ast specifies whether to construct an AST node on match or discard
 *      consumed token.
 *    out_found reports whether an optional token was found. Only set on
 *      success. May be set to NULL if this information is not needed.
 *
 * Returns:
 *    PARSE_OK on success.
 *    PARSE_ERROR to propagate a lexer error.
 *    RULE_NOT_FOUND if current token is not is specified set.
 *    NULL to propagate a restarted error.
 */
ast_t* parse_token_set(parser_t* parser, rule_state_t* state, const char* desc,
  const char* terminating, const token_id* id_set, bool make_ast,
  bool* out_found)
{
  pony_assert(parser != NULL);
  pony_assert(state != NULL);
  pony_assert(id_set != NULL);

  token_id id = current_token_id(parser);

  if(id == TK_LEX_ERROR)
    return propogate_error(parser, state);

  if(desc == NULL)
    desc = token_id_desc(id_set[0]);

  if(parser->trace_enable)
  {
    fprintf(stderr, "Rule %s: Looking for %s token%s %s. Found %s. ",
      state->fn_name,
      (state->deflt_id == TK_LEX_ERROR) ? "required" : "optional",
      (id_set[1] == TK_NONE) ? "" : "s", desc,
      token_print(parser->token));
  }

  for(const token_id* p = id_set; *p != TK_NONE; p++)
  {
    // Match new line if the next token is the first on a line
    if(*p == TK_NEWLINE)
    {
      pony_assert(parser->token != NULL);
      size_t last_token_line = token_line_number(parser->last_token);
      size_t next_token_line = token_line_number(parser->token);
      bool is_newline = (next_token_line != last_token_line);

      if(out_found != NULL)
        *out_found = is_newline;

      if(parser->trace_enable)
        fprintf(stderr, "\\n %smatched\n", is_newline ? "" : "not ");

      state->deflt_id = TK_LEX_ERROR;
      return PARSE_OK;
    }

    if(id == *p)
    {
      // Current token matches one in set
      if(parser->trace_enable)
        fprintf(stderr, "Compatible\n");

      parser->last_matched = token_print(parser->token);

      if(make_ast)
        return handle_found(parser, state, consume_token(parser),
          default_builder, out_found);

      // AST not needed, discard token
      consume_token_no_ast(parser);
      return handle_found(parser, state, NULL, NULL, out_found);
    }
  }

  // Current token does not match any in current set
  if(parser->trace_enable)
    fprintf(stderr, "Not compatible\n");

  return handle_not_found(parser, state, desc, terminating, out_found);
}


/* Check if any of the specified rules can be matched.
 * Args:
 *    rule_set is a NULL terminated list.
 *    out_found reports whether an optional token was found. Only set on
 *      success. May be set to NULL if this information is not needed.
 *
 * Returns:
 *    PARSE_OK on success.
 *    PARSE_ERROR to propagate an error.
 *    RULE_NOT_FOUND if no rules in given set can be matched.
 *    NULL to propagate a restarted error.
 */
ast_t* parse_rule_set(parser_t* parser, rule_state_t* state, const char* desc,
  const rule_t* rule_set, bool* out_found, bool annotate)
{
  pony_assert(parser != NULL);
  pony_assert(state != NULL);
  pony_assert(desc != NULL);
  pony_assert(rule_set != NULL);

  token_id id = current_token_id(parser);

  if(id == TK_LEX_ERROR)
    return propogate_error(parser, state);

  if(parser->trace_enable)
  {
    fprintf(stderr, "Rule %s: Looking for %s rule%s \"%s\"\n",
      state->fn_name,
      (state->deflt_id == TK_LEX_ERROR) ? "required" : "optional",
      (rule_set[1] == NULL) ? "" : "s", desc);
  }

  builder_fn_t build_fn = annotate ? annotation_builder : default_builder;
  for(const rule_t* p = rule_set; *p != NULL; p++)
  {
    ast_t* rule_ast = (*p)(parser, &build_fn, desc);

    if(rule_ast == PARSE_ERROR)
      return propogate_error(parser, state);

    if(rule_ast != RULE_NOT_FOUND)
    {
      // Rule found
      parser->last_matched = desc;
      return handle_found(parser, state, rule_ast, build_fn, out_found);
    }
  }

  // No rules in set can be matched
  return handle_not_found(parser, state, desc, NULL, out_found);
}


// Set the data flags to use for the next token consumed from the source
void parse_set_next_flags(parser_t* parser, uint32_t flags)
{
  pony_assert(parser != NULL);
  parser->next_flags = flags;
}


/* Tidy up a successfully parsed rule.
 * Args:
 *    rule_set is a NULL terminated list.
 *    out_found reports whether an optional token was found. Only set on
 *      success. May be set to NULL if this information is not needed.
 *
 * Returns:
 *    AST created, NULL for none.
 */
ast_t* parse_rule_complete(parser_t* parser, rule_state_t* state)
{
  pony_assert(parser != NULL);
  pony_assert(state != NULL);

  process_deferred_ast(parser, state);

  if(state->scope && state->ast != NULL)
    ast_scope(state->ast);

  if(parser->trace_enable)
    fprintf(stderr, "Rule %s: Complete\n", state->fn_name);

  if(state->restart == NULL)
    return state->ast;

  // We have a restart point, check next token is legal
  token_id id = current_token_id(parser);

  if(parser->trace_enable)
    fprintf(stderr, "Rule %s: Check restart set for next token %s\n",
      state->fn_name, token_print(parser->token));

  for(const token_id* p = state->restart; *p != TK_NONE; p++)
  {
    if(*p == id)
    {
      // Legal token found
      if(parser->trace_enable)
        fprintf(stderr, "Rule %s: Restart check successful\n", state->fn_name);

      return state->ast;
    }
  }

  // Next token is not in restart set, error
  if(parser->trace_enable)
    fprintf(stderr, "Rule %s: Restart check error\n", state->fn_name);

  pony_assert(parser->token != NULL);
  error(parser->errors, parser->source, token_line_number(parser->token),
    token_line_position(parser->token),
    "syntax error: unexpected token %s after %s", token_print(parser->token),
    state->desc);

  ast_free(state->ast);
  parser->failed = true;
  ditch_restart(parser, state);
  return NULL;
}


// Top level functions

bool parse(ast_t* package, source_t* source, rule_t start, const char* expected,
  errors_t* errors, bool allow_test_symbols, bool trace)
{
  pony_assert(package != NULL);
  pony_assert(source != NULL);
  pony_assert(expected != NULL);

  // Open the lexer
  lexer_t* lexer = lexer_open(source, errors, allow_test_symbols);

  if(lexer == NULL)
    return false;

  // Create a parser and attach the lexer
  parser_t* parser = POOL_ALLOC(parser_t);
  parser->source = source;
  parser->lexer = lexer;
  parser->token = lexer_next(lexer);
  parser->last_token = parser->token;
  parser->last_matched = NULL;
  parser->next_flags = 0;
  parser->free_last_token = false;
  parser->failed = false;
  parser->errors = errors;
  parser->trace_enable = trace;

  const size_t error_count = errors_get_count(errors);

  // Parse given start rule
  builder_fn_t build_fn;
  ast_t* ast = start(parser, &build_fn, expected);

  if(ast == PARSE_ERROR)
    ast = NULL;

  if(ast == RULE_NOT_FOUND)
  {
    syntax_error(parser, expected, NULL, NULL);
    ast = NULL;
  }

  if(parser->failed)
  {
    ast_free(ast);
    ast = NULL;
  }

  if(errors_get_count(errors) > error_count)
  {
    ast_free(ast);
    ast = NULL;
  }

  lexer_close(lexer);
  token_free(parser->token);
  POOL_FREE(parser_t, parser);

  if(ast == NULL)
  {
    source_close(source);
    return false;
  }

  pony_assert(ast_id(ast) == TK_MODULE);
  pony_assert(ast_data(ast) == NULL);
  ast_setdata(ast, source);
  ast_add(package, ast);
  return true;
}
