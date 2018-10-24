import os
import sys
import logging

RESOURCES_PATH = os.path.join(os.path.abspath(os.path.join(__file__, '../../..')), 'resources')
INPUT_PREFIX = os.environ['DATA_INPUT_PATH'] if os.environ.get('DATA_INPUT_PATH', None) else RESOURCES_PATH
OUTPUT_PREFIX = os.environ['DATA_OUTPUT_PATH'] if os.environ.get('DATA_OUTPUT_PATH', None) else RESOURCES_PATH
LOGS_PREFIX = os.environ['LOGS_OUTPUT_PATH'] if os.environ.get('LOGS_OUTPUT_PATH', None) else RESOURCES_PATH
METADATA_PREFIX = os.environ['METADATA_OUTPUT_PATH'] if os.environ.get('METADATA_OUTPUT_PATH', None) else RESOURCES_PATH
METADATA_PATH = os.path.join(METADATA_PREFIX, 'metadata.txt')


LOG_FORMAT = '%(levelname)s - %(filename)s - %(asctime)s - %(message)s'
logging.basicConfig(level=logging.INFO,
                    format=LOG_FORMAT,
                    datefmt='%a, %d %b %Y %H:%M:%S',
                    filename=os.path.join(LOGS_PREFIX, 'logs.log'))
logging.getLogger().addHandler(logging.StreamHandler(sys.stdout))
