import datetime
import math
import os

class InsertQueries:

    def __init__(self):

        self.desc_array = [
            "small_str_1", # 10 characters
            "medium_str_1" * 5, # 50 characters
            "long_str_1" * 10, # 100 characters
            "longer_str_1" * 50, # 500 characters
            "even_longer_str_1" * 100, # 1000 characters
            "very_long_str_1" * 500, # 5000 characters
        ]
        self.types = ["Type A", "Type B", "Type C", "Type D", "Type E"]  
        self.queries = []

    def insert_customer(self, num_rows):

        for i in range(num_rows):
            # Generate a random integer ID
            id = i
            
            # Generate a random name string of length 10

            char = 'A'
            new_char = chr(ord(char) + i%26) 
            name = new_char + (str)(math.floor(i/26))
            
            # SQL statement to insert a row into the 'Customer' table
            self.queries.append(f"INSERT INTO Customer (ID, Name) VALUES ({id}, {name});")
        
    def insert_order(self, num_rows, num_rows_customer):

        my_datetime = datetime.datetime(2023, 1, 1, 0, 0, 0)
            

        # Generate and insert the rows into the database
        for i in range(num_rows):
            # Generate random values for the row
            id = i + 1
            cust_id =  i % num_rows_customer
            price = 100+i
            type = self.types[i%5]
            description = self.desc_array[i%6]
            my_datetime += datetime.timedelta(seconds=1)
            # Define the SQL query to insert the row into the database
            self.queries.append(f"INSERT INTO Orders (ID, cust_id, price, type, time, description) VALUES ({id}, {cust_id}, {price}, {type}, {description}, {my_datetime});")
    
    def generate_queries_file(self, file_name):
    
        # Define the file path
        file_path = os.path.join(os.getcwd(), file_name)

        # Open the file in write mode
        with open(file_path, "w") as f:
            # Write each query to the file with a semicolon and newline
            for query in self.queries:
                f.write(query + "\n")
                f.write(";\n")

def main():
    iq = InsertQueries()
    iq.insert_customer(1000)
    iq.insert_order(1000, 1000)
    iq.generate_queries_file("insert_queries.sql")

if __name__ == "__main__":
    main()


