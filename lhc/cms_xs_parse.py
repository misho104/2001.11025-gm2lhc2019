#!env python3

import ctypes
import pathlib
import ROOT
import sys
import coloredlogs
import logging
logger = logging.getLogger(__name__)

CODES = {
    "cms-slep-0.5": ("cms1709/CMS-SUS-16-039_Figure_014.root", "obs_xs"),
    "cms-slep-0.05": ("cms1709/CMS-SUS-16-039_Figure_015-a.root", "obs_xs"),
    "cms-slep-0.95": ("cms1709/CMS-SUS-16-039_Figure_015-b.root", "obs_xs"),
}

directory = pathlib.Path(__file__).parent


def main(code, x, y):
    return get_hist(code).Interpolate(x, y)


def main_show_all(code):
    hist = get_hist(code)
    if hist.ClassName() in ["TH2F", "TH2D"]:
        (ix, iy, iz) = [ctypes.c_int(-1) for p in range(3)]
        for i in range(0, hist.fN):
            hist.GetBinXYZ(i, ix, iy, iz)
            x = hist.GetXaxis().GetBinCenter(ix.value)  # assuming "center"...
            y = hist.GetYaxis().GetBinCenter(iy.value)
            print(f"{x}\t{y}\t{hist.GetBinContent(i)}")


def list_primitives(f):
    results = []
    for key in f.GetListOfKeys():
        obj = f.Get(key.GetName())
        results.append(repr(obj))
        if isinstance(obj, ROOT.TVirtualPad):
            for primitive in obj.GetListOfPrimitives():
                results.append("  " + repr(primitive))
    return results


def get_hist(code):
    (pathname, obj_name) = CODES.get(code, (None, None))
    if pathname is None:
        logger.critical("Invalid code: %s", code)
        exit(1)

    path = directory / pathname
    f = ROOT.TFile(str(path))

    for key in f.GetListOfKeys():
        obj = f.Get(key.GetName())
        try:
            primitive = obj.GetPrimitive(obj_name)
            if primitive:
                return primitive
        except Exception:
            pass
    logger.critical(
        f"Object {obj_name} not found")
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
    if len(sys.argv) == 3 and sys.argv[2] == "all":
        (script, code, dummy) = sys.argv
        main_show_all(code) 
        exit(0)

    logger.critical(f"Usage: {sys.argv[0]} file_code x y")
    logger.critical(f"       {sys.argv[0]} file_code all")
    exit(1)
