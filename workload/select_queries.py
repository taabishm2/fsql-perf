import os

class SelectQueries:

    def __init__(self):

        # Define the SELECT queries
        self.queries = [
            # Get all records from the Customer table
            "SELECT * FROM Customer;",
            
            # Get all records from the Orders table
            "SELECT * FROM Orders;",
            
            # Get all records from the Orders table where cust_id is 1, ordered by time and limited to 10 records
            "SELECT * FROM Orders WHERE cust_id = 1 ORDER BY time DESC LIMIT 10;",
            
            # Get all records from the Orders table where time is between two dates, ordered by time
            "SELECT * FROM Orders WHERE time BETWEEN '2023-01-01 00:00:00' AND '2023-01-01 00:05:26' ORDER BY time;",
            
            # Get the average price of all orders
            "SELECT AVG(price) FROM Orders;",
            
            # Get the maximum price of all orders
            "SELECT MAX(price) FROM Orders;",
            
            # Get the minimum price of all orders
            "SELECT MIN(price) FROM Orders;",
            
            # Get the number of orders for each customer
            "SELECT cust_id, COUNT(*) as num_orders FROM Orders GROUP BY cust_id;",
            
            # Get the total price of orders for each customer
            "SELECT cust_id, SUM(price) as total_price FROM Orders GROUP BY cust_id;",
            
            # Get the top 10 order types by number of orders
            "SELECT type, COUNT(*) as num_orders FROM Orders GROUP BY type ORDER BY num_orders DESC LIMIT 10;",
            
            # Get the customers and order types with a total price greater than 1000, sorted by total price in descending order
            "SELECT cust_id, type, SUM(price) as total_price FROM Orders GROUP BY cust_id, type HAVING total_price > 1000 ORDER BY total_price DESC;"

            # Get the name of each customer along with the total number of orders they have made
            "SELECT c.Name, COUNT(o.ID) as num_orders FROM Customer c JOIN Orders o ON c.ID = o.cust_id GROUP BY c.ID;",
            
            # Get the name of each customer along with the total price of all their orders
            "SELECT c.Name, SUM(o.price) as total_price FROM Customer c JOIN Orders o ON c.ID = o.cust_id GROUP BY c.ID;",
            
            # Get the type of each order along with the name of the customer who made it
            "SELECT o.type, c.Name FROM Customer c JOIN Orders o ON c.ID = o.cust_id;",
            
            # Get the name of each customer along with the number of orders they have made and the total price of all their orders
            "SELECT c.Name, COUNT(o.ID) as num_orders, SUM(o.price) as total_price FROM Customer c JOIN Orders o ON c.ID = o.cust_id GROUP BY c.ID;"

            # Get the description of each order along with the type and price
            "SELECT type, price, description FROM Orders;",
            
            # Get the description of each order that contains the word 'ng_str'
            "SELECT type, price, description FROM Orders WHERE description LIKE '%ng_str%';",
            
            # Get the description of each order that was made by a customer with a name starting with 'even'
            "SELECT o.type, o.price, o.description FROM Customer c JOIN Orders o ON c.ID = o.cust_id WHERE c.Name LIKE 'even%';"
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
    sq = SelectQueries()
    sq.generate_queries_file("select_queries.sql", 20)

if __name__ == "__main__":
    main()