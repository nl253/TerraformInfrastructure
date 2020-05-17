#!/usr/bin/python3
from concurrent.futures import ProcessPoolExecutor as Pool, Future
from os import chdir
from os.path import dirname, abspath, relpath
from pathlib import Path
from subprocess import run, PIPE, DEVNULL, CompletedProcess
from sys import stderr
from typing import Iterator, List


def task(script: str) -> CompletedProcess:
    chdir(dirname(script))
    print(run(['terraform', 'init'], stderr=PIPE, stdout=DEVNULL).stderr.decode('utf-8'), end='')
    return run(
        (["python3"] if script.endswith('py') else ['bash', '-c']) + [script],
        stdout=PIPE,
        stderr=PIPE
    )


def find_tests(ext: str) -> Iterator[str]:
    return map(str, filter(lambda p: p.is_file(), map(lambda p: p.resolve(), Path('.').glob(f'./*/test.{ext}'))))


chdir(dirname(abspath(__file__)))

tests: List[str] = list(find_tests('sh')) + \
                   list(find_tests('py'))

tasks: List[Future] = []

failures = 0

print(f'collected {len(tests)} tests')

with Pool(min(4, len(tests))) as p:
    for idx, t in enumerate(tests):
        print(f'#{idx} running tests in {relpath(t)}')
        tasks.append(p.submit(task, t))

for idx, task in enumerate(tasks):
    t: str = tests[idx]
    print(f"#{idx} test results from {relpath(t)}")
    process: CompletedProcess = task.result()
    if process.returncode > 0:
        failures += 1
        print(f'ERROR failed test in {t} - {process.stderr.decode("utf-8")}', file=stderr)
    else:
        print(f'output from {t}:')
        print(process.stdout.decode('utf-8'))

if failures > 0:
    raise Exception(f'ERROR {failures}/{len(tests)} tests failed')
