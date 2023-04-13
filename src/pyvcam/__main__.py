#!/usr/bin/env python3
"""
__main__.py

Implement ARTIQ Network Device Support Package (NDSP) to support Teledyne Prime BSI camera integration
into ARTIQ experiment.

Kevin Chen
2023-02-24
University of Waterloo
QuantumIon
"""

from sipyco.pc_rpc import simple_server_loop
from sipyco import common_args
import argparse
import logging, logging.config
from pyvcam.driver import PyVCAM


logger = logging.getLogger('pyvcam')
logger.setLevel(logging.DEBUG)
logger.propagate = False  # prevents logging output flooding console

# create file handler which logs even debug messages
fh = logging.FileHandler('logfile.log')
fh.setLevel(logging.DEBUG)

# create console handler with a higher log level
ch = logging.StreamHandler()
ch.setLevel(logging.DEBUG)

# create formatter and add it to the handlers
formatter = logging.Formatter('%(asctime)s - %(name)s - %(levelname)s - %(message)s')
fh.setFormatter(formatter)
ch.setFormatter(formatter)

# add the handlers to the logger
logger.addHandler(fh)
logger.addHandler(ch)


def get_argparser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="""PyVCAM controller. Use this controller to drive the
                            Teledyne Prime BSI camera. See documentation at https://github.com/quantumion/PyVCAM""")
    common_args.simple_network_args(parser, 3249)
    common_args.verbosity_args(parser)
    return parser


def main() -> None:
    args = get_argparser().parse_args()
    common_args.init_logger_from_args(args)
    logger.info('Creating an instance of PyVCAM')
    camera = PyVCAM()
    logger.info('PyVCAM created. Opening camera...')

    try:
        camera.open()
        logger.info('Camera open.')
        simple_server_loop({"pyvcam": camera}, common_args.bind_address_from_args(args), args.port)
    except RuntimeError:
        logger.exception('Connection refused. Check camera status')
    finally:
        camera.close()
        logger.info('Camera closed.')
        del camera


if __name__ == "__main__":
    main()
