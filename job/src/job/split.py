import os

import numpy as np
import pandas as pd
from sklearn.model_selection import train_test_split

import settings as s


def split(prefix_path):
    input_path = os.path.join(prefix_path, 'clean_train.csv')
    output_paths = [os.path.join(prefix_path, x + '.csv')
                    for x in ['X_train', 'X_val', 'y_train', 'y_test']]

    df = pd.read_csv(input_path)
    X, y = df.values[:, 1:], df.values[:, 0].reshape(len(df), 1)

    X_train, X_val, y_train, y_val = train_test_split(
        X, y, test_size=0.2, random_state=42)

    np.savetxt(os.path.join(prefix_path, 'X_train' + '.csv'),
               X_train, delimiter=',')
    np.savetxt(os.path.join(prefix_path, 'X_val' + '.csv'),
               X_val, delimiter=',')
    np.savetxt(os.path.join(prefix_path, 'y_train' + '.csv'),
               y_train, delimiter=',')
    np.savetxt(os.path.join(prefix_path, 'y_val' + '.csv'),
               y_val, delimiter=',')


if __name__ == '__main__':
    '''
    data dependencies: `train.csv`
    data outputs: `X_train.csv`; `X_val.csv`; `y_train.csv`; `y_test`
    '''
    split(s.RESOURCES_PATH)
