import yaml
import logging

logger = logging.getLogger()
logging.basicConfig(level=logging.INFO)


def load_yaml(file):
    with open(file, "r") as fp:
        return yaml.load(fp, Loader=yaml.Loader)


def run_main():
    logger.info("Hello World")


if __name__ == "__main__":
    run_main()
