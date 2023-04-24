import os

class DeleteQueries:
    def __init__(self):
        
        # Define the DELETE queries
        self.queries = [
            # Delete all orders with a price less than $100
            "DELETE FROM Orders WHERE price < 100;",
            
            # Delete all orders that were made before January 1st, 2023 00:05:26
            "DELETE FROM Orders WHERE time < '2023-01-01 00:05:26';",
            
            # Delete all customers with an ID less than 10
            "DELETE FROM Customer WHERE ID < 10;",
            
            # Delete all orders made by customer with ID 5
            "DELETE FROM Orders WHERE cust_id = 5;",
            
            # Delete all orders with a description containing the word "ng_str"
            "DELETE FROM Orders WHERE description LIKE '%ng_str%';",
            
            # Delete all orders with a type of "standard"
            "DELETE FROM Orders WHERE type = 'standard';",
            
            # Delete all orders with a price less than $1000
            "DELETE FROM Orders WHERE price < 1000;",
            
            # Delete all customers whose names start with "X"
            "DELETE FROM Customer WHERE Name LIKE 'G%';",
            
            # Delete all orders made after January 1st, 2023 00:25:26
            "DELETE FROM Orders WHERE time > '2023-01-01 00:25:26';",
            
            # Delete all orders with a description less than 500 characters
            "DELETE FROM Orders WHERE LENGTH(description) < 500;",
            
            # Delete all orders with a type of "special" and a price less than $500
            "DELETE FROM Orders WHERE type = 'Type C' AND price < 500;",
            
            # Delete all customers who have not made any orders
            "DELETE FROM Customer WHERE ID NOT IN (SELECT DISTINCT cust_id FROM Orders);",
            
            # Delete all orders made by customers whose names start with "A"
            "DELETE FROM Orders WHERE cust_id IN (SELECT Name FROM Customer WHERE Name LIKE 'A%');"
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
                #f.write(";\n")

def main():
    dq = DeleteQueries()
    dq.generate_queries_file("delete_queries.sql", 20)

if __name__ == "__main__":
    main()
