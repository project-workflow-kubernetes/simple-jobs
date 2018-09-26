import os

import numpy as np

from sklearn.neural_network import MLPClassifier
from sklearn.externals import joblib

from job import settings as s


if __name__ == '__main__':
    '''
    data dependencies: `X_train.csv`, `X_val.csv`, `y_train`, `y_val`
    data outputs: `trained_model.pkl`
    '''
    X_train = np.loadtxt(os.path.join(s.RESOURCES_PATH, 'X_train.csv'),
                         delimiter=',',
                         dtype=np.float32)

    X_val = np.loadtxt(os.path.join(s.RESOURCES_PATH, 'X_val.csv'),
                       delimiter=',',
                       dtype=np.float32)

    y_train = np.loadtxt(os.path.join(s.RESOURCES_PATH, 'y_train.csv'),
                         delimiter=',',
                         dtype=np.float32)

    y_val = np.loadtxt(os.path.join(s.RESOURCES_PATH, 'y_val.csv'),
                       delimiter=',',
                       dtype=np.float32)

    clf = MLPClassifier(solver='adam', hidden_layer_sizes=350, alpha=1e-04)
    clf.fit(X_train, y_train)

    score = clf.score(X_val, y_val)
    print('Final score: {}'.format(score))

    joblib.dump(clf, os.path.join(s.RESOURCES_PATH, 'trained_model.pkl'))
