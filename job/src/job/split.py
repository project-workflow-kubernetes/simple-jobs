import os

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split

import settings as s


INPUTS = ['clean_train.csv']
OUTPUTS = ['X_train.csv', 'X_val.csv', 'y_train.csv', 'y_val.csv']



def split(df):
    X, y = df.values[:, 1:], df.values[:, 0].reshape(len(df), 1)

    return train_test_split(X, y, test_size=0.2, random_state=42)




if __name__ == '__main__':
    '''
    data dependencies: `train.csv`
    data outputs: `X_train.csv`; `X_val.csv`; `y_train.csv`; `y_test`
    '''
    input_path = os.path.join(s.INPUT_PREFIX, INPUTS[0])

    df = pd.read_csv(input_path)

    X_train, X_val, y_train, y_val = split(df)

    np.savetxt(os.path.join(s.OUTPUT_PREFIX, OUTPUTS[0]), X_train, delimiter=',')
    np.savetxt(os.path.join(s.OUTPUT_PREFIX, OUTPUTS[1]), X_val, delimiter=',')
    np.savetxt(os.path.join(s.OUTPUT_PREFIX, OUTPUTS[2]), y_train, delimiter=',')
    np.savetxt(os.path.join(s.OUTPUT_PREFIX, OUTPUTS[3]), y_val, delimiter=',')
