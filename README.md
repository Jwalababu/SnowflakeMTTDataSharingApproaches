# SnowflakeMTTDataSharingApproaches
This has Snowflake SQL script(s) to setup few sample base-tables and create listings using 4 different approaches.
Please note that this script is provided as an example only and not part of Snowfalke offering(s).

Following the steps 1-3 for setting up necessary tables and populate them with sample data.
From there one can either follow one of the options or try all 4  options to understand how each of the features work.

Complete code for Setup, 4 options and cleanup is located in one SQL file named SnowflakeMTTDataSharingApproaches.SQL.
Alternatively, individual scripts are provided for Setup, 4 seperate sripts for 4 options and cleanup script. 
These are split for convinience if you are trying one of the approaches/options.

Is important to note and make necessary changes in values for Snowflake account <Idenfier>  and <Orgname>.<AccountName>
Account <Idenfier> which is used in most of record filtering funtions and queries.
<Orgname>.<AccountName> is used in creating listings to share with target/consumer accounts.
Values provided in this scripts are dummay values and do not work unless they are changed to valid values.

Scripts create client specific schema to hold objetcs, shares and Listings under option 3 (Dynamic Tables), 4 (Secure Materialized views).
These are named with a suffix <CLIENTX> in these scripts, make sure to update it with right values for you.

After trying different options, you can use clean-up section to removed databases, schemas and any other objects created in this excercise.
