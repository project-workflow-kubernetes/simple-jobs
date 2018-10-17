import os

import numpy as np

from sklearn.neural_network import MLPClassifier

import settings as s
import helpers as h

INPUTS_FILES = {'X_train.txt': {'delimiter': ',', 'dtype': np.float32},
                'X_val.txt': {'delimiter': ',', 'dtype': np.float32},
                'y_train.txt': {'delimiter': ',', 'dtype': np.float32},
                'y_val.txt': {'delimiter': ',', 'dtype': np.float32}}
OUTPUTS_FILES = {'trained_model.pkl': {}}
FILENAME = os.path.basename(os.path.abspath(__file__)).split('.')[0]


def task(X_train, X_val, y_train, y_val):
    '''
    data dependencies: `X_train`, `X_val`, `y_train`, `y_val`
    data outputs: `trained_model`
    '''
    clf = MLPClassifier(solver='adam', hidden_layer_sizes=350, alpha=1e-03)
    clf.fit(X_train, y_train)

    score = clf.score(X_val, y_val)
    s.logging.warning('Score {score}'.format(score=score))

    return [clf]


if __name__ == '__main__':

    try:
        s.logging.warning('Starting {file}'.format(file=FILENAME))

        inputs = h.read_inputs(s.INPUT_PREFIX, INPUTS_FILES)
        outputs = task(*inputs)
        h.save_outputs(s.OUTPUT_PREFIX, outputs, OUTPUTS_FILES)

    except Exception as e:
        s.logging.error(str(e))
        raise e
