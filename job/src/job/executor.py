import os
import argparse
from time import time
import subprocess as sp


RESOURCES_PATH = os.path.join(os.path.abspath(os.path.join(__file__, '../../..')), 'resources')
LOGS_PREFIX = os.environ['LOGS_OUTPUT_PATH'] if os.environ.get('LOGS_OUTPUT_PATH', None) else RESOURCES_PATH
LOGS_PATH = os.path.join(LOGS_PREFIX, 'logs.log')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("cmd", help="cmd", type=str)
    args = parser.parse_args()
    cmd = args.cmd

    process = sp.Popen(cmd,
                       stdin=sp.PIPE,
                       stdout=sp.PIPE,
                       stderr=sp.STDOUT,
                       close_fds=True,
                       shell=True)

    while process.poll() == 0:
        time.sleep(0.1)

    out, err = process.communicate()
    out = out.decode('utf-8').split('\n') if out else out
    err = err.decode('utf-8').split('\n') if err else err

    with open(LOGS_PATH, "a") as fp:
        if out:
            for o in out:
                fp.write("%s\n" % o)
        if err:
            for e in err:
                fp.write("%s\n" % e)
