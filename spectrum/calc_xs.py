#!env python3
import click
import pathlib
from mg5helper import MG5, MG5Output, MG5Launch, MG5Card, ProcessType, CardDictType
import coloredlogs
import logging
logger = logging.getLogger(__name__)


processes = [
    (["p p > n2 x1pm"], "events/n2x1"),
]  # type: Sequence[Tuple[List[str], str]]

output_extra_code = [
    "define x1pm = x1+ x1-"
]  # type: Sequence[str]


@click.command()
@click.argument("slha_files", nargs=-1, type=click.Path(exists=True, dir_okay=False))
def calc_xs(slha_files):
    mg5 = MG5(mg5bin=pathlib.Path("../vendor/MG5_aMC/bin/MG5_aMC"))
    result = []  # type: List[str]
    for process, process_name in processes:
        for slha in slha_files:
            slha_path = pathlib.Path(slha)
            out = MG5Output(process, path=process_name, model="MSSM_SLHA2-full",
                            extra_code=output_extra_code)
            out.mg5 = mg5
            out.output(force=False)
            cards = {
                "run": MG5Card("mg5_run_card.dat", {"nev": 10000}),
                "param": MG5Card(slha_path),
            }
            launch = out.launch(cards, name=slha_path.stem)
            result.append(f"{slha}, {launch.xs}, {launch.xserr}")
            for line in result:
                logger.info(line)
    for line in result:
        print(line)


if __name__ == "__main__":
    coloredlogs.install(logger=logging.getLogger(),
                        fmt="%(levelname)8s %(message)s")
    calc_xs()
