#!/usr/bin/python3

from pathlib import Path
from subprocess import run, PIPE
from typing import Iterator
from os import chdir
from os.path import dirname

ROOT = dirname(__file__)

chdir(ROOT)


def find_test_files(ext: str) -> Iterator[str]:
    return map(str, filter(lambda p: p.is_file(), map(lambda p: p.resolve(), Path('.').glob(f'./*/test.{ext}'))))


tests = list(find_test_files('sh')) + list(find_test_files('py'))

print(f'collected tests {tests}')

for script in tests:
    chdir(dirname(script))
    print(f"running tests in {script}")
    process = run(["python3", script] if script.endswith('py') else ['bash', '-c', script], stdout=PIPE)
    output = process.stdout.decode('utf-8')
    print(f'output from {script}:')
    print(output)
