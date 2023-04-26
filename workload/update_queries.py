import os

class UpdateQueries:

    def __init__(self):

        # Define the UPDATE queries
        self.queries = [
            # Update the price of all orders to $10
            "UPDATE Orders SET price = 10;",
            
            # Update the price of orders made by customer with ID=1 to $15
            "UPDATE Orders SET price = price * 1.1 WHERE cust_id > (SELECT AVG(ID) FROM Customer);",
            
            # Decrease the price of all orders made before a certain date by 5%
            "UPDATE Orders SET price = 20 WHERE time BETWEEN '2023-01-01 00:00:00' AND '2023-01-01 00:05:26';",
            
            # Update after joining customer_id and price
            "UPDATE Orders o JOIN Customer t ON o.cust_id=t.ID SET o.price=1.1*o.price;",
        
            
            # Update and then OrderBy using timestamp
            "UPDATE Orders SET price=25 WHERE time < '2023-04-22 00:00:00' ORDER BY time;",
            
            # Update based on description size
            "UPDATE Orders SET type='Type C' WHERE LENGTH(description) > 500;"
        ]
            
    def generate_queries_file(self, file_name, num_queries):
        
        # Define the file path
        file_path = os.path.join(os.getcwd(), file_name)

        queries = []
        n = len(self.queries)
        for i in range(num_queries):
            queries.append(self.queries[i%n])

        # Open the file in write mode
        with open(file_path, "w") as f:
            # Write each query to the file with a semicolon and newline
            for query in queries:
                f.write(query + "\n")
                f.write(";\n")


def main():
    uq = UpdateQueries()
    uq.generate_queries_file("update_queries.sql", 20)

if __name__ == "__main__":
    main()
