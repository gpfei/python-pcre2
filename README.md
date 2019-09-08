# python-pcre2
A simple Python wrapper of [PCRE2](http://www.pcre.org/)


### Requirements
- Python 3.5+
- Cython
- libpcre2 + header file


### Example

```python
>>> import pcre2
>>> p = pcre2.PCRE2(r'(hello) (.+)'.encode())  # compile
>>> result = p.search('hello world'.encode())
>>> result.groups()
[b'hello', b'world']
>>> result.group(0)
b'hello world'
>>> result.group(1)
b'hello'
>>> result.group(2)
b'world'
```

For non-Latin word (`\w`) match, you should specify UTF and UCP option:

```python
>>> p = pcre2.PCRE2(r'(北京)(\w+)广场'.encode(), pcre2.UTF | pcre2.UCP)
>>> result = p.search('我来到北京敏感词广场看日出东方'.encode())
>>> result.groups()
[b'\xe5\x8c\x97\xe4\xba\xac', b'\xe6\x95\x8f\xe6\x84\x9f\xe8\xaf\x8d']
>>> result.group(0).decode()
'北京敏感词广场'
```


### Notes

- Pattern and Searched Text should be `bytes` type with `UTF-8` charset.
- Matched result is also encoded with `UTF-8`


### UTF-16/32 Support

If you want to match UTF-16 bytes (UTF-32 is similar), you could modify the settings in `setup.py` and then reinstall.

```python

extra_compile_args=['-DPCRE2_CODE_UNIT_WIDTH=8']
  => extra_compile_args=['-DPCRE2_CODE_UNIT_WIDTH=16']

libraries=['pcre2-8']
  => libraries=['pcre2-16']

```
