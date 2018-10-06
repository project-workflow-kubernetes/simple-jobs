import os

RESOURCES_PATH = os.path.join(os.path.abspath(os.path.join(__file__, '../../..')), 'resources')

INPUT_PREFIX = os.environ['DATA_INPUT_PATH'] if os.environ['DATA_INPUT_PATH'] else RESOURCES_PATH
OUTPUT_PREFIX = os.environ['DATA_OUTPUT_PATH'] if os.environ['DATA_OUTPUT_PATH'] else RESOURCES_PATH
