import argparse
from math import floor
from insert_queries import InsertQueries
from select_queries import SelectQueries
from delete_queries import DeleteQueries

def generate_create_queries(num_create):
    iq = InsertQueries()
    num_customers = floor(0.3 * num_create)
    num_orders = num_create - num_customers
    iq.insert_customer(num_customers)
    iq.insert_order(num_orders, num_customers)
    iq.generate_queries_file("insert_queries.sql")    

def generate_read_queries(num_read):
    sq = SelectQueries()
    sq.generate_queries_file("select_queries.sql", num_read)

def generate_update_queries(num_update):
    pass

def generate_delete_queries(num_delete):
    dq = DeleteQueries()
    dq.generate_queries_file("delete_queries.sql", num_delete)

def main():
    # Parsing command line arguments
    parser = argparse.ArgumentParser(description='Crud percentages')
    parser.add_argument('--queries', dest='queries', help='queries help')
    parser.add_argument('--C', dest='C', help='C help')
    parser.add_argument('--R', dest='R', help='C help')
    parser.add_argument('--U', dest='U', help='C help')
    parser.add_argument('--D', dest='D', help='C help')
    args = parser.parse_args()

    queries = int(args.queries)
    C = int(args.C)
    U = int(args.U)
    D = int(args.D)

    # Number of CRUD queries based on percentages
    num_create = floor(C * 0.01 * queries)
    num_update = floor(U * 0.01 * queries)
    num_delete = floor(D * 0.01 * queries)
    num_read = queries - (num_create + num_update + num_delete)

    # Generating CRUD data in a sql file
    generate_create_queries(num_create)
    generate_read_queries(num_read)
    generate_update_queries(num_update)
    generate_delete_queries(num_delete)    

    # print(f"queries: {args.queries}")
    # print(f"C: {args.C}")
    # print(f"R: {args.R}")
    # print(f"U: {args.U}")
    # print(f"D: {args.D}")


if __name__ == "__main__":
    main()
