#!env python3

import ROOT
import sys
import coloredlogs
import logging
logger = logging.getLogger(__name__)

CODES = {
    "cms-slep-0.5": ("CMS-SUS-16-039_Figure_014.root", "obs_xs"),
    "cms-slep-0.05": ("CMS-SUS-16-039_Figure_015-a.root", "obs_xs"),
    "cms-slep-0.95": ("CMS-SUS-16-039_Figure_015-b.root", "obs_xs"),
}


def main(code, x, y):
    (path, obj_name) = CODES.get(code, (None, None))
    if path is None:
        logger.critical("Invalid code: %s", code)
        exit(1)

    f = ROOT.TFile(path)
    return get_hist(f, obj_name).Interpolate(x, y)


def list_primitives(f):
    results = []
    for key in f.GetListOfKeys():
        obj = f.Get(key.GetName())
        results.append(repr(obj))
        if isinstance(obj, ROOT.TVirtualPad):
            for primitive in obj.GetListOfPrimitives():
                results.append("  " + repr(primitive))
    return results


def get_hist(f, name):
    for key in f.GetListOfKeys():
        obj = f.Get(key.GetName())
        try:
            primitive = obj.GetPrimitive(name)
            if primitive:
                return primitive
        except:
            pass
    logger.critical(
        f"Object {name} not found")
    logger.info("Following objects and primitive objects are found.")
    for line in list_primitives(f):
        logger.info(line)


if __name__ == "__main__":
    coloredlogs.install(logger=logging.getLogger(),
                        fmt="%(levelname)8s %(message)s")

    if len(sys.argv) == 4:
        (script, code, x, y) = sys.argv
        value = main(code, float(x), float(y))
        print(value)
        exit(0)

    logger.critical(f"Usage: {sys.argv[0]} file_code x y")
    exit(1)
