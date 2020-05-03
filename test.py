#!/usr/bin/python3

from pathlib import Path
from subprocess import run, PIPE
from typing import Iterator
from os import chdir
from os.path import dirname


def find_test_files(ext: str) -> Iterator[str]:
    return map(str, filter(lambda p: p.is_file(), map(lambda p: p.resolve(), Path('.').glob(f'*/test.{ext}'))))


for ext in ['py', 'sh']:
    for script in find_test_files(ext):
        chdir(dirname(script))
        print(f"running tests in {script}")
        process = run(["python3", script] if ext == 'py' else ['bash', '-c', script], stdout=PIPE)
        output = process.stdout.decode('utf-8')
        print(f'output from {script}:')
        print(output)
