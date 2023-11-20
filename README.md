# Properties_Data_Cleaning_SQL
The provided code performs data cleaning operations on a property dataset from the 'Portfolio..NashvilleHousing' table. Here's a summary of the steps:
Data Exploration: Initial exploration of the dataset by querying all columns from the 'NashvilleHousing' table.
Standardizing Date Format: Converting the 'SaleDate' column into standardized date formats (DATE and VARCHAR) for uniformity.
Handling Property Address: Ensuring consistency in property addresses by populating missing addresses based on identical ParcelIDs and breaking down the address into separate 'Address' and 'City' columns.
Handling Owner Address: Splitting the owner's address into separate 'Address', 'City', and 'State' columns for better analysis and readability.
Cleaning Categorical Data: Updating 'SoldAsVacant' column values from 'Y' and 'N' to 'Yes' and 'No' respectively for better interpretation.
Removing Duplicates: Removing duplicate rows using the ROW_NUMBER() function partitioned by several columns.
Creating a Cleaned View: Creating a 'Cleaned_Table' view containing the cleaned and formatted data with renamed columns for improved clarity and ordering the results by sale price.
Throughout these operations, the focus remains on enhancing the dataset's consistency, readability, and usability for further analysis by standardizing formats, handling missing data, and improving categorical values.
