from libc.stdint cimport uint8_t, uint32_t

cdef extern from "pcre2.h":
    enum:
        PCRE2_ZERO_TERMINATED
        PCRE2_ERROR_NOMATCH

        # jit
        PCRE2_JIT_COMPLETE
        PCRE2_JIT_PARTIAL_SOFT
        PCRE2_JIT_PARTIAL_HARD

        # compile options
        PCRE2_ALLOW_EMPTY_CLASS
        PCRE2_ALT_BSUX
        PCRE2_AUTO_CALLOUT
        PCRE2_CASELESS
        PCRE2_DOLLAR_ENDONLY
        PCRE2_DOTALL
        PCRE2_DUPNAMES
        PCRE2_EXTENDED
        PCRE2_FIRSTLINE
        PCRE2_MATCH_UNSET_BACKREF
        PCRE2_MULTILINE
        PCRE2_NEVER_UCP
        PCRE2_NEVER_UTF
        PCRE2_NO_AUTO_CAPTURE
        PCRE2_NO_AUTO_POSSESS
        PCRE2_NO_DOTSTAR_ANCHOR
        PCRE2_NO_START_OPTIMIZE
        PCRE2_UCP
        PCRE2_UNGREEDY
        PCRE2_UTF
        PCRE2_NEVER_BACKSLASH_C
        PCRE2_ALT_CIRCUMFLEX
        PCRE2_ALT_VERBNAMES
        PCRE2_USE_OFFSET_LIMIT
        #

    cdef struct pcre2_real_general_context:
        pass
    ctypedef pcre2_real_general_context pcre2_general_context

    cdef struct pcre2_real_compile_context:
        pass
    ctypedef pcre2_real_compile_context pcre2_compile_context

    cdef struct pcre2_real_match_context:
        pass
    ctypedef pcre2_real_match_context pcre2_match_context

    cdef struct pcre2_real_code:
        pass
    ctypedef pcre2_real_code pcre2_code

    cdef struct pcre2_real_match_data:
        pass
    ctypedef pcre2_real_match_data pcre2_match_data

    ctypedef const uint8_t * PCRE2_SPTR
    ctypedef size_t PCRE2_SIZE

    # compile and match
    pcre2_code *pcre2_compile(PCRE2_SPTR, PCRE2_SIZE, uint32_t, int *, PCRE2_SIZE *, pcre2_compile_context *)
    int pcre2_match(const pcre2_code *, PCRE2_SPTR, PCRE2_SIZE, PCRE2_SIZE, uint32_t, pcre2_match_data *, pcre2_match_context *)
    # jit
    int pcre2_jit_compile(pcre2_code *, uint32_t)
    int pcre2_jit_match(const pcre2_code *, PCRE2_SPTR, PCRE2_SIZE, PCRE2_SIZE, uint32_t, pcre2_match_data *, pcre2_match_context *)

    # match data
    pcre2_match_data *pcre2_match_data_create_from_pattern(const pcre2_code *, pcre2_general_context *)
    void pcre2_match_data_free(pcre2_match_data *)

    # re code
    void pcre2_code_free(pcre2_code *)

    PCRE2_SIZE *pcre2_get_ovector_pointer(pcre2_match_data *)
