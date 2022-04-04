import mysql.connector

# Change these values to connect to your Character database
acore_db = mysql.connector.connect(
    host="localhost",
    user="acore",
    password="acore",
    database="acore_characters"
)

# Change this number to your account ID, or leave as -1 to be prompted for character name
account_id = -1

acore_cursor = acore_db.cursor()

if account_id == -1:
    input_data = input("Please input your account_id or character name:")
    try:
        account_id = int(input_data)
    except ValueError:
        acore_cursor.execute("SELECT account FROM characters WHERE name = \"{}\"".format(
            input_data
        ))
        results = acore_cursor.fetchall()
        if len(results) != 1:
            print("Unable to find character with name {}".format(
                input_data
            ))
            exit(0)
        else:
            account_id = results[0][0]

acore_cursor.execute("SELECT item_template_id FROM custom_unlocked_appearances WHERE account_id = {}".format(
    account_id
))
results = acore_cursor.fetchall()
if len(results) == 0:
    print("No transmog results found! No syncing necessary.")
    exit(0)
output_file = open("transmogTip.lua", 'w', encoding='utf-8')
output_file.write("\nTransmogTipList = {\n")
counter = 0
for item in results:
    counter += 1
    output_file.write("\t{}, -- [{}]\n".format(
        item[0],
        counter
    ))
output_file.write("}")
output_file.close()

print("SUCCESS! Please place transmogTip.lua in <WoW Dir>/WTF/Account/<AccountName>/<CharName>/SavedVariables")

