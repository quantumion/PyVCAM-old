#!/usr/bin/env python3
"""
__main__.py

Implement ARTIQ Network Device Support Package (NDSP) to support Teledyne PrimeBSI camera integration into ARTIQ experiment.

Kevin Chen
2023-02-24
University of Waterloo
QuantumIon
"""

from sipyco.pc_rpc import simple_server_loop
from sipyco import common_args
import argparse
import logging
import sys
from pyvcam.driver import PyVCAM
from pyvcam.camera import Camera
from pyvcam import pvc


logger = logging.getLogger(__name__)


def has_list_arg(*arguments: tuple[str]):
    """
    Check whether one or more arguments have been passed to the controller program.

    Args:
        arguments (tuple[str]): collection of arguments passed to the controller program

    Returns:
        bool: True if at least one of the given arguments has been passed to the program, otherwise False
    """
    logger.info
    for argument in arguments:
        if argument in sys.argv:
            return True
    return False


def get_argparser():
    """Format command line interface for the NDSP"""
    parser = argparse.ArgumentParser(description="""PyVCAM controller. Use this controller to drive the Teledyne PrimeBSI camera.
                                     See documentation at https://github.com/Photometrics/PyVCAM""")
    common_args.simple_network_args(parser, 3249)
    common_args.verbosity_args(parser)
    parser.add_argument("-d", "--device", action="store", required=not has_list_arg("-l", "--list"), help="Camera device name")
    parser.add_argument("-l", "--list", action="store_true", required=False, help="List available devices on the host")
    return parser

def main():
    args = get_argparser().parse_args()
    common_args.init_logger_from_args(args)

    # identify camera device(s)
    if args.list:
        logger.info("Listing available camera device names")
        try:
            pvc.init_pvcam()
            print(Camera.get_available_camera_names())
        finally:
            pvc.uninit_pvcam()
        sys.exit(0)

    # initiate controller
    try:
        logger.info("Initiating PVCAM")
        pvc.init_pvcam()
        try:
            logger.info("Opening PyVCAM")
            camera = PyVCAM(Camera.select_camera(args.device))
            camera.open()

            logger.info("Launching controller")
            simple_server_loop({"pyvcam": camera}, common_args.bind_address_from_args(args), args.port)
        finally:
            logger.info("Closing PyVCAM")
            camera.close()

    finally:
        logger.info("Cleaning up PVCAM")
        pvc.uninit_pvcam()

if __name__ == "__main__":
    main()
