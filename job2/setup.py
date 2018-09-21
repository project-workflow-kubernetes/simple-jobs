#!/usr/bin/env python
from setuptools import setup, find_packages

setup(name='job3',
      url='',
      author='',
      package_dir={'': 'src'},
      packages=find_packages('src'),
      version='0.0.1',
      install_requires=['pandas==0.23.0',
                        'numpy==1.14.3'],
      include_package_data=True,
      zip_safe=False)