import os

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split

import settings as s
import helpers as h


INPUTS_FILES = {'clean_train.csv': {}}
OUTPUTS_FILES = {'X_train.txt': {'delimiter': ','},
                 'X_val.txt': {'delimiter': ','},
                 'y_train.txt': {'delimiter': ','},
                 'y_val.txt': {'delimiter': ','}}
FILENAME = os.path.basename(os.path.abspath(__file__)).split('.')[0]


def split(df):
    X, y = df.values[:, 1:], df.values[:, 0].reshape(len(df), 1)

    return train_test_split(X, y, test_size=0.2, random_state=42)


def task(clean_train):
    '''
    data dependencies: `clean_train`
    data outputs: `X_train`; `X_val`; `y_train`; `y_test`
    '''
    return split(clean_train)


if __name__ == '__main__':

    try:
        s.logging.warning('Starting {file}'.format(file=FILENAME))

        inputs = h.read_inputs(s.INPUT_PREFIX, INPUTS_FILES)
        outputs = task(*inputs)
        h.save_outputs(s.OUTPUT_PREFIX, outputs, OUTPUTS_FILES)

    except Exception as e:
        s.logging.error(str(e))
        raise e
