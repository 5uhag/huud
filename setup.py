from setuptools import setup, find_packages

setup(
    name='huud',
    version='1.0.0',
    packages=['backend'],
    install_requires=[
        'flask',
        'flask-cors',
        'psutil',
        'GPUtil',
        'pynvml'
    ],
    entry_points={
        'console_scripts': [
            'huud=backend.app:start_server',
        ],
    },
)
