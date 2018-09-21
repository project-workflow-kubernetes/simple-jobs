import os

import numpy as np
import pandas as pd
from sklearn.externals import joblib

from job import settings as s


if __name__ == '__main__':
    '''
    data dependencies: `X_test.csv`, `trained_model.pkl`
    data outputs: `scores_test.csv
    '''

    X_test = (pd.read_csv(os.path.join(s.RESOURCES_PATH, 'clean.csv'))
              .values)
    clf = joblib.load(os.path.join(s.RESOURCES_PATH, 'trained_model.pkl'))
    preds = pd.DataFrame(clf.predict(X_test))

    preds.to_csv(os.path.join(s.RESOURCES_PATH, 'scores_test.csv'), index=False)
