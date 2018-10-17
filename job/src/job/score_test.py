import os

import pandas as pd
from sklearn.externals import joblib

import settings as s
import helpers as h


INPUTS_FILES = {'trained_model.pkl': {}, 'clean_test.csv': {}}
OUTPUTS_FILES = {'scored_test.csv': {}}
FILENAME = os.path.basename(os.path.abspath(__file__)).split('.')[0]


def task(trained_model, clean_test):
    '''
    data dependencies: `X_test`, `trained_model`
    data outputs: `scores_test
    '''
    preds = pd.DataFrame(trained_model.predict(clean_test))

    return [preds]



if __name__ == '__main__':

    try:
        s.logging.info('Starting {file}'.format(file=FILENAME))

        inputs = h.read_inputs(s.INPUT_PREFIX, INPUTS_FILES)
        outputs = task(*inputs)
        h.save_outputs(s.OUTPUT_PREFIX, outputs, OUTPUTS_FILES, FILENAME)

    except Exception as e:
        s.logging.error(str(e))
        raise e
