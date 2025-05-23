/*
 * Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License").
 * You may not use this file except in compliance with the License.
 * A copy of the License is located at
 *
 *  http://aws.amazon.com/apache2.0
 *
 * or in the "license" file accompanying this file. This file is distributed
 * on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
 * express or implied. See the License for the specific language governing
 * permissions and limitations under the License.
 */

#include <errno.h>
#include <fcntl.h>

#include "api/s2n.h"
#include "crypto/s2n_fips.h"
#include "s2n_test.h"
#include "testlib/s2n_testlib.h"
#include "utils/s2n_bitmap.h"
#include "utils/s2n_safety.h"

#define S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_NANOS (S2N_TICKET_ENCRYPT_DECRYPT_KEY_LIFETIME_IN_NANOS + S2N_TICKET_DECRYPT_KEY_LIFETIME_IN_NANOS)
#define S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS  S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_NANOS / ONE_SEC_IN_NANOS
#define S2N_PARTIAL_SESSION_STATE_INFO_IN_BYTES          S2N_STATE_FORMAT_LEN + S2N_SESSION_TICKET_SIZE_LEN
#define S2N_TICKET_KEY_NAME_LOCATION                     S2N_PARTIAL_SESSION_STATE_INFO_IN_BYTES + S2N_TICKET_VERSION_SIZE
#define ONE_SEC_DELAY                                    1

#define S2N_CLOCK_SYS CLOCK_REALTIME

/**
 * This function is used to "skip" time in unit tests. It will mock the system
 * time to be current_time (ns) + data (ns). The "data" parameter is a uint64_t
 * passed in as a void*.
 */
int mock_nanoseconds_since_epoch(void *data, uint64_t *nanoseconds)
{
    struct timespec current_time;

    clock_gettime(S2N_CLOCK_SYS, &current_time);

    /**
     * current_time fields are represented as time_t, and time_t has a platform
     * dependent size. On 32 bit platforms, attempting to convert the current
     * system time to nanoseconds will overflow, causing odd failures in unit
     * tests. We upcast current_time fields to uint64_t before multiplying to
     * avoid this.
     */
    *nanoseconds = 0;
    *nanoseconds += (uint64_t) current_time.tv_sec * ONE_SEC_IN_NANOS;
    *nanoseconds += (uint64_t) current_time.tv_nsec;
    *nanoseconds += *(uint64_t *) data;

    return 0;
}

static int mock_time(void *data, uint64_t *nanoseconds)
{
    if (data) {
        *nanoseconds = *((uint64_t *) data);
    } else {
        *nanoseconds = 1000000000;
    }
    return S2N_SUCCESS;
}

uint8_t cb_session_data[S2N_TLS12_SESSION_SIZE * 2] = { 0 };
size_t cb_session_data_len = 0;
uint32_t cb_session_lifetime = 0;
static int s2n_test_session_ticket_callback(struct s2n_connection *conn, void *ctx, struct s2n_session_ticket *ticket)
{
    EXPECT_NOT_NULL(conn);
    EXPECT_NOT_NULL(ticket);

    /* Store the callback data for comparison at the end of the connection. */
    EXPECT_SUCCESS(s2n_session_ticket_get_data_len(ticket, &cb_session_data_len));
    EXPECT_SUCCESS(s2n_session_ticket_get_data(ticket, sizeof(cb_session_data), cb_session_data));
    EXPECT_SUCCESS(s2n_session_ticket_get_lifetime(ticket, &cb_session_lifetime));

    return S2N_SUCCESS;
}

/* make a struct with a ticket name and key adjacent in memory */
struct small_name_ticket {
    uint8_t name[1];
    uint8_t key[32];
};

int main(int argc, char **argv)
{
    char *cert_chain = NULL;
    char *private_key = NULL;
    struct s2n_cert_chain_and_key *chain_and_key = NULL;
    struct s2n_connection *client_conn = NULL;
    struct s2n_connection *server_conn = NULL;
    struct s2n_config *client_config = NULL;
    struct s2n_config *server_config = NULL;
    uint64_t now = 0;
    struct s2n_ticket_key *ticket_key = NULL;
    uint32_t ticket_keys_len = 0;

    size_t serialized_session_state_length = 0;
    uint8_t s2n_state_with_session_id = S2N_STATE_WITH_SESSION_ID;
    uint8_t serialized_session_state[S2N_PARTIAL_SESSION_STATE_INFO_IN_BYTES + S2N_TLS12_TICKET_SIZE_IN_BYTES + S2N_TLS12_STATE_SIZE_IN_BYTES] = { 0 };

    /* Session ticket keys. Taken from test vectors in https://tools.ietf.org/html/rfc5869 */
    uint8_t ticket_key_name1[1] = "A";
    uint8_t ticket_key_name2[4] = "BBBB";
    uint8_t ticket_key_name3[16] = "CCCCCCCCCCCCCCCC";
    uint8_t ticket_key1[32] = { 0x07, 0x77, 0x09, 0x36, 0x2c, 0x2e, 0x32, 0xdf, 0x0d, 0xdc,
        0x3f, 0x0d, 0xc4, 0x7b, 0xba, 0x63, 0x90, 0xb6, 0xc7, 0x3b,
        0xb5, 0x0f, 0x9c, 0x31, 0x22, 0xec, 0x84, 0x4a, 0xd7, 0xc2,
        0xb3, 0xe5 };
    uint8_t ticket_key2[32] = { 0x06, 0xa6, 0xb8, 0x8c, 0x58, 0x53, 0x36, 0x1a, 0x06, 0x10,
        0x4c, 0x9c, 0xeb, 0x35, 0xb4, 0x5c, 0xef, 0x76, 0x00, 0x14,
        0x90, 0x46, 0x71, 0x01, 0x4a, 0x19, 0x3f, 0x40, 0xc1, 0x5f,
        0xc2, 0x44 };
    uint8_t ticket_key3[32] = { 0x19, 0xef, 0x24, 0xa3, 0x2c, 0x71, 0x7b, 0x16, 0x7f, 0x33,
        0xa9, 0x1d, 0x6f, 0x64, 0x8b, 0xdf, 0x96, 0x59, 0x67, 0x76,
        0xaf, 0xdb, 0x63, 0x77, 0xac, 0x43, 0x4c, 0x1c, 0x29, 0x3c,
        0xcb, 0x04 };

    /* Testcases:
     * 1) Client sends empty ST extension. Server issues NST.
     * 2) Client sends empty ST extension. Server does a full handshake, but is unable to issue NST due to absence of an encrypt-decrypt key.
     * 3) Client sends non-empty ST extension. Server does an abbreviated handshake without issuing NST.
     * 4) Client sends non-empty ST extension. Server does an abbreviated handshake without issuing NST even though the key is in decrypt-only state.
     * 5) Client sends non-empty ST extension. Server does an abbreviated handshake, but does not issue a NST even though the key is in
     *    decrypt-only state due to absence of encrypt-decrypt key.
     * 6) Client sends non-empty ST extension. Server does a full handshake and issues a NST because the key is not found.
     * 7) Client sends non-empty ST extension. Server does a full handshake and issues a NST because the key has expired.
     * 8) Client sends non-empty ST extension. Server does a full handshake and issues a NST because the ticket has non-standard size.
     * 9) Client sends non-empty ST extension, but server cannot or does not want to honor the ticket.
     * 10) Client sets corrupted ST extension.
     * 11) User tries adding a duplicate key to the server.
     * 12) Testing expired keys are removed from the server config while adding new keys.
     * 13) Scenario 1: Client sends empty ST and server has multiple encrypt-decrypt keys to choose from for encrypting NST.
     * 14) Scenario 2: Client sends empty ST and server has multiple encrypt-decrypt keys to choose from for encrypting NST.
     * 15) Testing s2n_config_set_ticket_encrypt_decrypt_key_lifetime and s2n_config_set_ticket_decrypt_key_lifetime calls.
     * 16) Add keys out of order and pre-emptively add a key.
     * 17) Handshake with client auth and session ticket enabled.
     * 18) Session resumption APIs and session_ticket_cb return the same values when receiving a new ticket in TLS1.2
     * 19) Session resumption APIs and session_ticket_cb return sane values when receiving a new ticket in TLS1.3
     * 20) Client has TLS1.3 ticket but negotiates TLS1.2, so does full handshake
     */

    BEGIN_TEST();
    EXPECT_SUCCESS(s2n_disable_tls13_in_test());

    DEFER_CLEANUP(struct s2n_stuffer tls13_serialized_session_state = { 0 }, s2n_stuffer_free);
    EXPECT_SUCCESS(s2n_stuffer_growable_alloc(&tls13_serialized_session_state, 0));

    struct s2n_test_io_pair io_pair;
    EXPECT_SUCCESS(s2n_io_pair_init_non_blocking(&io_pair));

    EXPECT_NOT_NULL(cert_chain = malloc(S2N_MAX_TEST_PEM_SIZE));
    EXPECT_NOT_NULL(private_key = malloc(S2N_MAX_TEST_PEM_SIZE));
    EXPECT_SUCCESS(s2n_read_test_pem(S2N_DEFAULT_TEST_CERT_CHAIN, cert_chain, S2N_MAX_TEST_PEM_SIZE));
    EXPECT_SUCCESS(s2n_read_test_pem(S2N_DEFAULT_TEST_PRIVATE_KEY, private_key, S2N_MAX_TEST_PEM_SIZE));
    EXPECT_NOT_NULL(chain_and_key = s2n_cert_chain_and_key_new());
    EXPECT_SUCCESS(s2n_cert_chain_and_key_load_pem(chain_and_key, cert_chain, private_key));

    struct s2n_cert_chain_and_key *ecdsa_chain_and_key = NULL;
    EXPECT_SUCCESS(s2n_test_cert_chain_and_key_new(&ecdsa_chain_and_key,
            S2N_DEFAULT_ECDSA_TEST_CERT_CHAIN, S2N_DEFAULT_ECDSA_TEST_PRIVATE_KEY));

    EXPECT_SUCCESS(setenv("S2N_DONT_MLOCK", "1", 0));

    /* Test ticket name handling */
    {
        DEFER_CLEANUP(struct s2n_config *config = s2n_config_new(), s2n_config_ptr_free);
        EXPECT_NOT_NULL(config);

        /* Enable session tickets */
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(config, 1));

        /* The name should be greater than 0 and less than or equal to 16 */
        uint8_t too_large_name[17] = { 0 };
        EXPECT_FAILURE_WITH_ERRNO(s2n_config_add_ticket_crypto_key(config, too_large_name, 0, ticket_key1, s2n_array_len(ticket_key1), 0), S2N_ERR_INVALID_TICKET_KEY_NAME_OR_NAME_LENGTH);
        EXPECT_FAILURE_WITH_ERRNO(s2n_config_add_ticket_crypto_key(config, too_large_name, 17, ticket_key1, s2n_array_len(ticket_key1), 0), S2N_ERR_INVALID_TICKET_KEY_NAME_OR_NAME_LENGTH);

        /* Add a ticket with a single-byte name */
        struct small_name_ticket small = { .name = { 0xAA }, .key = { 0xBB, 0xBB, 0xBB, 0xBB } };
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(config, small.name, s2n_array_len(small.name), small.key, s2n_array_len(small.key), 0));

        /* Ensure a ticket with the same name is not added */
        struct small_name_ticket small2 = { .name = { 0xAA }, .key = { 0xCC, 0xCC, 0xCC, 0xCC } };
        EXPECT_FAILURE_WITH_ERRNO(s2n_config_add_ticket_crypto_key(config, small2.name, s2n_array_len(small2.name), small2.key, s2n_array_len(small2.key), 0), S2N_ERR_INVALID_TICKET_KEY_NAME_OR_NAME_LENGTH);

        /* Ensure a ticket with a zero-padded name is not added */
        uint8_t padded_name[16] = { 0xAA, 0 };
        EXPECT_FAILURE_WITH_ERRNO(s2n_config_add_ticket_crypto_key(config, padded_name, s2n_array_len(padded_name), ticket_key1, s2n_array_len(ticket_key1), 0), S2N_ERR_INVALID_TICKET_KEY_NAME_OR_NAME_LENGTH);
    };

    /* Client sends empty ST extension. Server issues NST. */
    {
        EXPECT_NOT_NULL(client_conn = s2n_connection_new(S2N_CLIENT));

        EXPECT_NOT_NULL(client_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(client_config, 1));
        EXPECT_SUCCESS(s2n_config_disable_x509_verification(client_config));
        EXPECT_SUCCESS(s2n_connection_set_config(client_conn, client_config));

        EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));
        EXPECT_NOT_NULL(server_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_config, 1));
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(server_config, chain_and_key));

        /* Create nonblocking pipes */
        EXPECT_SUCCESS(s2n_connections_set_io_pair(client_conn, server_conn, &io_pair));

        /* Set session state lifetime for 15 hours which is equal to the default lifetime of a ticket key */
        EXPECT_SUCCESS(s2n_config_set_session_state_lifetime(server_config, S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS));

        uint64_t mock_current_time = 0;
        EXPECT_SUCCESS(s2n_config_set_wall_clock(server_config, mock_time, &mock_current_time));

        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name2, s2n_array_len(ticket_key_name2),
                ticket_key2, s2n_array_len(ticket_key2), 0));

        EXPECT_SUCCESS(s2n_connection_set_config(server_conn, server_config));

        /* A newly created connection should not be considered resumed */
        EXPECT_FALSE(s2n_connection_is_session_resumed(server_conn));
        EXPECT_FALSE(s2n_connection_is_session_resumed(client_conn));
        EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server_conn, client_conn));

        /* Verify that the server did a full handshake and issued NST */
        EXPECT_TRUE(IS_FULL_HANDSHAKE(server_conn));
        EXPECT_TRUE(IS_ISSUING_NEW_SESSION_TICKET(server_conn));

        /* Verify that the client received NST */
        serialized_session_state_length = s2n_connection_get_session_length(client_conn);
        EXPECT_EQUAL(s2n_connection_get_session(client_conn, serialized_session_state, serialized_session_state_length), serialized_session_state_length);
        EXPECT_BYTEARRAY_EQUAL(serialized_session_state + S2N_TICKET_KEY_NAME_LOCATION,
                ticket_key_name2, s2n_array_len(ticket_key_name2));

        /* Verify the lifetime hint from the server */
        EXPECT_EQUAL(s2n_connection_get_session_ticket_lifetime_hint(client_conn), S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS);

        EXPECT_SUCCESS(s2n_shutdown_test_server_and_client(server_conn, client_conn));

        EXPECT_SUCCESS(s2n_connection_free(server_conn));
        EXPECT_SUCCESS(s2n_connection_free(client_conn));

        EXPECT_SUCCESS(s2n_config_free(server_config));
        EXPECT_SUCCESS(s2n_config_free(client_config));
    };

    /* Client sends empty ST extension. Server does a full handshake, but is unable
     * to issue NST due to absence of an encrypt-decrypt key. */
    {
        EXPECT_NOT_NULL(client_conn = s2n_connection_new(S2N_CLIENT));
        EXPECT_NOT_NULL(client_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(client_config, 1));
        EXPECT_SUCCESS(s2n_config_disable_x509_verification(client_config));
        EXPECT_SUCCESS(s2n_connection_set_config(client_conn, client_config));

        EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));
        EXPECT_NOT_NULL(server_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_config, 1));
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(server_config, chain_and_key));

        /* Create nonblocking pipes */
        EXPECT_SUCCESS(s2n_connections_set_io_pair(client_conn, server_conn, &io_pair));

        /* Set session state lifetime for 15 hours which is equal to the default lifetime of a ticket key */
        EXPECT_SUCCESS(s2n_config_set_session_state_lifetime(server_config, S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS));

        EXPECT_SUCCESS(s2n_connection_set_config(server_conn, server_config));

        EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server_conn, client_conn));

        /* Verify that the server did a full handshake and did not issue NST */
        EXPECT_TRUE(IS_FULL_HANDSHAKE(server_conn));
        EXPECT_FALSE(IS_ISSUING_NEW_SESSION_TICKET(server_conn));

        EXPECT_SUCCESS(s2n_shutdown_test_server_and_client(server_conn, client_conn));

        EXPECT_SUCCESS(s2n_connection_free(server_conn));
        EXPECT_SUCCESS(s2n_connection_free(client_conn));

        EXPECT_SUCCESS(s2n_config_free(server_config));
        EXPECT_SUCCESS(s2n_config_free(client_config));
    };

    /* Client sends non-empty ST extension. Server does an abbreviated handshake without issuing NST. */
    {
        EXPECT_NOT_NULL(client_conn = s2n_connection_new(S2N_CLIENT));

        /* Set client ST and session state */
        EXPECT_SUCCESS(s2n_connection_set_session(client_conn, serialized_session_state, serialized_session_state_length));

        EXPECT_NOT_NULL(client_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(client_config, 1));
        EXPECT_SUCCESS(s2n_connection_set_config(client_conn, client_config));

        EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));
        EXPECT_NOT_NULL(server_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_config, 1));
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(server_config, chain_and_key));

        /* Create nonblocking pipes */
        EXPECT_SUCCESS(s2n_connections_set_io_pair(client_conn, server_conn, &io_pair));

        /* Set session state lifetime for 15 hours which is equal to the default lifetime of a ticket key */
        EXPECT_SUCCESS(s2n_config_set_session_state_lifetime(server_config, S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS));

        uint64_t mock_current_time = 0;
        EXPECT_SUCCESS(s2n_config_set_wall_clock(server_config, mock_time, &mock_current_time));

        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name2, s2n_array_len(ticket_key_name2),
                ticket_key2, s2n_array_len(ticket_key2), 0));

        EXPECT_SUCCESS(s2n_connection_set_config(server_conn, server_config));

        EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server_conn, client_conn));

        /* Verify that the server did an abbreviated handshake and not issue NST */
        EXPECT_TRUE(IS_RESUMPTION_HANDSHAKE(server_conn));
        EXPECT_TRUE(s2n_connection_is_session_resumed(server_conn));
        EXPECT_FALSE(IS_ISSUING_NEW_SESSION_TICKET(server_conn));

        /* Verify that client_ticket is same as before because server didn't issue a NST */
        uint8_t old_session_ticket[S2N_PARTIAL_SESSION_STATE_INFO_IN_BYTES + S2N_TLS12_TICKET_SIZE_IN_BYTES];
        EXPECT_MEMCPY_SUCCESS(old_session_ticket, serialized_session_state, S2N_PARTIAL_SESSION_STATE_INFO_IN_BYTES + S2N_TLS12_TICKET_SIZE_IN_BYTES);
        EXPECT_TRUE(s2n_connection_is_session_resumed(client_conn));
        s2n_connection_get_session(client_conn, serialized_session_state, serialized_session_state_length);
        EXPECT_BYTEARRAY_EQUAL(old_session_ticket, serialized_session_state, S2N_PARTIAL_SESSION_STATE_INFO_IN_BYTES + S2N_TLS12_TICKET_SIZE_IN_BYTES);

        /* Verify that the server lifetime hint is 0 because server didn't issue a NST */
        EXPECT_EQUAL(s2n_connection_get_session_ticket_lifetime_hint(client_conn), 0);

        EXPECT_SUCCESS(s2n_shutdown_test_server_and_client(server_conn, client_conn));

        EXPECT_SUCCESS(s2n_connection_free(server_conn));
        EXPECT_SUCCESS(s2n_connection_free(client_conn));

        EXPECT_SUCCESS(s2n_config_free(server_config));
        EXPECT_SUCCESS(s2n_config_free(client_config));
    };

    /* Client sends non-empty ST extension. Server does an abbreviated handshake without issuing a NST
     * even though the key is in decrypt-only state.
     */
    {
        EXPECT_NOT_NULL(client_conn = s2n_connection_new(S2N_CLIENT));

        /* Set client ST and session state */
        EXPECT_SUCCESS(s2n_connection_set_session(client_conn, serialized_session_state, serialized_session_state_length));

        EXPECT_NOT_NULL(client_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(client_config, 1));
        EXPECT_SUCCESS(s2n_connection_set_config(client_conn, client_config));

        EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));

        EXPECT_NOT_NULL(server_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_config, 1));
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(server_config, chain_and_key));

        /* Create nonblocking pipes */
        EXPECT_SUCCESS(s2n_connections_set_io_pair(client_conn, server_conn, &io_pair));

        /* Set session state lifetime for 15 hours which is equal to the default lifetime of a ticket key */
        EXPECT_SUCCESS(s2n_config_set_session_state_lifetime(server_config, S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS));

        uint64_t mock_current_time = 0;
        EXPECT_SUCCESS(s2n_config_set_wall_clock(server_config, mock_time, &mock_current_time));

        /* Add one ST key */
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name2, s2n_array_len(ticket_key_name2), ticket_key2, s2n_array_len(ticket_key2), 0));

        /* Add a mock delay such that key 1 moves to decrypt-only state */
        mock_current_time += server_config->encrypt_decrypt_key_lifetime_in_nanos;

        uint32_t key_intro_time = mock_current_time / ONE_SEC_IN_NANOS;
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name1, s2n_array_len(ticket_key_name1),
                ticket_key1, s2n_array_len(ticket_key1), key_intro_time));

        /* Verify there is an encrypt key available */
        EXPECT_OK(s2n_config_is_encrypt_key_available(server_config));

        EXPECT_SUCCESS(s2n_connection_set_config(server_conn, server_config));

        EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server_conn, client_conn));

        /* Verify that the server did an abbreviated handshake without issuing NST */
        EXPECT_TRUE(IS_RESUMPTION_HANDSHAKE(server_conn));
        EXPECT_FALSE(IS_ISSUING_NEW_SESSION_TICKET(server_conn));

        /* Verify that client_ticket is the same as before because server didn't issue a NST */
        uint8_t old_session_ticket[S2N_PARTIAL_SESSION_STATE_INFO_IN_BYTES + S2N_TLS12_TICKET_SIZE_IN_BYTES];
        EXPECT_MEMCPY_SUCCESS(old_session_ticket, serialized_session_state, S2N_PARTIAL_SESSION_STATE_INFO_IN_BYTES + S2N_TLS12_TICKET_SIZE_IN_BYTES);

        EXPECT_EQUAL(s2n_connection_get_session(client_conn, serialized_session_state, serialized_session_state_length), serialized_session_state_length);
        EXPECT_BYTEARRAY_EQUAL(old_session_ticket, serialized_session_state, S2N_PARTIAL_SESSION_STATE_INFO_IN_BYTES + S2N_TLS12_TICKET_SIZE_IN_BYTES);

        /* Verify the lifetime hint from the server */
        EXPECT_EQUAL(s2n_connection_get_session_ticket_lifetime_hint(client_conn), 0);

        EXPECT_SUCCESS(s2n_shutdown_test_server_and_client(server_conn, client_conn));

        EXPECT_SUCCESS(s2n_connection_free(server_conn));
        EXPECT_SUCCESS(s2n_connection_free(client_conn));

        EXPECT_SUCCESS(s2n_config_free(server_config));
        EXPECT_SUCCESS(s2n_config_free(client_config));
    };

    /* Client sends non-empty ST extension. Server does an abbreviated handshake,
     * but does not issue a NST even though the key is in decrypt-only state due to
     * the absence of encrypt-decrypt key.
     */
    {
        EXPECT_NOT_NULL(client_conn = s2n_connection_new(S2N_CLIENT));

        /* Set client ST and session state */
        EXPECT_SUCCESS(s2n_connection_set_session(client_conn, serialized_session_state, serialized_session_state_length));

        EXPECT_NOT_NULL(client_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(client_config, 1));
        EXPECT_SUCCESS(s2n_connection_set_config(client_conn, client_config));

        EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));

        EXPECT_NOT_NULL(server_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_config, 1));
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(server_config, chain_and_key));

        /* Create nonblocking pipes */
        EXPECT_SUCCESS(s2n_connections_set_io_pair(client_conn, server_conn, &io_pair));

        /* Set session state lifetime for 15 hours which is equal to the default lifetime of a ticket key */
        EXPECT_SUCCESS(s2n_config_set_session_state_lifetime(server_config, S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS));

        uint64_t mock_current_time = 0;
        EXPECT_SUCCESS(s2n_config_set_wall_clock(server_config, mock_time, &mock_current_time));

        /* Add one ST key */
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name2, s2n_array_len(ticket_key_name2), ticket_key2, s2n_array_len(ticket_key2), 0));

        /* Add a mock delay such that key 1 moves to decrypt-only state */
        mock_current_time += server_config->encrypt_decrypt_key_lifetime_in_nanos;

        EXPECT_SUCCESS(s2n_connection_set_config(server_conn, server_config));

        EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server_conn, client_conn));

        /* Verify that the server did an abbreviated handshake and did not issue a NST */
        EXPECT_TRUE(IS_RESUMPTION_HANDSHAKE(server_conn));
        EXPECT_FALSE(IS_ISSUING_NEW_SESSION_TICKET(server_conn));

        /* Verify that client_ticket is same as before because server did not issue a NST */
        uint8_t old_session_ticket[S2N_PARTIAL_SESSION_STATE_INFO_IN_BYTES + S2N_TLS12_TICKET_SIZE_IN_BYTES];
        EXPECT_MEMCPY_SUCCESS(old_session_ticket, serialized_session_state, S2N_PARTIAL_SESSION_STATE_INFO_IN_BYTES + S2N_TLS12_TICKET_SIZE_IN_BYTES);

        s2n_connection_get_session(client_conn, serialized_session_state, serialized_session_state_length);
        EXPECT_FALSE(memcmp(old_session_ticket, serialized_session_state, S2N_PARTIAL_SESSION_STATE_INFO_IN_BYTES + S2N_TLS12_TICKET_SIZE_IN_BYTES));

        EXPECT_SUCCESS(s2n_shutdown_test_server_and_client(server_conn, client_conn));

        EXPECT_SUCCESS(s2n_connection_free(server_conn));
        EXPECT_SUCCESS(s2n_connection_free(client_conn));

        EXPECT_SUCCESS(s2n_config_free(server_config));
        EXPECT_SUCCESS(s2n_config_free(client_config));
    };

    /* Client sends non-empty ST extension. Server does a full handshake and issues
     * a NST because the key used to encrypt the session ticket is not found.
     */
    {
        EXPECT_NOT_NULL(client_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(client_config, 1));
        EXPECT_SUCCESS(s2n_config_disable_x509_verification(client_config));
        EXPECT_NOT_NULL(client_conn = s2n_connection_new(S2N_CLIENT));

        /* Set client ST and session state */
        EXPECT_SUCCESS(s2n_connection_set_session(client_conn, serialized_session_state, serialized_session_state_length));

        EXPECT_SUCCESS(s2n_connection_set_config(client_conn, client_config));

        EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));

        EXPECT_NOT_NULL(server_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_config, 1));
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(server_config, chain_and_key));

        /* Create nonblocking pipes */
        EXPECT_SUCCESS(s2n_connections_set_io_pair(client_conn, server_conn, &io_pair));

        /* Set session state lifetime for 15 hours which is equal to the default lifetime of a ticket key */
        EXPECT_SUCCESS(s2n_config_set_session_state_lifetime(server_config, S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS));

        uint64_t mock_current_time = 0;
        EXPECT_SUCCESS(s2n_config_set_wall_clock(server_config, mock_time, &mock_current_time));

        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name1, s2n_array_len(ticket_key_name1),
                ticket_key1, s2n_array_len(ticket_key1), 0));

        EXPECT_SUCCESS(s2n_connection_set_config(server_conn, server_config));

        EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server_conn, client_conn));

        /* Verify that the server did a full handshake and issued NST */
        EXPECT_TRUE(IS_FULL_HANDSHAKE(server_conn));
        EXPECT_TRUE(IS_ISSUING_NEW_SESSION_TICKET(server_conn));

        /* Verify that the client received NST */
        serialized_session_state_length = s2n_connection_get_session_length(client_conn);
        EXPECT_EQUAL(s2n_connection_get_session(client_conn, serialized_session_state, serialized_session_state_length), serialized_session_state_length);
        EXPECT_BYTEARRAY_EQUAL(serialized_session_state + S2N_TICKET_KEY_NAME_LOCATION,
                ticket_key_name1, s2n_array_len(ticket_key_name1));

        /* Verify the lifetime hint from the server */
        uint32_t session_ticket_lifetime = s2n_connection_get_session_ticket_lifetime_hint(client_conn);
        EXPECT_EQUAL(session_ticket_lifetime, S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS);

        EXPECT_SUCCESS(s2n_shutdown_test_server_and_client(server_conn, client_conn));

        EXPECT_SUCCESS(s2n_connection_free(server_conn));
        EXPECT_SUCCESS(s2n_connection_free(client_conn));

        EXPECT_SUCCESS(s2n_config_free(server_config));
        EXPECT_SUCCESS(s2n_config_free(client_config));
    };

    /* Client sends non-empty ST extension. Server does a full handshake and issues a NST
     * because the key has expired.
     */
    {
        EXPECT_NOT_NULL(client_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(client_config, 1));
        EXPECT_SUCCESS(s2n_config_disable_x509_verification(client_config));
        EXPECT_NOT_NULL(client_conn = s2n_connection_new(S2N_CLIENT));

        /* Set client ST and session state */
        EXPECT_SUCCESS(s2n_connection_set_session(client_conn, serialized_session_state, serialized_session_state_length));

        EXPECT_SUCCESS(s2n_connection_set_config(client_conn, client_config));

        EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));

        EXPECT_NOT_NULL(server_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_config, 1));
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(server_config, chain_and_key));

        /* Create nonblocking pipes */
        EXPECT_SUCCESS(s2n_connections_set_io_pair(client_conn, server_conn, &io_pair));

        /* Set session state lifetime for 15 hours which is equal to the default lifetime of a ticket key */
        EXPECT_SUCCESS(s2n_config_set_session_state_lifetime(server_config, S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS));

        uint64_t mock_current_time = 0;
        EXPECT_SUCCESS(s2n_config_set_wall_clock(server_config, mock_time, &mock_current_time));

        /* Add one ST key */
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name1, s2n_array_len(ticket_key_name1), ticket_key1, s2n_array_len(ticket_key1), 0));

        /* Add a mock delay such that the key used to encrypt ST expires */
        mock_current_time += server_config->decrypt_key_lifetime_in_nanos + server_config->encrypt_decrypt_key_lifetime_in_nanos;

        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name2, s2n_array_len(ticket_key_name2),
                ticket_key2, s2n_array_len(ticket_key2), 0));

        EXPECT_SUCCESS(s2n_connection_set_config(server_conn, server_config));

        EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server_conn, client_conn));

        /* Verify that the server did a full handshake and issued NST */
        EXPECT_TRUE(IS_FULL_HANDSHAKE(server_conn));
        EXPECT_TRUE(IS_ISSUING_NEW_SESSION_TICKET(server_conn));

        /* Verify that the server has only the unexpired key */
        EXPECT_OK(s2n_array_get(server_config->ticket_keys, 0, (void **) &ticket_key));
        EXPECT_BYTEARRAY_EQUAL(ticket_key->key_name, ticket_key_name2, s2n_array_len(ticket_key_name2));
        EXPECT_OK(s2n_array_num_elements(server_config->ticket_keys, &ticket_keys_len));
        EXPECT_EQUAL(ticket_keys_len, 1);

        /* Verify that the client received NST */
        serialized_session_state_length = s2n_connection_get_session_length(client_conn);
        EXPECT_EQUAL(s2n_connection_get_session(client_conn, serialized_session_state, serialized_session_state_length), serialized_session_state_length);
        EXPECT_BYTEARRAY_EQUAL(serialized_session_state + S2N_TICKET_KEY_NAME_LOCATION,
                ticket_key_name2, s2n_array_len(ticket_key_name2));

        /* Verify the lifetime hint from the server */
        EXPECT_EQUAL(s2n_connection_get_session_ticket_lifetime_hint(client_conn), S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS);

        EXPECT_SUCCESS(s2n_shutdown_test_server_and_client(server_conn, client_conn));

        EXPECT_SUCCESS(s2n_connection_free(server_conn));
        EXPECT_SUCCESS(s2n_connection_free(client_conn));

        EXPECT_SUCCESS(s2n_config_free(server_config));
        EXPECT_SUCCESS(s2n_config_free(client_config));
    };

    /* Client sends non-empty ST extension. Server does a full handshake and issues a NST because the ticket has non-standard size. */
    {
        EXPECT_NOT_NULL(client_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(client_config, 1));
        EXPECT_SUCCESS(s2n_config_disable_x509_verification(client_config));
        EXPECT_NOT_NULL(client_conn = s2n_connection_new(S2N_CLIENT));

        /* Tamper session state to make session ticket size smaller than what we expect */
        /* Verify that client_ticket is same as before because server did not issue a NST */
        uint8_t tampered_session_state[sizeof(serialized_session_state) - 1];
        /* Copy session format */
        tampered_session_state[0] = serialized_session_state[0];
        /* Copy and reduce by 1 the session ticket length */
        tampered_session_state[1] = serialized_session_state[1];
        tampered_session_state[2] = serialized_session_state[2] - 1;
        /* Skip 1 byte of the session ticket and copy the rest */
        EXPECT_MEMCPY_SUCCESS(tampered_session_state + 3, serialized_session_state + 4, sizeof(tampered_session_state) - 4);

        /* Set client tampered ST and session state */
        EXPECT_SUCCESS(s2n_connection_set_session(client_conn, tampered_session_state, serialized_session_state_length - 1));

        EXPECT_SUCCESS(s2n_connection_set_config(client_conn, client_config));

        EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));

        EXPECT_NOT_NULL(server_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_config, 1));
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(server_config, chain_and_key));

        /* Create nonblocking pipes */
        EXPECT_SUCCESS(s2n_connections_set_io_pair(client_conn, server_conn, &io_pair));

        /* Set session state lifetime for 15 hours which is equal to the default lifetime of a ticket key */
        EXPECT_SUCCESS(s2n_config_set_session_state_lifetime(server_config, S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS));

        uint64_t mock_current_time = 0;
        EXPECT_SUCCESS(s2n_config_set_wall_clock(server_config, mock_time, &mock_current_time));

        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name1, s2n_array_len(ticket_key_name1),
                ticket_key1, s2n_array_len(ticket_key1), 0));

        EXPECT_SUCCESS(s2n_connection_set_config(server_conn, server_config));

        EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server_conn, client_conn));

        /* Verify that the server did a full handshake and issued NST */
        EXPECT_TRUE(IS_FULL_HANDSHAKE(server_conn));
        EXPECT_TRUE(IS_ISSUING_NEW_SESSION_TICKET(server_conn));

        /* Verify that the client received NST */
        serialized_session_state_length = s2n_connection_get_session_length(client_conn);
        EXPECT_EQUAL(s2n_connection_get_session(client_conn, serialized_session_state, serialized_session_state_length), serialized_session_state_length);
        EXPECT_BYTEARRAY_EQUAL(serialized_session_state + S2N_TICKET_KEY_NAME_LOCATION,
                ticket_key_name1, s2n_array_len(ticket_key_name1));

        /* Verify the lifetime hint from the server */
        EXPECT_EQUAL(s2n_connection_get_session_ticket_lifetime_hint(client_conn), S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS);

        EXPECT_SUCCESS(s2n_shutdown_test_server_and_client(server_conn, client_conn));

        EXPECT_SUCCESS(s2n_connection_free(server_conn));
        EXPECT_SUCCESS(s2n_connection_free(client_conn));

        EXPECT_SUCCESS(s2n_config_free(server_config));
        EXPECT_SUCCESS(s2n_config_free(client_config));
    };

    /* Client sends non-empty ST extension, but server cannot or does not want to honor the ticket. */
    {
        EXPECT_NOT_NULL(client_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(client_config, 1));
        EXPECT_SUCCESS(s2n_config_disable_x509_verification(client_config));
        EXPECT_NOT_NULL(client_conn = s2n_connection_new(S2N_CLIENT));

        /* Set client ST and session state */
        EXPECT_SUCCESS(s2n_connection_set_session(client_conn, serialized_session_state, serialized_session_state_length));

        EXPECT_SUCCESS(s2n_connection_set_config(client_conn, client_config));

        EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));

        EXPECT_NOT_NULL(server_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(server_config, chain_and_key));

        /* Create nonblocking pipes */
        EXPECT_SUCCESS(s2n_connections_set_io_pair(client_conn, server_conn, &io_pair));

        /* Not enabling resumption using ST */
        EXPECT_SUCCESS(s2n_connection_set_config(server_conn, server_config));

        EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server_conn, client_conn));

        /* Verify that the server did a full handshake and did not issue NST */
        EXPECT_TRUE(IS_FULL_HANDSHAKE(server_conn));
        EXPECT_FALSE(IS_ISSUING_NEW_SESSION_TICKET(server_conn));

        /* Verify that client_ticket is empty */
        EXPECT_EQUAL(s2n_connection_get_session(client_conn, serialized_session_state, serialized_session_state_length), 1 + 1 + client_conn->session_id_len + S2N_TLS12_STATE_SIZE_IN_BYTES);
        EXPECT_EQUAL(memcmp(serialized_session_state, &s2n_state_with_session_id, 1), 0);
        EXPECT_NOT_EQUAL(memcmp(serialized_session_state + S2N_TICKET_KEY_NAME_LOCATION,
                                 ticket_key_name2, s2n_array_len(ticket_key_name2)),
                0);

        /* Verify the lifetime hint from the server */
        EXPECT_FAILURE_WITH_ERRNO(s2n_connection_get_session_ticket_lifetime_hint(client_conn), S2N_ERR_SESSION_TICKET_NOT_SUPPORTED);

        EXPECT_SUCCESS(s2n_shutdown_test_server_and_client(server_conn, client_conn));

        EXPECT_SUCCESS(s2n_connection_free(server_conn));
        EXPECT_SUCCESS(s2n_connection_free(client_conn));

        EXPECT_SUCCESS(s2n_config_free(server_config));
        EXPECT_SUCCESS(s2n_config_free(client_config));
    };

    /* Client sets corrupted ST extension. */
    {
        EXPECT_NOT_NULL(client_conn = s2n_connection_new(S2N_CLIENT));

        memset(serialized_session_state, 0, serialized_session_state_length);

        /* Set client ST and session state */
        EXPECT_FAILURE(s2n_connection_set_session(client_conn, serialized_session_state, serialized_session_state_length));

        EXPECT_SUCCESS(s2n_connection_free(client_conn));
    };

    /* User tries adding a duplicate key to the server */
    {
        EXPECT_NOT_NULL(server_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_config, 1));

        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name1, s2n_array_len(ticket_key_name1), ticket_key1, s2n_array_len(ticket_key1), 0));

        /* Try adding the same key, but with a different name */
        EXPECT_EQUAL(-1, s2n_config_add_ticket_crypto_key(server_config, ticket_key_name2, s2n_array_len(ticket_key_name2), ticket_key1, s2n_array_len(ticket_key1), 0));

        /* Try adding a different key, but with the same name */
        EXPECT_EQUAL(-1, s2n_config_add_ticket_crypto_key(server_config, ticket_key_name1, s2n_array_len(ticket_key_name1), ticket_key2, s2n_array_len(ticket_key2), 0));
        EXPECT_EQUAL(s2n_errno, S2N_ERR_INVALID_TICKET_KEY_NAME_OR_NAME_LENGTH);

        /* Try adding a key with invalid key length */
        EXPECT_EQUAL(-1, s2n_config_add_ticket_crypto_key(server_config, ticket_key_name2, s2n_array_len(ticket_key_name2), ticket_key2, 0, 0));
        EXPECT_EQUAL(s2n_errno, S2N_ERR_INVALID_TICKET_KEY_LENGTH);

        EXPECT_SUCCESS(s2n_config_free(server_config));
    };

    /* Testing expired keys are removed from the server config while adding new keys. */
    {
        EXPECT_NOT_NULL(server_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_config, 1));

        /* Add 2 ST keys */
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name1, s2n_array_len(ticket_key_name1), ticket_key1, s2n_array_len(ticket_key1), 0));
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name2, s2n_array_len(ticket_key_name2), ticket_key2, s2n_array_len(ticket_key2), 0));

        /* Add a mock delay such that the first two keys expire */
        uint64_t mock_delay = server_config->decrypt_key_lifetime_in_nanos + server_config->encrypt_decrypt_key_lifetime_in_nanos;
        EXPECT_SUCCESS(s2n_config_set_wall_clock(server_config, mock_nanoseconds_since_epoch, &mock_delay));

        /* Add a third ST key */
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name3, s2n_array_len(ticket_key_name3), ticket_key3, s2n_array_len(ticket_key3), 0));

        /* Try adding the expired keys */
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name2, s2n_array_len(ticket_key_name2), ticket_key2, s2n_array_len(ticket_key2), 0));
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name1, s2n_array_len(ticket_key_name1), ticket_key1, s2n_array_len(ticket_key1), 0));

        /* Verify that the config has three unexpired keys */
        EXPECT_OK(s2n_array_get(server_config->ticket_keys, 0, (void **) &ticket_key));
        /* ticket_key3 should have "rotated" to the first index as other keys expired */
        EXPECT_BYTEARRAY_EQUAL(ticket_key->key_name, ticket_key_name3, s2n_array_len(ticket_key_name3));
        EXPECT_OK(s2n_array_num_elements(server_config->ticket_keys, &ticket_keys_len));
        EXPECT_EQUAL(ticket_keys_len, 3);

        EXPECT_SUCCESS(s2n_config_free(server_config));
    };

    /* Attempting to add more than S2N_MAX_TICKET_KEYS causes failures. */
    {
        DEFER_CLEANUP(struct s2n_config *config = s2n_config_new(), s2n_config_ptr_free);
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(config, 1));
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(config, chain_and_key));

        uint8_t id = 0;
        uint8_t ticket_key_buf[32] = { 0 };

        for (uint8_t i = 0; i < S2N_MAX_TICKET_KEYS; i++) {
            id = i;
            ticket_key_buf[0] = i;
            EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(config,
                    &id, sizeof(id), ticket_key_buf, s2n_array_len(ticket_key_buf), 0));
        }

        id = S2N_MAX_TICKET_KEYS;
        ticket_key_buf[0] = S2N_MAX_TICKET_KEYS;
        EXPECT_FAILURE(s2n_config_add_ticket_crypto_key(config, &id, sizeof(id),
                ticket_key_buf, s2n_array_len(ticket_key_buf), 0));
    };

    /* Scenario 1: Client sends empty ST and server has multiple encrypt-decrypt keys to choose from for encrypting NST. */
    {
        EXPECT_NOT_NULL(client_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(client_config, 1));
        EXPECT_SUCCESS(s2n_config_disable_x509_verification(client_config));
        EXPECT_NOT_NULL(client_conn = s2n_connection_new(S2N_CLIENT));

        EXPECT_SUCCESS(s2n_connection_set_config(client_conn, client_config));

        EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));

        EXPECT_NOT_NULL(server_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_config, 1));
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(server_config, chain_and_key));

        /* Create nonblocking pipes */
        EXPECT_SUCCESS(s2n_connections_set_io_pair(client_conn, server_conn, &io_pair));

        /* Set session state lifetime for 15 hours which is equal to the default lifetime of a ticket key */
        EXPECT_SUCCESS(s2n_config_set_session_state_lifetime(server_config, S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS));

        uint64_t mock_current_time = 0;
        EXPECT_SUCCESS(s2n_config_set_wall_clock(server_config, mock_time, &mock_current_time));

        /* Add one ST key */
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name1, s2n_array_len(ticket_key_name1), ticket_key1, s2n_array_len(ticket_key1), 0));

        /* Add a mock delay such that the first key is close to it's encryption peak */
        uint64_t delay_in_nanos = server_config->encrypt_decrypt_key_lifetime_in_nanos / 2;
        mock_current_time += delay_in_nanos;

        /* Add two more ST keys */
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name2, s2n_array_len(ticket_key_name2), ticket_key2, s2n_array_len(ticket_key2), 0));
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name3, s2n_array_len(ticket_key_name3), ticket_key3, s2n_array_len(ticket_key3), 0));

        EXPECT_SUCCESS(s2n_connection_set_config(server_conn, server_config));

        EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server_conn, client_conn));

        /* Verify that the server did a full handshake and issued NST */
        EXPECT_TRUE(IS_FULL_HANDSHAKE(server_conn));
        EXPECT_TRUE(IS_ISSUING_NEW_SESSION_TICKET(server_conn));

        /* Verify that the client received NST which is encrypted using a key which is at it's peak encryption */
        serialized_session_state_length = s2n_connection_get_session_length(client_conn);
        EXPECT_EQUAL(s2n_connection_get_session(client_conn, serialized_session_state, serialized_session_state_length), serialized_session_state_length);
        EXPECT_BYTEARRAY_EQUAL(serialized_session_state + S2N_TICKET_KEY_NAME_LOCATION,
                ticket_key_name1, s2n_array_len(ticket_key_name1));

        /* Verify the lifetime hint from the server */
        uint32_t session_ticket_lifetime = s2n_connection_get_session_ticket_lifetime_hint(client_conn);
        uint32_t first_key_remaining_lifetime = S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS - delay_in_nanos / ONE_SEC_IN_NANOS;
        EXPECT_EQUAL(session_ticket_lifetime, first_key_remaining_lifetime);

        EXPECT_SUCCESS(s2n_shutdown_test_server_and_client(server_conn, client_conn));

        EXPECT_SUCCESS(s2n_connection_free(server_conn));
        EXPECT_SUCCESS(s2n_connection_free(client_conn));

        EXPECT_SUCCESS(s2n_config_free(server_config));
        EXPECT_SUCCESS(s2n_config_free(client_config));
    };

    /* Scenario 2: Client sends empty ST and server has multiple encrypt-decrypt keys to choose from for encrypting NST */
    {
        const size_t allowed_failures = 1;
        size_t failures = 0;
        bool expected_key_chosen = false;

        /* This test sets up three different ticket encryption keys at various times in their encryption lifetime. The test
         * is meant to check that the weighted random selection algorithm correctly selects the key that is at its
         * encryption peak. However the test will sometimes pick a key that is not at its encryption peak because the
         * selection function uses a weighted random selection algorithm. Here we retry the test once if the key chosen
         * is not the expected key.
         *
         * The wrong key will be chosen 0.02% of the time. This value is drawn from the weight of the expected key,
         * which does not change per test run. Therefore, the probability that the test chooses the wrong key
         * more than allowed_failures times is 0.0002 ^ 2 = 0.00000004, which is extremely unlikely to occur. If
         * the logic changes to chose the wrong key at a higher rate, say 50% of the time, this test would fail at a
         * 0.5 ^ 2 = 0.25 or 25% of the time. This rate is high enough for us to notice and investigate.
         */
        while (expected_key_chosen == false) {
            EXPECT_TRUE(failures <= allowed_failures);

            EXPECT_NOT_NULL(client_config = s2n_config_new());
            EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(client_config, 1));
            EXPECT_SUCCESS(s2n_config_disable_x509_verification(client_config));
            EXPECT_NOT_NULL(client_conn = s2n_connection_new(S2N_CLIENT));

            EXPECT_SUCCESS(s2n_connection_set_config(client_conn, client_config));

            EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));

            EXPECT_NOT_NULL(server_config = s2n_config_new());
            EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_config, 1));
            EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(server_config, chain_and_key));

            /* Create nonblocking pipes */
            EXPECT_SUCCESS(s2n_connections_set_io_pair(client_conn, server_conn, &io_pair));

            /* Set session state lifetime for 15 hours which is equal to the default lifetime of a ticket key */
            EXPECT_SUCCESS(s2n_config_set_session_state_lifetime(server_config, S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS));

            uint64_t mock_current_time = 0;
            EXPECT_SUCCESS(s2n_config_set_wall_clock(server_config, mock_time, &mock_current_time));

            /* Add one ST key */
            EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name1, s2n_array_len(ticket_key_name1),
                    ticket_key1, s2n_array_len(ticket_key1), 0));

            /* Add second key when the first key is very close to it's encryption peak */
            uint64_t delay_in_nanos = server_config->encrypt_decrypt_key_lifetime_in_nanos / 2;
            mock_current_time += delay_in_nanos;
            EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name2, s2n_array_len(ticket_key_name2),
                    ticket_key2, s2n_array_len(ticket_key2), 0));

            /* Add third key when the second key is very close to it's encryption peak and
            * the first key is about to transition from encrypt-decrypt state to decrypt-only state
            */
            mock_current_time += delay_in_nanos;
            EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name3, s2n_array_len(ticket_key_name3),
                    ticket_key3, s2n_array_len(ticket_key3), 0));

            EXPECT_SUCCESS(s2n_connection_set_config(server_conn, server_config));

            EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server_conn, client_conn));

            /* Verify that the server did a full handshake and issued NST */
            EXPECT_TRUE(IS_FULL_HANDSHAKE(server_conn));
            EXPECT_TRUE(IS_ISSUING_NEW_SESSION_TICKET(server_conn));

            /* Verify that the client received NST which is encrypted using a key which is at it's peak encryption */
            serialized_session_state_length = s2n_connection_get_session_length(client_conn);
            EXPECT_EQUAL(s2n_connection_get_session(client_conn, serialized_session_state, serialized_session_state_length),
                    serialized_session_state_length);
            int result = memcmp(serialized_session_state + S2N_TICKET_KEY_NAME_LOCATION,
                    ticket_key_name2,
                    s2n_array_len(ticket_key_name2));
            if (result == 0) {
                expected_key_chosen = true;
            } else {
                failures += 1;
            }

            /* Verify the lifetime hint from the server */
            uint32_t session_ticket_lifetime = s2n_connection_get_session_ticket_lifetime_hint(client_conn);
            uint32_t second_key_remaining_lifetime = S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS - (delay_in_nanos / ONE_SEC_IN_NANOS);
            EXPECT_EQUAL(session_ticket_lifetime, second_key_remaining_lifetime);

            EXPECT_SUCCESS(s2n_shutdown_test_server_and_client(server_conn, client_conn));

            EXPECT_SUCCESS(s2n_connection_free(server_conn));
            EXPECT_SUCCESS(s2n_connection_free(client_conn));

            EXPECT_SUCCESS(s2n_config_free(server_config));
            EXPECT_SUCCESS(s2n_config_free(client_config));
        }
    };

    /* Testing s2n_config_set_ticket_encrypt_decrypt_key_lifetime and
     * s2n_config_set_ticket_decrypt_key_lifetime calls */
    {
        EXPECT_NOT_NULL(client_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(client_config, 1));
        EXPECT_SUCCESS(s2n_config_disable_x509_verification(client_config));
        EXPECT_NOT_NULL(client_conn = s2n_connection_new(S2N_CLIENT));

        EXPECT_SUCCESS(s2n_connection_set_config(client_conn, client_config));

        EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));

        EXPECT_NOT_NULL(server_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_config, 1));
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(server_config, chain_and_key));

        /* Create nonblocking pipes */
        EXPECT_SUCCESS(s2n_connections_set_io_pair(client_conn, server_conn, &io_pair));

        /* Set session state lifetime for 15 hours which is equal to the default lifetime of a ticket key */
        EXPECT_SUCCESS(s2n_config_set_session_state_lifetime(server_config, S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS));

        /* Set encrypt-decrypt key expire time to 24 hours */
        EXPECT_SUCCESS(s2n_config_set_ticket_encrypt_decrypt_key_lifetime(server_config, 86400));

        /* Set decrypt-only key expire time to 5 hours */
        EXPECT_SUCCESS(s2n_config_set_ticket_decrypt_key_lifetime(server_config, 18000));

        /* Add one ST key */
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name1, s2n_array_len(ticket_key_name1), ticket_key1, s2n_array_len(ticket_key1), 0));

        /* Add second key when the first key is very close to it's encryption peak */
        uint64_t mock_delay = (server_config->encrypt_decrypt_key_lifetime_in_nanos / 2) - ONE_SEC_IN_NANOS;
        EXPECT_SUCCESS(s2n_config_set_wall_clock(server_config, mock_nanoseconds_since_epoch, &mock_delay));
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name2, s2n_array_len(ticket_key_name2), ticket_key2, s2n_array_len(ticket_key2), 0));

        /* Add third key when the second key is very close to it's encryption peak and
         * the first key is about to transition from encrypt-decrypt state to decrypt-only state
         */
        mock_delay = server_config->encrypt_decrypt_key_lifetime_in_nanos - ONE_SEC_IN_NANOS;
        EXPECT_SUCCESS(s2n_config_set_wall_clock(server_config, mock_nanoseconds_since_epoch, &mock_delay));
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name3, s2n_array_len(ticket_key_name3), ticket_key3, s2n_array_len(ticket_key3), 0));

        EXPECT_SUCCESS(s2n_connection_set_config(server_conn, server_config));

        EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server_conn, client_conn));

        /* Verify that the server did a full handshake and issued NST */
        EXPECT_TRUE(IS_FULL_HANDSHAKE(server_conn));
        EXPECT_TRUE(IS_ISSUING_NEW_SESSION_TICKET(server_conn));

        /* Verify that the client received NST which is encrypted using a key which is at it's peak encryption */
        serialized_session_state_length = s2n_connection_get_session_length(client_conn);
        EXPECT_EQUAL(s2n_connection_get_session(client_conn, serialized_session_state, serialized_session_state_length), serialized_session_state_length);
        EXPECT_BYTEARRAY_EQUAL(serialized_session_state + S2N_TICKET_KEY_NAME_LOCATION,
                ticket_key_name2, s2n_array_len(ticket_key_name2));

        /* Verify the lifetime hint from the server */
        EXPECT_EQUAL(s2n_connection_get_session_ticket_lifetime_hint(client_conn), S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS);

        EXPECT_SUCCESS(s2n_shutdown_test_server_and_client(server_conn, client_conn));

        EXPECT_SUCCESS(s2n_connection_free(server_conn));
        EXPECT_SUCCESS(s2n_connection_free(client_conn));

        EXPECT_SUCCESS(s2n_config_free(server_config));
        EXPECT_SUCCESS(s2n_config_free(client_config));
    };

    /* Add keys out of order and pre-emptively add a key */
    {
        EXPECT_NOT_NULL(client_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(client_config, 1));
        EXPECT_SUCCESS(s2n_config_disable_x509_verification(client_config));
        EXPECT_NOT_NULL(client_conn = s2n_connection_new(S2N_CLIENT));

        EXPECT_SUCCESS(s2n_connection_set_config(client_conn, client_config));

        EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));

        EXPECT_NOT_NULL(server_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_config, 1));
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(server_config, chain_and_key));

        /* Create nonblocking pipes */
        EXPECT_SUCCESS(s2n_connections_set_io_pair(client_conn, server_conn, &io_pair));

        /* Set session state lifetime for 15 hours which is equal to the default lifetime of a ticket key */
        EXPECT_SUCCESS(s2n_config_set_session_state_lifetime(server_config, S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS));

        /* Add a key. After 1 hour it will be considered an encrypt-decrypt key. */
        POSIX_GUARD(server_config->wall_clock(server_config->sys_clock_ctx, &now));
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name1, s2n_array_len(ticket_key_name1), ticket_key1, s2n_array_len(ticket_key1), (now / ONE_SEC_IN_NANOS) + 3600));

        /* Add a key. After 1 hour it will reach it's peak */
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name2, s2n_array_len(ticket_key_name2), ticket_key2, s2n_array_len(ticket_key2), now / ONE_SEC_IN_NANOS));

        /* Add a key pre-emptively. It can be used only after 10 hours */
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name3, s2n_array_len(ticket_key_name3), ticket_key3, s2n_array_len(ticket_key3), now / ONE_SEC_IN_NANOS + 36000));

        /* Add a mock delay such that negotiation happens after 1 hour */
        uint64_t mock_delay = (server_config->encrypt_decrypt_key_lifetime_in_nanos / 2) - ONE_SEC_IN_NANOS;
        EXPECT_SUCCESS(s2n_config_set_wall_clock(server_config, mock_nanoseconds_since_epoch, &mock_delay));

        EXPECT_SUCCESS(s2n_connection_set_config(server_conn, server_config));

        EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server_conn, client_conn));

        /* Verify that the server did a full handshake and issued NST */
        EXPECT_TRUE(IS_FULL_HANDSHAKE(server_conn));
        EXPECT_TRUE(IS_ISSUING_NEW_SESSION_TICKET(server_conn));

        /* Verify that the client received NST which is encrypted using a key which is at it's peak encryption */
        serialized_session_state_length = s2n_connection_get_session_length(client_conn);
        EXPECT_EQUAL(s2n_connection_get_session(client_conn, serialized_session_state, serialized_session_state_length), serialized_session_state_length);
        EXPECT_BYTEARRAY_EQUAL(serialized_session_state + S2N_TICKET_KEY_NAME_LOCATION,
                ticket_key_name2, s2n_array_len(ticket_key_name2));

        EXPECT_SUCCESS(s2n_shutdown_test_server_and_client(server_conn, client_conn));

        EXPECT_SUCCESS(s2n_connection_free(server_conn));
        EXPECT_SUCCESS(s2n_connection_free(client_conn));

        EXPECT_SUCCESS(s2n_config_free(server_config));
        EXPECT_SUCCESS(s2n_config_free(client_config));
    };

    /* Handshake with client auth and session ticket enabled */
    {
        EXPECT_NOT_NULL(client_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_disable_x509_verification(client_config));

        /* Client has session ticket and mutual auth enabled */
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(client_config, 1));
        EXPECT_SUCCESS(s2n_config_set_client_auth_type(client_config, S2N_CERT_AUTH_OPTIONAL));

        EXPECT_NOT_NULL(client_conn = s2n_connection_new(S2N_CLIENT));
        EXPECT_SUCCESS(s2n_connection_set_config(client_conn, client_config));

        EXPECT_NOT_NULL(server_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(server_config, chain_and_key));

        EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));

        /* Server has session ticket and mutual auth enabled */
        EXPECT_SUCCESS(s2n_connection_set_client_auth_type(server_conn, S2N_CERT_AUTH_OPTIONAL));
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_config, 1));
        EXPECT_SUCCESS(s2n_connection_set_config(server_conn, server_config));

        /* Create nonblocking pipes */
        EXPECT_SUCCESS(s2n_connections_set_io_pair(client_conn, server_conn, &io_pair));

        EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server_conn, client_conn));

        /* Verify that the server did a full handshake and did not issue NST since client
         * auth is enabled in server mode */
        EXPECT_TRUE(IS_FULL_HANDSHAKE(server_conn));
        EXPECT_FALSE(IS_ISSUING_NEW_SESSION_TICKET(server_conn));

        EXPECT_SUCCESS(s2n_shutdown_test_server_and_client(server_conn, client_conn));

        EXPECT_SUCCESS(s2n_connection_free(server_conn));
        EXPECT_SUCCESS(s2n_connection_free(client_conn));

        EXPECT_SUCCESS(s2n_config_free(server_config));
        EXPECT_SUCCESS(s2n_config_free(client_config));
    };

    /* s2n_resume_decrypt_session fails to decrypt when presented with a valid ticket_key, valid iv and invalid encrypted blob */
    {
        EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));
        EXPECT_NOT_NULL(server_config = s2n_config_new());

        /* Add Session Ticket key on the server config */
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_config, 1));
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name1, s2n_array_len(ticket_key_name1), ticket_key1, s2n_array_len(ticket_key1), 0));
        EXPECT_SUCCESS(s2n_connection_set_config(server_conn, server_config));

        /* Setup stuffers value containing the valid version number, valid key name, valid info, valid iv and invalid encrypted blob */
        POSIX_GUARD(s2n_stuffer_write_uint8(&server_conn->client_ticket_to_decrypt, S2N_PRE_ENCRYPTED_STATE_V1));
        POSIX_GUARD(s2n_stuffer_write_bytes(&server_conn->client_ticket_to_decrypt, ticket_key_name1, s2n_array_len(ticket_key_name1)));

        uint8_t valid_info[S2N_TICKET_INFO_SIZE] = { 0 };
        POSIX_GUARD(s2n_stuffer_write_bytes(&server_conn->client_ticket_to_decrypt, valid_info, sizeof(valid_info)));

        uint8_t valid_iv[S2N_TLS_GCM_IV_LEN] = { 0 };
        POSIX_GUARD(s2n_stuffer_write_bytes(&server_conn->client_ticket_to_decrypt, valid_iv, sizeof(valid_iv)));

        uint8_t invalid_en_data[S2N_TLS12_STATE_SIZE_IN_BYTES + S2N_TLS_GCM_TAG_LEN] = { 0 };
        POSIX_GUARD(s2n_stuffer_write_bytes(&server_conn->client_ticket_to_decrypt, invalid_en_data, sizeof(invalid_en_data)));

        server_conn->session_ticket_status = S2N_DECRYPT_TICKET;
        EXPECT_ERROR_WITH_ERRNO(s2n_resume_decrypt_session(server_conn, &server_conn->client_ticket_to_decrypt), S2N_ERR_DECRYPT);

        EXPECT_SUCCESS(s2n_connection_free(server_conn));
        EXPECT_SUCCESS(s2n_config_free(server_config));
    };

    /* s2n_resume_decrypt_session fails with a key not found error when presented with an invalid ticket_key, valid iv and invalid encrypted blob */
    {
        EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));
        EXPECT_NOT_NULL(server_config = s2n_config_new());

        /* Add Session Ticket key on the server config */
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_config, 1));
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name1, s2n_array_len(ticket_key_name1), ticket_key1, s2n_array_len(ticket_key1), 0));
        EXPECT_SUCCESS(s2n_connection_set_config(server_conn, server_config));

        /* Setup stuffers value containing the valid version number, invalid key name, valid iv, valid info, and invalid encrypted blob */
        POSIX_GUARD(s2n_stuffer_write_uint8(&server_conn->client_ticket_to_decrypt, S2N_PRE_ENCRYPTED_STATE_V1));
        POSIX_GUARD(s2n_stuffer_write_bytes(&server_conn->client_ticket_to_decrypt, ticket_key_name2, s2n_array_len(ticket_key_name2)));

        uint8_t valid_info[S2N_TICKET_INFO_SIZE] = { 0 };
        POSIX_GUARD(s2n_stuffer_write_bytes(&server_conn->client_ticket_to_decrypt, valid_info, sizeof(valid_info)));

        uint8_t valid_iv[S2N_TLS_GCM_IV_LEN] = { 0 };
        POSIX_GUARD(s2n_stuffer_write_bytes(&server_conn->client_ticket_to_decrypt, valid_iv, sizeof(valid_iv)));

        uint8_t invalid_en_data[S2N_TLS12_STATE_SIZE_IN_BYTES + S2N_TLS_GCM_TAG_LEN] = { 0 };
        POSIX_GUARD(s2n_stuffer_write_bytes(&server_conn->client_ticket_to_decrypt, invalid_en_data, sizeof(invalid_en_data)));

        server_conn->session_ticket_status = S2N_DECRYPT_TICKET;
        EXPECT_ERROR_WITH_ERRNO(s2n_resume_decrypt_session(server_conn, &server_conn->client_ticket_to_decrypt), S2N_ERR_KEY_USED_IN_SESSION_TICKET_NOT_FOUND);

        EXPECT_SUCCESS(s2n_connection_free(server_conn));
        EXPECT_SUCCESS(s2n_config_free(server_config));
    };

    /* Test s2n_connection_is_session_resumed */
    {
        /* TLS1.2 */
        {
            struct s2n_connection *conn = s2n_connection_new(S2N_SERVER);
            EXPECT_NOT_NULL(conn);
            conn->actual_protocol_version = S2N_TLS12;

            conn->handshake.handshake_type = INITIAL;
            EXPECT_FALSE(s2n_connection_is_session_resumed(conn));

            conn->handshake.handshake_type = NEGOTIATED | WITH_SESSION_TICKET;
            EXPECT_TRUE(s2n_connection_is_session_resumed(conn));

            /* Ignores PSK mode */
            conn->psk_params.type = S2N_PSK_TYPE_EXTERNAL;
            EXPECT_TRUE(s2n_connection_is_session_resumed(conn));

            EXPECT_SUCCESS(s2n_connection_free(conn));
        };

        /* TLS1.3 */
        {
            struct s2n_connection *conn = s2n_connection_new(S2N_SERVER);
            EXPECT_NOT_NULL(conn);
            conn->actual_protocol_version = S2N_TLS13;

            conn->handshake.handshake_type = INITIAL;
            conn->psk_params.type = S2N_PSK_TYPE_EXTERNAL;
            EXPECT_FALSE(s2n_connection_is_session_resumed(conn));

            conn->handshake.handshake_type = NEGOTIATED;
            conn->psk_params.type = S2N_PSK_TYPE_EXTERNAL;
            EXPECT_FALSE(s2n_connection_is_session_resumed(conn));

            conn->handshake.handshake_type = NEGOTIATED;
            conn->psk_params.type = S2N_PSK_TYPE_RESUMPTION;
            EXPECT_TRUE(s2n_connection_is_session_resumed(conn));

            EXPECT_SUCCESS(s2n_connection_free(conn));
        };
    };

    /* Session resumption APIs and session_ticket_cb return the same values
     * when receiving a new ticket in TLS1.2
     */
    {
        EXPECT_NOT_NULL(client_conn = s2n_connection_new(S2N_CLIENT));

        EXPECT_NOT_NULL(client_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_wall_clock(client_config, mock_time, NULL));
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(client_config, 1));
        EXPECT_SUCCESS(s2n_config_disable_x509_verification(client_config));

        /* Client will use callback when server nst is received */
        EXPECT_SUCCESS(s2n_config_set_session_ticket_cb(client_config, s2n_test_session_ticket_callback, NULL));
        EXPECT_SUCCESS(s2n_connection_set_config(client_conn, client_config));

        EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));
        EXPECT_NOT_NULL(server_config = s2n_config_new());
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_config, 1));
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(server_config, chain_and_key));

        /* Create nonblocking pipes */
        EXPECT_SUCCESS(s2n_connections_set_io_pair(client_conn, server_conn, &io_pair));

        /* Set session state lifetime for 15 hours which is equal to the default lifetime of a ticket key */
        EXPECT_SUCCESS(s2n_config_set_session_state_lifetime(server_config, S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS));

        /* Add one ST key */
        POSIX_GUARD(server_config->wall_clock(server_config->sys_clock_ctx, &now));
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_config, ticket_key_name1, s2n_array_len(ticket_key_name1), ticket_key1, s2n_array_len(ticket_key1), now / ONE_SEC_IN_NANOS));

        EXPECT_SUCCESS(s2n_connection_set_config(server_conn, server_config));

        EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server_conn, client_conn));

        /* Expect values from the session_ticket_cb are equivalent to values from the APIs */
        EXPECT_EQUAL(cb_session_data_len, s2n_connection_get_session_length(client_conn));
        uint8_t session_data[S2N_TLS12_SESSION_SIZE] = { 0 };
        EXPECT_SUCCESS(s2n_connection_get_session(client_conn, session_data, cb_session_data_len));
        EXPECT_BYTEARRAY_EQUAL(cb_session_data, session_data, cb_session_data_len);

        EXPECT_EQUAL(cb_session_lifetime, s2n_connection_get_session_ticket_lifetime_hint(client_conn));

        EXPECT_SUCCESS(s2n_shutdown_test_server_and_client(server_conn, client_conn));

        EXPECT_SUCCESS(s2n_connection_free(server_conn));
        EXPECT_SUCCESS(s2n_connection_free(client_conn));

        EXPECT_SUCCESS(s2n_config_free(server_config));
        EXPECT_SUCCESS(s2n_config_free(client_config));
    };

    EXPECT_SUCCESS(s2n_reset_tls13_in_test());

    /* Session resumption APIs and session_ticket_cb return the same values
     * when receiving a new ticket in TLS1.3
     */
    if (s2n_is_tls13_fully_supported()) {
        struct s2n_config *config = s2n_config_new();
        EXPECT_NOT_NULL(config);

        /* Freeze time */
        POSIX_GUARD(config->wall_clock(config->sys_clock_ctx, &now));
        EXPECT_OK(s2n_config_mock_wall_clock(config, &now));

        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(config, ecdsa_chain_and_key));
        EXPECT_SUCCESS(s2n_config_set_unsafe_for_testing(config));
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(config, 1));
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(config, ticket_key_name1, s2n_array_len(ticket_key_name1),
                ticket_key1, s2n_array_len(ticket_key1), 0));
        EXPECT_SUCCESS(s2n_config_set_cipher_preferences(config, "default_tls13"));

        /* Send one NewSessionTicket */
        cb_session_data_len = 0;
        EXPECT_SUCCESS(s2n_config_set_session_ticket_cb(config, s2n_test_session_ticket_callback, NULL));
        EXPECT_SUCCESS(s2n_config_set_initial_ticket_count(config, 1));

        EXPECT_NOT_NULL(client_conn = s2n_connection_new(S2N_CLIENT));
        EXPECT_SUCCESS(s2n_connection_set_config(client_conn, config));

        EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));
        EXPECT_SUCCESS(s2n_connection_set_blinding(server_conn, S2N_SELF_SERVICE_BLINDING));
        EXPECT_SUCCESS(s2n_connection_set_config(server_conn, config));

        EXPECT_SUCCESS(s2n_connections_set_io_pair(client_conn, server_conn, &io_pair));
        EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server_conn, client_conn));

        /* Verify that TLS1.3 was negotiated */
        EXPECT_EQUAL(client_conn->actual_protocol_version, S2N_TLS13);
        EXPECT_EQUAL(server_conn->actual_protocol_version, S2N_TLS13);

        /* Old TLS1.2 customer code will likely attempt to read the ticket here -- ensure we indicate no ticket yet */
        EXPECT_EQUAL(s2n_connection_get_session_length(client_conn), 0);

        /* Receive and save the issued session ticket for the next test */
        s2n_blocked_status blocked = S2N_NOT_BLOCKED;
        uint8_t out = 0;
        EXPECT_FAILURE_WITH_ERRNO(s2n_recv(client_conn, &out, 1, &blocked), S2N_ERR_IO_BLOCKED);
        EXPECT_NOT_EQUAL(cb_session_data_len, 0);
        EXPECT_SUCCESS(s2n_stuffer_write_bytes(&tls13_serialized_session_state, cb_session_data, cb_session_data_len));

        /* Verify correct session ticket lifetime "hint" */
        EXPECT_EQUAL(s2n_connection_get_session_ticket_lifetime_hint(client_conn), cb_session_lifetime);

        /* Verify the session ticket APIs produce the same results as the callback */
        DEFER_CLEANUP(struct s2n_blob legacy_api_ticket = { 0 }, s2n_free);
        EXPECT_SUCCESS(s2n_realloc(&legacy_api_ticket, cb_session_data_len));
        EXPECT_EQUAL(s2n_connection_get_session_length(client_conn), cb_session_data_len);
        EXPECT_SUCCESS(s2n_connection_get_session(client_conn, legacy_api_ticket.data, legacy_api_ticket.size));
        EXPECT_BYTEARRAY_EQUAL(cb_session_data, legacy_api_ticket.data, legacy_api_ticket.size);

        EXPECT_SUCCESS(s2n_shutdown_test_server_and_client(server_conn, client_conn));
        EXPECT_SUCCESS(s2n_connection_free(server_conn));
        EXPECT_SUCCESS(s2n_connection_free(client_conn));
        EXPECT_SUCCESS(s2n_config_free(config));
    }

    /* Client has TLS1.3 ticket but negotiates TLS1.2 */
    if (s2n_is_tls13_fully_supported()) {
        s2n_extension_type_id client_session_ticket_ext_id = 0, psk_ext_id = 0;
        EXPECT_SUCCESS(s2n_extension_supported_iana_value_to_id(TLS_EXTENSION_PRE_SHARED_KEY, &psk_ext_id));
        EXPECT_SUCCESS(s2n_extension_supported_iana_value_to_id(TLS_EXTENSION_SESSION_TICKET, &client_session_ticket_ext_id));

        struct s2n_config *config = s2n_config_new();
        EXPECT_NOT_NULL(config);
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(config, chain_and_key));
        EXPECT_SUCCESS(s2n_config_set_unsafe_for_testing(config));
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(config, 1));
        EXPECT_SUCCESS(s2n_config_set_session_state_lifetime(config, S2N_SESSION_STATE_CONFIGURABLE_LIFETIME_IN_SECS));
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(config, ticket_key_name1, s2n_array_len(ticket_key_name1),
                ticket_key1, s2n_array_len(ticket_key1), 0));

        EXPECT_NOT_NULL(client_conn = s2n_connection_new(S2N_CLIENT));
        EXPECT_SUCCESS(s2n_connection_set_config(client_conn, config));
        EXPECT_SUCCESS(s2n_connection_set_cipher_preferences(client_conn, "test_all"));
        EXPECT_SUCCESS(s2n_connection_set_session(client_conn, tls13_serialized_session_state.blob.data,
                s2n_stuffer_data_available(&tls13_serialized_session_state)));

        EXPECT_NOT_NULL(server_conn = s2n_connection_new(S2N_SERVER));
        EXPECT_SUCCESS(s2n_connection_set_blinding(server_conn, S2N_SELF_SERVICE_BLINDING));
        EXPECT_SUCCESS(s2n_connection_set_config(server_conn, config));
        EXPECT_SUCCESS(s2n_connection_set_cipher_preferences(server_conn, "20240501"));

        EXPECT_SUCCESS(s2n_connections_set_io_pair(client_conn, server_conn, &io_pair));
        EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server_conn, client_conn));

        /* Verify that TLS1.2 was negotiated */
        EXPECT_EQUAL(client_conn->actual_protocol_version, S2N_TLS12);
        EXPECT_EQUAL(server_conn->actual_protocol_version, S2N_TLS12);

        /* Verify that the client did NOT try to use TLS1.2 tickets */
        EXPECT_FALSE(S2N_CBIT_TEST(client_conn->extension_requests_sent, client_session_ticket_ext_id));
        EXPECT_FALSE(S2N_CBIT_TEST(client_conn->extension_requests_sent, client_session_ticket_ext_id));

        /* Verify that the client tried to use TLS1.3 tickets, but the server ignored them */
        EXPECT_TRUE(S2N_CBIT_TEST(client_conn->extension_requests_sent, psk_ext_id));
        EXPECT_FALSE(S2N_CBIT_TEST(server_conn->extension_requests_sent, psk_ext_id));

        /* Verify that a full handshake occurred instead */
        EXPECT_TRUE(IS_FULL_HANDSHAKE(client_conn));
        EXPECT_TRUE(IS_FULL_HANDSHAKE(server_conn));

        EXPECT_SUCCESS(s2n_shutdown_test_server_and_client(server_conn, client_conn));
        EXPECT_SUCCESS(s2n_connection_free(server_conn));
        EXPECT_SUCCESS(s2n_connection_free(client_conn));
        EXPECT_SUCCESS(s2n_config_free(config));
    }

    /* Test: TLS1.3 resumption is successful when key used to encrypt ticket is in decrypt-only state */
    if (s2n_is_tls13_fully_supported()) {
        DEFER_CLEANUP(struct s2n_config *client_configuration = s2n_config_new(),
                s2n_config_ptr_free);
        EXPECT_NOT_NULL(client_configuration);
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(client_configuration, 1));
        EXPECT_SUCCESS(s2n_config_set_cipher_preferences(client_configuration, "default_tls13"));
        EXPECT_SUCCESS(s2n_config_set_unsafe_for_testing(client_configuration));

        DEFER_CLEANUP(struct s2n_config *server_configuration = s2n_config_new(),
                s2n_config_ptr_free);
        EXPECT_NOT_NULL(server_configuration);
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_configuration, 1));
        EXPECT_SUCCESS(s2n_config_set_cipher_preferences(server_configuration, "default_tls13"));
        EXPECT_SUCCESS(s2n_config_set_unsafe_for_testing(server_configuration));
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(server_configuration,
                chain_and_key));

        /* Add the key that encrypted the session ticket so that the server will be able to decrypt 
         * the ticket successfully. 
         */
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_configuration, ticket_key_name1,
                s2n_array_len(ticket_key_name1), ticket_key1, s2n_array_len(ticket_key1), 0));

        /* Add a mock delay such that key 1 moves to decrypt-only state */
        uint64_t mock_delay = server_configuration->encrypt_decrypt_key_lifetime_in_nanos;
        EXPECT_SUCCESS(s2n_config_set_wall_clock(server_configuration, mock_nanoseconds_since_epoch,
                &mock_delay));

        /* Add one session ticket key with an intro time in the past so that the key is immediately valid */
        POSIX_GUARD(server_configuration->wall_clock(server_configuration->sys_clock_ctx, &now));
        uint64_t key_intro_time = (now / ONE_SEC_IN_NANOS) - ONE_SEC_DELAY;
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_configuration, ticket_key_name2,
                s2n_array_len(ticket_key_name2), ticket_key2, s2n_array_len(ticket_key2), key_intro_time));

        DEFER_CLEANUP(struct s2n_connection *client = s2n_connection_new(S2N_CLIENT),
                s2n_connection_ptr_free);
        EXPECT_NOT_NULL(client);
        EXPECT_SUCCESS(s2n_connection_set_session(client, tls13_serialized_session_state.blob.data,
                s2n_stuffer_data_available(&tls13_serialized_session_state)));
        EXPECT_SUCCESS(s2n_connection_set_config(client, client_configuration));

        DEFER_CLEANUP(struct s2n_connection *server = s2n_connection_new(S2N_SERVER),
                s2n_connection_ptr_free);
        EXPECT_NOT_NULL(server);
        EXPECT_SUCCESS(s2n_connection_set_config(server, server_configuration));

        /* Create nonblocking pipes */
        DEFER_CLEANUP(struct s2n_test_io_stuffer_pair test_io = { 0 },
                s2n_io_stuffer_pair_free);
        EXPECT_OK(s2n_io_stuffer_pair_init(&test_io));
        EXPECT_OK(s2n_connections_set_io_stuffer_pair(client, server, &test_io));

        EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server, client));

        /* Verify that TLS1.3 was negotiated */
        EXPECT_EQUAL(client->actual_protocol_version, S2N_TLS13);
        EXPECT_EQUAL(server->actual_protocol_version, S2N_TLS13);

        /* Expect a resumption handshake because the session ticket is valid.
         * If a full handshake is performed instead, then the session ticket is incorrectly
         * being evaluated as invalid. This was previously known to happen with a decrypt-only
         * key because we'd incorrectly try to set a TLS1.2-only handshake type flag,
         * triggering an error while decrypting the session ticket.
         */
        EXPECT_TRUE(IS_RESUMPTION_HANDSHAKE(server));
    }

    /* Test TLS 1.2 Server sends a zero-length ticket in the NewSessionTicket handshake
     * if the ticket key was expired after SERVER_HELLO
     */
    {
        DEFER_CLEANUP(struct s2n_config *client_configuration = s2n_config_new(),
                s2n_config_ptr_free);
        EXPECT_NOT_NULL(client_configuration);
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(client_configuration, 1));
        EXPECT_SUCCESS(s2n_config_set_unsafe_for_testing(client_configuration));
        EXPECT_SUCCESS(s2n_config_set_cipher_preferences(client_configuration, "20240501"));

        DEFER_CLEANUP(struct s2n_config *server_configuration = s2n_config_new(),
                s2n_config_ptr_free);
        EXPECT_NOT_NULL(server_configuration);
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(server_configuration, 1));
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(server_configuration,
                chain_and_key));
        EXPECT_SUCCESS(s2n_config_set_cipher_preferences(server_configuration, "20240501"));

        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(server_configuration, ticket_key_name1,
                s2n_array_len(ticket_key_name1), ticket_key1, s2n_array_len(ticket_key1), 0));

        DEFER_CLEANUP(struct s2n_connection *client = s2n_connection_new(S2N_CLIENT),
                s2n_connection_ptr_free);
        EXPECT_NOT_NULL(client);
        EXPECT_SUCCESS(s2n_connection_set_config(client, client_configuration));

        DEFER_CLEANUP(struct s2n_connection *server = s2n_connection_new(S2N_SERVER),
                s2n_connection_ptr_free);
        EXPECT_NOT_NULL(server);
        EXPECT_SUCCESS(s2n_connection_set_config(server, server_configuration));

        DEFER_CLEANUP(struct s2n_test_io_stuffer_pair test_io = { 0 },
                s2n_io_stuffer_pair_free);
        EXPECT_OK(s2n_io_stuffer_pair_init(&test_io));
        EXPECT_OK(s2n_connections_set_io_stuffer_pair(client, server, &test_io));

        /* Stop the handshake after the peers have established that a ticket 
         * will be sent in this handshake. 
         */
        EXPECT_OK(s2n_negotiate_test_server_and_client_until_message(server, client,
                CLIENT_FINISHED));

        /* Expire current session ticket key so that server no longer holds a valid key */
        uint64_t mock_delay = server_configuration->encrypt_decrypt_key_lifetime_in_nanos;
        EXPECT_SUCCESS(s2n_config_set_wall_clock(server_configuration, mock_nanoseconds_since_epoch,
                &mock_delay));

        /* Attempt to send a NewSessionTicket. This should send a zero-length NST message */
        EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server, client));

        /* Verify that TLS1.2 was negotiated */
        EXPECT_EQUAL(client->actual_protocol_version, S2N_TLS12);
        EXPECT_EQUAL(server->actual_protocol_version, S2N_TLS12);

        /* Verify that the server issued zero-length session ticket */
        EXPECT_TRUE(IS_ISSUING_NEW_SESSION_TICKET(server));

        /* Client does not have a session ticket since it received zero-length NST message */
        EXPECT_EQUAL(client->client_ticket.size, 0);
        EXPECT_EQUAL(client->ticket_lifetime_hint, 0);
    }

    /* Test: Server disables tls12 tickets */
    {
        DEFER_CLEANUP(struct s2n_config *forward_secret_config = s2n_config_new(),
                s2n_config_ptr_free);
        EXPECT_NOT_NULL(forward_secret_config);
        EXPECT_SUCCESS(s2n_config_require_ticket_forward_secrecy(forward_secret_config, true));
        EXPECT_SUCCESS(s2n_config_set_cipher_preferences(forward_secret_config, "default_tls13"));
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(forward_secret_config,
                chain_and_key));
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(forward_secret_config, 1));
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(forward_secret_config, ticket_key_name1,
                s2n_array_len(ticket_key_name1), ticket_key1, s2n_array_len(ticket_key1), 0));

        DEFER_CLEANUP(struct s2n_config *tls12_client_config = s2n_config_new(),
                s2n_config_ptr_free);
        EXPECT_NOT_NULL(tls12_client_config);
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(tls12_client_config, 1));
        EXPECT_SUCCESS(s2n_config_set_unsafe_for_testing(tls12_client_config));
        /* Security policy that does not support TLS1.3 */
        EXPECT_SUCCESS(s2n_config_set_cipher_preferences(tls12_client_config, "20240501"));

        DEFER_CLEANUP(struct s2n_config *tls13_client_config = s2n_config_new(),
                s2n_config_ptr_free);
        EXPECT_NOT_NULL(tls12_client_config);
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(tls13_client_config, 1));
        EXPECT_SUCCESS(s2n_config_set_unsafe_for_testing(tls13_client_config));
        /* Security policy that does support TLS1.3 */
        EXPECT_SUCCESS(s2n_config_set_cipher_preferences(tls13_client_config, "default_tls13"));

        /* Server does not send ticket when forward secrecy is enforced and TLS1.2 is negotiated */
        {
            DEFER_CLEANUP(struct s2n_connection *client = s2n_connection_new(S2N_CLIENT),
                    s2n_connection_ptr_free);
            EXPECT_NOT_NULL(client);
            DEFER_CLEANUP(struct s2n_connection *server = s2n_connection_new(S2N_SERVER),
                    s2n_connection_ptr_free);
            EXPECT_NOT_NULL(server);

            EXPECT_SUCCESS(s2n_connection_set_config(client, tls12_client_config));
            EXPECT_SUCCESS(s2n_connection_set_config(server, forward_secret_config));

            DEFER_CLEANUP(struct s2n_test_io_stuffer_pair test_io = { 0 },
                    s2n_io_stuffer_pair_free);
            EXPECT_OK(s2n_io_stuffer_pair_init(&test_io));
            EXPECT_OK(s2n_connections_set_io_stuffer_pair(client, server, &test_io));

            EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server, client));
            EXPECT_EQUAL(client->actual_protocol_version, S2N_TLS12);
            EXPECT_EQUAL(server->actual_protocol_version, S2N_TLS12);

            uint16_t tickets_sent = 0;
            EXPECT_SUCCESS(s2n_connection_get_tickets_sent(server, &tickets_sent));
            EXPECT_EQUAL(tickets_sent, 0);
        }

        /* Server does send tickets when forward secrecy is enforced and TLS1.3 is negotiated */
        if (s2n_is_tls13_fully_supported()) {
            DEFER_CLEANUP(struct s2n_connection *client = s2n_connection_new(S2N_CLIENT),
                    s2n_connection_ptr_free);
            EXPECT_NOT_NULL(client);
            DEFER_CLEANUP(struct s2n_connection *server = s2n_connection_new(S2N_SERVER),
                    s2n_connection_ptr_free);
            EXPECT_NOT_NULL(server);

            EXPECT_SUCCESS(s2n_connection_set_config(client, tls13_client_config));
            EXPECT_SUCCESS(s2n_connection_set_config(server, forward_secret_config));

            DEFER_CLEANUP(struct s2n_test_io_stuffer_pair test_io = { 0 },
                    s2n_io_stuffer_pair_free);
            EXPECT_OK(s2n_io_stuffer_pair_init(&test_io));
            EXPECT_OK(s2n_connections_set_io_stuffer_pair(client, server, &test_io));

            EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server, client));
            EXPECT_EQUAL(client->actual_protocol_version, S2N_TLS13);
            EXPECT_EQUAL(server->actual_protocol_version, S2N_TLS13);

            uint16_t tickets_sent = 0;
            EXPECT_SUCCESS(s2n_connection_get_tickets_sent(server, &tickets_sent));
            EXPECT_EQUAL(tickets_sent, 1);
        }

        /* Server does not accept valid TLS1.2 ticket when forward secrecy is enforced */
        {
            DEFER_CLEANUP(struct s2n_connection *client = s2n_connection_new(S2N_CLIENT),
                    s2n_connection_ptr_free);
            EXPECT_NOT_NULL(client);
            DEFER_CLEANUP(struct s2n_connection *server = s2n_connection_new(S2N_SERVER),
                    s2n_connection_ptr_free);
            EXPECT_NOT_NULL(server);

            /* Disable forward secrecy for the first handshake */
            EXPECT_SUCCESS(s2n_config_require_ticket_forward_secrecy(forward_secret_config, false));

            EXPECT_SUCCESS(s2n_connection_set_config(client, tls12_client_config));
            EXPECT_SUCCESS(s2n_connection_set_config(server, forward_secret_config));

            DEFER_CLEANUP(struct s2n_test_io_stuffer_pair test_io = { 0 },
                    s2n_io_stuffer_pair_free);
            EXPECT_OK(s2n_io_stuffer_pair_init(&test_io));
            EXPECT_OK(s2n_connections_set_io_stuffer_pair(client, server, &test_io));

            EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server, client));
            EXPECT_EQUAL(client->actual_protocol_version, S2N_TLS12);
            EXPECT_EQUAL(server->actual_protocol_version, S2N_TLS12);

            uint16_t tickets_sent = 0;
            EXPECT_SUCCESS(s2n_connection_get_tickets_sent(server, &tickets_sent));
            EXPECT_EQUAL(tickets_sent, 1);

            uint8_t session_data[S2N_TLS12_SESSION_SIZE] = { 0 };
            EXPECT_SUCCESS(s2n_connection_get_session(client, session_data, sizeof(session_data)));

            /* Enable forward secrecy for the second handshake */
            EXPECT_SUCCESS(s2n_config_require_ticket_forward_secrecy(forward_secret_config, true));

            EXPECT_SUCCESS(s2n_connection_wipe(client));
            EXPECT_SUCCESS(s2n_connection_wipe(server));

            EXPECT_SUCCESS(s2n_connection_set_session(client, session_data, sizeof(session_data)));

            EXPECT_SUCCESS(s2n_connection_set_config(client, tls12_client_config));
            EXPECT_SUCCESS(s2n_connection_set_config(server, forward_secret_config));
            EXPECT_OK(s2n_connections_set_io_stuffer_pair(client, server, &test_io));

            EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server, client));
            EXPECT_EQUAL(client->actual_protocol_version, S2N_TLS12);
            EXPECT_EQUAL(server->actual_protocol_version, S2N_TLS12);

            /* Session ticket not accepted */
            EXPECT_TRUE(IS_FULL_HANDSHAKE(client));
            EXPECT_TRUE(IS_FULL_HANDSHAKE(server));

            /* No ticket issued */
            EXPECT_SUCCESS(s2n_connection_get_tickets_sent(server, &tickets_sent));
            EXPECT_EQUAL(tickets_sent, 0);
        }
    }

    /* Test: Client disables tls12 tickets */
    {
        DEFER_CLEANUP(struct s2n_config *forward_secret_config = s2n_config_new(),
                s2n_config_ptr_free);
        EXPECT_NOT_NULL(forward_secret_config);
        EXPECT_SUCCESS(s2n_config_require_ticket_forward_secrecy(forward_secret_config, true));
        EXPECT_SUCCESS(s2n_config_set_cipher_preferences(forward_secret_config, "default_tls13"));
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(forward_secret_config, 1));
        EXPECT_SUCCESS(s2n_config_set_unsafe_for_testing(forward_secret_config));

        DEFER_CLEANUP(struct s2n_config *tls12_server_config = s2n_config_new(),
                s2n_config_ptr_free);
        EXPECT_NOT_NULL(tls12_server_config);
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(tls12_server_config, 1));
        /* Security policy that does not support TLS1.3 */
        EXPECT_SUCCESS(s2n_config_set_cipher_preferences(tls12_server_config, "20240501"));
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(tls12_server_config,
                chain_and_key));
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(tls12_server_config, ticket_key_name1,
                s2n_array_len(ticket_key_name1), ticket_key1, s2n_array_len(ticket_key1), 0));

        DEFER_CLEANUP(struct s2n_config *tls13_server_config = s2n_config_new(),
                s2n_config_ptr_free);
        EXPECT_NOT_NULL(tls13_server_config);
        EXPECT_SUCCESS(s2n_config_set_session_tickets_onoff(tls13_server_config, 1));
        /* Security policy that does support TLS1.3 */
        EXPECT_SUCCESS(s2n_config_set_cipher_preferences(tls13_server_config, "default_tls13"));
        EXPECT_SUCCESS(s2n_config_add_cert_chain_and_key_to_store(tls13_server_config,
                chain_and_key));
        EXPECT_SUCCESS(s2n_config_add_ticket_crypto_key(tls13_server_config, ticket_key_name1,
                s2n_array_len(ticket_key_name1), ticket_key1, s2n_array_len(ticket_key1), 0));

        /* No ticket is received when forward secrecy is enforced and TLS1.2 is negotiated */
        {
            DEFER_CLEANUP(struct s2n_connection *client = s2n_connection_new(S2N_CLIENT),
                    s2n_connection_ptr_free);
            EXPECT_NOT_NULL(client);
            DEFER_CLEANUP(struct s2n_connection *server = s2n_connection_new(S2N_SERVER),
                    s2n_connection_ptr_free);
            EXPECT_NOT_NULL(server);

            EXPECT_SUCCESS(s2n_connection_set_config(client, forward_secret_config));
            EXPECT_SUCCESS(s2n_connection_set_config(server, tls12_server_config));

            DEFER_CLEANUP(struct s2n_test_io_stuffer_pair test_io = { 0 },
                    s2n_io_stuffer_pair_free);
            EXPECT_OK(s2n_io_stuffer_pair_init(&test_io));
            EXPECT_OK(s2n_connections_set_io_stuffer_pair(client, server, &test_io));

            EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server, client));

            EXPECT_EQUAL(client->actual_protocol_version, S2N_TLS12);
            EXPECT_EQUAL(server->actual_protocol_version, S2N_TLS12);

            EXPECT_EQUAL(client->client_ticket.size, 0);
        }

        /* A ticket is received when forward secrecy is enforced and TLS1.3 is negotiated */
        if (s2n_is_tls13_fully_supported()) {
            DEFER_CLEANUP(struct s2n_connection *client = s2n_connection_new(S2N_CLIENT),
                    s2n_connection_ptr_free);
            EXPECT_NOT_NULL(client);
            DEFER_CLEANUP(struct s2n_connection *server = s2n_connection_new(S2N_SERVER),
                    s2n_connection_ptr_free);
            EXPECT_NOT_NULL(server);

            EXPECT_SUCCESS(s2n_connection_set_config(client, forward_secret_config));
            EXPECT_SUCCESS(s2n_connection_set_config(server, tls13_server_config));

            DEFER_CLEANUP(struct s2n_test_io_stuffer_pair test_io = { 0 },
                    s2n_io_stuffer_pair_free);
            EXPECT_OK(s2n_io_stuffer_pair_init(&test_io));
            EXPECT_OK(s2n_connections_set_io_stuffer_pair(client, server, &test_io));

            EXPECT_SUCCESS(s2n_negotiate_test_server_and_client(server, client));

            EXPECT_EQUAL(client->actual_protocol_version, S2N_TLS13);
            EXPECT_EQUAL(server->actual_protocol_version, S2N_TLS13);

            /* Do a recv call to pick up TLS1.3 ticket */
            uint8_t data = 1;
            s2n_blocked_status blocked = S2N_NOT_BLOCKED;
            EXPECT_FAILURE_WITH_ERRNO(s2n_recv(client, &data, 1, &blocked), S2N_ERR_IO_BLOCKED);

            EXPECT_NOT_EQUAL(client->client_ticket.size, 0);
        }
    }

    EXPECT_SUCCESS(s2n_io_pair_close(&io_pair));
    EXPECT_SUCCESS(s2n_cert_chain_and_key_free(chain_and_key));
    EXPECT_SUCCESS(s2n_cert_chain_and_key_free(ecdsa_chain_and_key));
    free(cert_chain);
    free(private_key);
    END_TEST();
}
