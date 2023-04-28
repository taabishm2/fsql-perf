import csv
from datetime import datetime
import pytz

def read_and_convert_csv(file_path):
    with open(file_path, 'r') as file:
        reader = csv.reader(file)
        for row in reader:
            if len(row) == 4:
                first_col, second_col, epoch1, epoch2 = row
                timestamp1 = epoch_to_cdt(float(epoch1))
                timestamp2 = epoch_to_cdt(float(epoch2))
                print(f"{first_col}, {second_col}, {timestamp1}, {timestamp2}")

def epoch_to_cdt(epoch_timestamp):
    utc_timezone = pytz.timezone("UTC")
    cdt_timezone = pytz.timezone("America/Chicago")
    utc_dt = datetime.utcfromtimestamp(epoch_timestamp).replace(tzinfo=utc_timezone)
    cdt_dt = utc_dt.astimezone(cdt_timezone)
    return cdt_dt.strftime('%Y-%m-%d %H:%M:%S')

if __name__ == '__main__':
    file_path = 'FS_engine_timestamp.csv'
    read_and_convert_csv(file_path)
