import logging
import os

def setup_logs(save_dir, run_name):
    # initialize logger
    logger = logging.getLogger("anti-spoofing")
    logger.setLevel(logging.INFO)

    # create the logging file handler
    log_file = os.path.join(save_dir, run_name + ".log")
    if not os.path.exists(save_dir):
        os.makedirs(save_dir)
    fh = logging.FileHandler(log_file)

    # create the logging console handler
    ch = logging.StreamHandler()

    # format
    formatter = logging.Formatter("%(asctime)s - %(message)s")
    fh.setFormatter(formatter)

    # add handlers to logger object
    logger.addHandler(fh)
    logger.addHandler(ch)

    return logger
