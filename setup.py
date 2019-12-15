#!/usr/bin/env python
import os
import sys

try:
    from setuptools import setup, find_packages
except ImportError:
    from distutils.core import setup, find_packages

# readme = open('README.rst').read()

setup(
    name="evolution_challenge",
    version="1.0",
    description="Code Challenge for Evolution Virtual",
    author="Noemi Millman",
    author_email="noemi@triopter.com",
    packages=find_packages(),
    include_package_data=True,
    install_requires=["django", "psycopg2"],
    license="Proprietary. All Rights Reserved.",
    zip_safe=False,
)
