from topia.parser import parse_args
from topia.utils.io import log
# from topia.utils.version import print_version


def main() -> None:
    try:
        parser, args = parse_args()
        # if args.version:
        #     print_version()
        if "cls" in args:
            args.cls(args).run()
        else:
            parser.print_help()
    except KeyboardInterrupt:
        log("Exiting...")
