from setuptools import setup, find_packages
from setuptools.extension import Extension

#from Cython.Build import cythonize


extensions = [
    Extension(
        'pcre2',
        sources=[
            'src/pcre2.pyx',
        ],
        extra_link_args=[],
        extra_compile_args=['-DPCRE2_CODE_UNIT_WIDTH=8'],
        library_dirs=[],
        libraries=['pcre2-8'],
        include_dirs=[],
    ),
]


setup(
    name = 'pcre2',
    version = '0.1',
    packages = find_packages(),
    include_package_data = True,

    entry_points = {
        'console_scripts': [
        ],
    },

    setup_requires = [
        'setuptools>=18.0',
        'cython',
    ], 

    install_requires = [
        'Cython',
    ],

    ext_modules = extensions,

    author = 'Gu Pengfei',
    author_email = 'gpfei96@gmail.com',
    description = 'A Python wrapper for PCRE2',
    license = 'MIT',
)

