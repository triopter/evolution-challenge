import json

from django.core.management.base import BaseCommand, CommandError

from football.importer import ScoreImporter


class Command(BaseCommand):
    help = (
        "Import scores in format provided at "
        "https://github.com/openfootball/football.json/blob/f03f5cf87dad91d359ead88e4ebfef4529944067/2016-17/en.1.json"
    )

    def add_arguments(self, parser):
        parser.add_argument("file_path", nargs="+", type=str, action="store")

    def handle(self, *args, **options):
        for path in options["file_path"]:
            print(f"Importing from {path}")
            try:
                with open(path, "r") as fp:
                    raw_data = json.load(fp)
            except FileNotFoundError:
                raise CommandError(f"Invalid file path {path}")

            self.import_data(raw_data)

    def import_data(self, raw_data):
        ScoreImporter().import_data(raw_data)
