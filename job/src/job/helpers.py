import os
import time

import pandas as pd
import numpy as np
from sklearn.externals import joblib

import settings as s


def read_inputs(prefix_path, inputs_files):
    inputs = []

    for i in inputs_files:

        file_format = i.split('.')[-1]
        path = os.path.join(prefix_path, i)

        s.logging.info('Reading file: {file}'.format(file=path))

        if file_format == 'csv':
            inputs.append(pd.read_csv(path, **inputs_files[i]))

        elif file_format == 'pkl':
            inputs.append(joblib.load(path, **inputs_files[i]))

        elif file_format == 'txt':
            inputs.append(np.loadtxt(path, **inputs_files[i]))

        else:
            raise ValueError(
                'The format: {format} is not valid'.format(format=file_format))

    return inputs


def save_outputs(prefix_path, outputs, outputs_files, process):

    for i, o in enumerate(outputs_files):

        file_format = o.split('.')[-1]
        path = os.path.join(prefix_path, o)

        s.logging.info('Saving file: {file}'.format(file=path))

        if file_format == 'csv':
            outputs[i].to_csv(path, index=False, **outputs_files[o])

        elif file_format == 'pkl':
            joblib.dump(outputs[i], path, **outputs_files[o])

        elif file_format == 'txt':
            np.savetxt(path, outputs[i], **outputs_files[o])

        else:
            raise ValueError(
                'The format {format} is not valid'.format(format=file_format))

        saved_time = time.ctime(os.path.getmtime(path))
        metadata_info = '{file},{process},{time}\n'.format(file=o,
                                                           process=process,
                                                           time=saved_time)

        with open(s.METADATA_PATH, "w") as fp:
            fp.write(metadata_info)
