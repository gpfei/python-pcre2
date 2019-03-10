# -*- coding: utf-8 -*-
# cython: c_string_type=unicode, c_string_encoding=utf8
from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free
from libc.stdint cimport uint32_t
from libc.string cimport memcpy, memset, strlen

from src cimport _pcre2

ctypedef int(*match_func_type)(
        const _pcre2.pcre2_code *,
        _pcre2.PCRE2_SPTR,
        _pcre2.PCRE2_SIZE,
        _pcre2.PCRE2_SIZE,
        uint32_t,
        _pcre2.pcre2_match_data *,
        _pcre2.pcre2_match_context *)

# jit
JIT_COMPLETE = _pcre2.PCRE2_JIT_COMPLETE
JIT_PARTIAL_SOFT = _pcre2.PCRE2_JIT_PARTIAL_SOFT
JIT_PARTIAL_HARD = _pcre2.PCRE2_JIT_PARTIAL_HARD

# compile options
ALLOW_EMPTY_CLASS = _pcre2.PCRE2_ALLOW_EMPTY_CLASS
ALT_BSUX = _pcre2.PCRE2_ALT_BSUX
AUTO_CALLOUT = _pcre2.PCRE2_AUTO_CALLOUT
CASELESS = _pcre2.PCRE2_CASELESS
DOLLAR_ENDONLY = _pcre2.PCRE2_DOLLAR_ENDONLY
DOTALL = _pcre2.PCRE2_DOTALL
DUPNAMES = _pcre2.PCRE2_DUPNAMES
EXTENDED = _pcre2.PCRE2_EXTENDED
FIRSTLINE = _pcre2.PCRE2_FIRSTLINE
MATCH_UNSET_BACKREF = _pcre2.PCRE2_MATCH_UNSET_BACKREF
MULTILINE = _pcre2.PCRE2_MULTILINE
NEVER_UCP = _pcre2.PCRE2_NEVER_UCP
NEVER_UTF = _pcre2.PCRE2_NEVER_UTF
NO_AUTO_CAPTURE = _pcre2.PCRE2_NO_AUTO_CAPTURE
NO_AUTO_POSSESS = _pcre2.PCRE2_NO_AUTO_POSSESS
NO_DOTSTAR_ANCHOR = _pcre2.PCRE2_NO_DOTSTAR_ANCHOR
NO_START_OPTIMIZE = _pcre2.PCRE2_NO_START_OPTIMIZE
UCP = _pcre2.PCRE2_UCP
UNGREEDY = _pcre2.PCRE2_UNGREEDY
UTF = _pcre2.PCRE2_UTF
NEVER_BACKSLASH_C = _pcre2.PCRE2_NEVER_BACKSLASH_C
ALT_CIRCUMFLEX = _pcre2.PCRE2_ALT_CIRCUMFLEX
ALT_VERBNAMES = _pcre2.PCRE2_ALT_VERBNAMES
USE_OFFSET_LIMIT = _pcre2.PCRE2_USE_OFFSET_LIMIT


cdef class PCRE2:
    cdef unsigned char * _pattern
    cdef int error_number
    cdef _pcre2.PCRE2_SIZE error_offset
    cdef _pcre2.pcre2_code* re_code
    cdef _pcre2.pcre2_match_data* match_data
    cdef match_func_type match_func

    def __cinit__(self,
                  bytes pattern,
                  uint32_t options=0,
                  uint32_t jit_option=_pcre2.PCRE2_JIT_COMPLETE):
        cdef size_t length = len(pattern)
        self._pattern = <unsigned char *>PyMem_Malloc((length + 1) * sizeof(unsigned char))
        if not self._pattern:
            raise MemoryError()

        memcpy(self._pattern, <unsigned char *>pattern, length)
        self._pattern[length] = b'\0'

        self.re_code = _pcre2.pcre2_compile(
            <_pcre2.PCRE2_SPTR>self._pattern,
            _pcre2.PCRE2_ZERO_TERMINATED,
            options,
            &self.error_number,
            &self.error_offset,
            NULL
        )
        if not self.re_code:
            raise ValueError(
                'Failed to compile pattern at offset: {}.'.format(self.error_offset))

        if _pcre2.pcre2_jit_compile(self.re_code, jit_option) == 0:
            self.match_func = _pcre2.pcre2_jit_match
        else:
            self.match_func = _pcre2.pcre2_match
        self.match_data = _pcre2.pcre2_match_data_create_from_pattern(self.re_code, NULL)

    def search(self, bytes content, int offset=0):
        cdef int match_count

        match_count = self.match_func(
            self.re_code,
            <_pcre2.PCRE2_SPTR>content,
            len(content),
            offset,
            0,
            self.match_data,
            NULL
        )
        if match_count < 0:
            if match_count == _pcre2.PCRE2_ERROR_NOMATCH:
                # Not found
                return None
            else:
                # Match error
                return None

        if match_count == 0:
            print("ovector was not big enough for all the captured substrings")

        return ResultFactory(content, match_count, self.match_data)

    def __dealloc__(self):
        if self._pattern:
            PyMem_Free(self._pattern)
            self._pattern = NULL
        if self.match_data:
            _pcre2.pcre2_match_data_free(self.match_data)
            self.match_data = NULL
        if self.re_code:
            _pcre2.pcre2_code_free(self.re_code)
            self.re_code = NULL


cdef Result ResultFactory(bytes content, int match_count, _pcre2.pcre2_match_data* match_data):
    cdef Result res = Result()
    cdef bytes substring
    cdef _pcre2.PCRE2_SIZE* ovector = _pcre2.pcre2_get_ovector_pointer(match_data)
    cdef int i

    for i in range(match_count):
        substring = content[ovector[2*i]:ovector[2*i+1]]
        res.add_match(substring)

    return res


cdef class Result:
    cdef list matches

    def __init__(self):
        self.matches = list()

    def add_match(self, bytes substring):
        self.matches.append(substring)

    def group(self, index):
        return self.matches[index]

    def groups(self):
        return self.matches[1:]
