import os
import sys
import logging

RESOURCES_PATH = os.path.join(os.path.abspath(os.path.join(__file__, '../../..')), 'resources')
INPUT_PREFIX = os.environ['DATA_INPUT_PATH'] if os.environ.get('DATA_INPUT_PATH', None) else RESOURCES_PATH
OUTPUT_PREFIX = os.environ['DATA_OUTPUT_PATH'] if os.environ.get('DATA_OUTPUT_PATH', None) else RESOURCES_PATH
METADATA_PREFIX = os.environ['METADATA_OUTPUT_PATH'] if os.environ.get('METADATA_OUTPUT_PATH', None) else RESOURCES_PATH
METADATA_PATH = os.path.join(METADATA_PREFIX, 'metadata.txt')


root = logging.getLogger()
root.setLevel(logging.INFO)
ch = logging.StreamHandler(sys.stdout)
ch.setLevel(logging.INFO)
formatter = logging.Formatter('%(levelname)s - %(asctime)s - %(filename)s - %(message)s')
formatter.default_msec_format = '%s.%03d'
ch.setFormatter(formatter)
root.addHandler(ch)
