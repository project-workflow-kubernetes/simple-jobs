import os

import pandas as pd

import settings as s


def clean(prefix_path, train=True):
    data_type = 'train' if train else 'test'
    input_path = os.path.join(prefix_path, data_type + '.csv')
    output_path = os.path.join(prefix_path, 'clean_' + data_type +'.csv')

    df = pd.read_csv(input_path)
    out_df = df.dropna()

    out_df.to_csv(output_path, index=False)


if __name__ == '__main__':
    '''
    data dependencies: `train.csv` and `test.csv`
    data outputs: `clean_train.csv` and `clean_test.csv`
    '''
    clean(s.RESOURCES_PATH)
    clean(s.RESOURCES_PATH, False)
