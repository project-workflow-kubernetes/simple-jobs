import os

import numpy as np

from sklearn.neural_network import MLPClassifier
from sklearn.externals import joblib

from job import settings as s

INPUTS = ['X_train.csv', 'X_val.csv', 'y_train.csv', 'y_val.csv']
OUTPUTS = ['trained_model.pkl']


if __name__ == '__main__':
    '''
    data dependencies: `X_train.csv`, `X_val.csv`, `y_train`, `y_val`
    data outputs: `trained_model.pkl`
    '''
    X_train = np.loadtxt(os.path.join(s.INPUT_PREFIX, INPUTS[0]),
                         delimiter=',',
                         dtype=np.float32)

    X_val = np.loadtxt(os.path.join(s.INPUT_PREFIX, INPUTS[1]),
                       delimiter=',',
                       dtype=np.float32)

    y_train = np.loadtxt(os.path.join(s.INPUT_PREFIX, INPUTS[2]),
                         delimiter=',',
                         dtype=np.float32)

    y_val = np.loadtxt(os.path.join(s.INPUT_PREFIX, INPUTS[3]),
                       delimiter=',',
                       dtype=np.float32)

    print(X_train.shape)
    print(y_train.shape)

    clf = MLPClassifier(solver='adam', hidden_layer_sizes=350, alpha=1e-03)
    clf.fit(X_train, y_train)

    score = clf.score(X_val, y_val)
    print('Final score: {}'.format(score))

    joblib.dump(clf, os.path.join(s.OUTPUT_PREFIX, OUTPUTS[0]))
