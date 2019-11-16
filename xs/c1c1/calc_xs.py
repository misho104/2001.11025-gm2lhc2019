#!env python3
import logging
import pathlib

import click
import coloredlogs
import mg5helper
import subprocess

logger = logging.getLogger(__name__)

git_root = (
    subprocess.run(["git", "rev-parse", "--show-toplevel"], capture_output=True)
    .stdout.decode()
    .strip()
)
mg5bin = pathlib.Path(f"{git_root}/vendor/MG5_aMC/bin/MG5_aMC")
if not mg5bin.is_file():
    logger.critical("MG5 binary not found at %s", mg5)
    exit(1)
mg5 = mg5helper.MG5(mg5bin=mg5bin)


def calc_cross_section(name, param, run_card, processes, extra_code=None):
    cards = {
        "run": mg5helper.MG5Card(run_card, {"nev": 10000}),
        "param": mg5helper.MG5Card(param),
    }
    extra_code = extra_code if extra_code else []
    for process, process_name in processes:
        out = mg5helper.MG5Output(
            process, path=process_name, model="MSSM_SLHA2-full", extra_code=extra_code
        )
        out.mg5 = mg5
        out.output(force=False)
        launch = out.launch(cards, name=name)
        logger.info(f"{process_name}\t{name}\t{launch.xs}\t{launch.xserr}")


@click.group()
def calc():
    pass


@calc.command()
@click.argument('slha', type=click.Path())
def c1c1(slha):
    sq = "ul ul~ ur ur~ dl dl~ dr dr~ cl cl~ cr cr~ sl sl~ sr sr~ b1 b1~ b2 b2~ t1 t1~ t2 t2~"

    calc_cross_section(
        name=pathlib.Path(slha).stem,
        param=slha,
        run_card="../mg5_run_card.dat",
        processes=[
               (f"p p > x1+ x1- / {sq}", "c1c1"),
        ],
    )



if __name__ == "__main__":
    coloredlogs.install(logger=logging.getLogger(), fmt="%(levelname)8s %(message)s")
    calc()
