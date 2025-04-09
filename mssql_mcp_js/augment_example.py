from augment_config import execute_query, execute_command

def get_data_for_augment(query):
    """Fetch data from database for Augment to process"""
    try:
        results = execute_query(query)
        return results
    except Exception as e:
        print(f"Error fetching data: {e}")
        return None

def update_data_from_augment(command, params):
    """Update database based on Augment's output"""
    try:
        execute_command(command, params)
        return True
    except Exception as e:
        print(f"Error updating data: {e}")
        return False

# Example usage:
if __name__ == "__main__":
    # Example query
    data = get_data_for_augment("SELECT TOP 10 * FROM your_table")
    
    # Example update
    success = update_data_from_augment(
        "UPDATE your_table SET column1 = ? WHERE id = ?",
        ("new_value", 1)
    )