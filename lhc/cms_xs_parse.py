#!env python3

import ctypes
import logging
import pathlib
import sys

import coloredlogs

import ROOT

logger = logging.getLogger(__name__)

CODES = {
    "cms-NC-3L-0.5": ("cms1709/CMS-SUS-16-039_Figure_014.root", "obs_xs"),
    "cms-NC-3L-0.05": ("cms1709/CMS-SUS-16-039_Figure_015-a.root", "obs_xs"),
    "cms-NC-3L-0.95": ("cms1709/CMS-SUS-16-039_Figure_015-b.root", "obs_xs"),
    "cms-NC-3L-0.05-2Lss": ("cms1709/CMS-SUS-16-039_Figure-aux_001.root", "obs_xs"),
    "cms-NC-3L-0.95-2Lss": ("cms1709/CMS-SUS-16-039_Figure-aux_003.root", "obs_xs"),
    "cms-NC-3L-0.05-3L": ("cms1709/CMS-SUS-16-039_Figure-aux_002.root", "obs_xs"),
    "cms-NC-3L-0.95-3L": ("cms1709/CMS-SUS-16-039_Figure-aux_004.root", "obs_xs"),
    "cms-NC-LLT-0.05": ("cms1709/CMS-SUS-16-039_Figure_016-a.root", "obs_xs"),
    "cms-NC-LLT-0.5": ("cms1709/CMS-SUS-16-039_Figure_016-c.root", "obs_xs"),
    "cms-NC-LLT-0.95": ("cms1709/CMS-SUS-16-039_Figure_016-b.root", "obs_xs"),
    "cms-NC-LLT-0.05-3L": ("cms1709/CMS-SUS-16-039_Figure-aux_007.root", "obs_xs"),
    "cms-NC-LLT-0.5-3L": ("cms1709/CMS-SUS-16-039_Figure-aux_005.root", "obs_xs"),
    "cms-NC-LLT-0.95-3L": ("cms1709/CMS-SUS-16-039_Figure-aux_009.root", "obs_xs"),
    "cms-NC-LLT-0.05-2LT": ("cms1709/CMS-SUS-16-039_Figure-aux_008.root", "obs_xs"),
    "cms-NC-LLT-0.5-2LT": ("cms1709/CMS-SUS-16-039_Figure-aux_006.root", "obs_xs"),
    "cms-NC-LLT-0.95-2LT": ("cms1709/CMS-SUS-16-039_Figure-aux_010.root", "obs_xs"),
    "cms-NC-3T-0.5": ("cms1807/CMS-SUS-17-003_Figure_014.root", "hXsec_exp_corr"),
    "5": ("cms1807/CMS-SUS-17-003_Figure_014.root", "hXsec_exp_corr"),
    "6": ("cms1807/CMS-SUS-17-003_Figure_014.root", "hsig_exp_corr"),
    "7": ("cms1807/CMS-SUS-17-003_Figure_014.root", "hsig_obs_corr"),
    "cms-CC-2T-0.5": ("cms1807/CMS-SUS-17-003_Figure_015.root", "glim"),
    "cms-NC-WZ-1709": ("cms1709/CMS-SUS-16-039_Figure_018-a.root", "obs_xs"),
    "cms-NC-WH-1709": ("cms1709/CMS-SUS-16-039_Figure_018-b.root", "obs_xs0"),
    "cms-NC-WZ": ("cms1801/CMS-SUS-17-004_Figure_008-a.root", "obs_xs"),
    "cms-NC-WH": ("cms1801/CMS-SUS-17-004_Figure_008-b.root", "obs_xs"),
}

directory = pathlib.Path(__file__).parent


def main(code, x, y):
    return get_hist(code).Interpolate(x, y)


def main_show_all(code):
    file, hist = get_hist(code)
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

    try:
        obj = f.Get(obj_name)
        if obj:
            return (f, obj)
    except Exception:
        pass

    for key in f.GetListOfKeys():
        obj = f.Get(key.GetName())
        try:
            primitive = obj.GetPrimitive(obj_name)
            if primitive:
                return (f, primitive)
        except Exception:
            pass
    logger.critical(f"Object {obj_name} not found")
    logger.info("Following objects and primitive objects are found.")
    for key in f.GetListOfKeys():
        logger.info(key)
    for line in list_primitives(f):
        logger.info(line)


if __name__ == "__main__":
    coloredlogs.install(logger=logging.getLogger(), fmt="%(levelname)8s %(message)s")

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
