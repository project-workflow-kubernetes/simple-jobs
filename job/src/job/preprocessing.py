import os

import pandas as pd

import settings as s


INPUT_PREFIX = s.RESOURCES_PATH
OUTPUT_PREFIX = s.RESOURCES_PATH
INPUTS = ['train.csv', 'test.csv']
OUTPUTS = ['clean_train.csv', 'clean_test.csv']


def clean(df):
    out_df = df.dropna()

    return out_df



if __name__ == '__main__':
    '''
    data dependencies: `train.csv` and `test.csv`
    data outputs: `clean_train.csv` and `clean_test.csv`
    '''

    input_path = os.path.join(INPUT_PREFIX, INPUTS[0])
    output_path = os.path.join(OUTPUT_PREFIX, OUTPUTS[0])
    out = clean(pd.read_csv(input_path))
    out.to_csv(output_path, index=False)

    input_path = os.path.join(INPUT_PREFIX, INPUTS[1])
    output_path = os.path.join(OUTPUT_PREFIX, OUTPUTS[1])
    out = clean(pd.read_csv(input_path))
    out.to_csv(output_path, index=False)
