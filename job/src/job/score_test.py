import os

import numpy as np
import pandas as pd
from sklearn.externals import joblib

from job import settings as s


INPUT_PREFIX = s.RESOURCES_PATH
OUTPUT_PREFIX = s.RESOURCES_PATH
INPUTS = ['trained_model.pkl', 'clean_test.csv']
OUTPUTS = ['scored_test.csv']


if __name__ == '__main__':
    '''
    data dependencies: `X_test.csv`, `trained_model.pkl`
    data outputs: `scores_test.csv
    '''

    X_test = (pd.read_csv(os.path.join(INPUT_PREFIX, INPUTS[1])).values)
    clf = joblib.load(os.path.join(INPUT_PREFIX, INPUTS[0]))
    preds = pd.DataFrame(clf.predict(X_test))

    preds.to_csv(os.path.join(OUTPUT_PREFIX, 'scored_test.csv'), index=False)
