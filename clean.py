import os
import csv

SYSBENCH_DIR = "logs"
OUTPUT_DIR = "clean-logs"

def get_sysbench_path():
    dirs = [d for d in os.listdir(SYSBENCH_DIR) if os.path.isdir(os.path.join(SYSBENCH_DIR, d))]
    if len(dirs) == 0: raise Exception(f"No sysbench logs in path:{SYSBENCH_DIR}")
    
    sysbench_log_path = SYSBENCH_DIR + "/" + dirs[0]
    if len(dirs) > 1: 
        print(f"Multiple logs exist in path:{SYSBENCH_DIR}")
        for i, v in enumerate(dirs): print(f"{i}: {v}")
        sysbench_log_path = SYSBENCH_DIR + "/" + dirs[int(input("Enter index of log to use: "))]
        
    return sysbench_log_path


def get_query_value(string, query):
    for line in string.split("\n"):
        if query in line:
            return line.split(":")[1].strip()
    return None

   
def get_sysbench_csv():     
    sysbench_path = get_sysbench_path()
    log_files = [f for f in os.listdir(sysbench_path) if f.endswith('.log')]

    sysbench_out_csv = open(f"{OUTPUT_DIR}/sysbench.csv", "w")
    csv_writer = csv.writer(sysbench_out_csv)
    csv_writer.writerow([
        "Filesystem", "DB Engine", 
        "Read Queries", "Write Queries", "Other Queries", "Total Queries",
        "Transactions/sec", "Queries/sec",
        "Min Latency (ms)", "Avg Latency (ms)", "Max Latency (ms)", "95th percentile (ms)"
        ])
    
    for log_file in log_files:
        file_sys, db_engine = log_file[:-4].split("-")
        log_content = open(f"{sysbench_path}/{log_file}", "r").read()
        
        read_queries = get_query_value(log_content, "read:")
        write_queries = get_query_value(log_content, "write:")
        other_queries = get_query_value(log_content, "other:")
        total_queries = get_query_value(log_content, "total:")
        
        tps_queries = get_query_value(log_content, "transactions:")
        qps_queries = get_query_value(log_content, "queries:")
        tps = tps_queries[tps_queries.find("("):][1:].split(" ")[0]
        qps = qps_queries[tps_queries.find("("):][1:].split(" ")[0]
        
        min_lat_queries = get_query_value(log_content, "min:")
        avg_lat_queries = get_query_value(log_content, "avg:")
        max_lat_queries = get_query_value(log_content, "max:")
        nfp_lat_queries = get_query_value(log_content, "95th percentile:")
        
        csv_writer.writerow([
            file_sys, db_engine, 
            read_queries, write_queries, other_queries, total_queries, 
            tps, qps, 
            min_lat_queries, avg_lat_queries, max_lat_queries, nfp_lat_queries])
        
    sysbench_out_csv.close()
    
get_sysbench_csv()
print("Sysbench CSV generated")