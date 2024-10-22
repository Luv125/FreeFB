#!/bin/bash

# Function to generate random strings
generate_random_string() {
    local length="$1"
    tr -dc 'a-zA-Z0-9' < /dev/urandom | head -c "$length"
}

# Function to create a new account
create_account() {
    local email="$1"
    local password="$2"
    local api_key="$3"

    # Firebase API endpoint
    local api_url="https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=${api_key}"

    # Create the JSON payload
    json_payload=$(jq -n --arg email "$email" --arg password "$password" '{email: $email, password: $password, returnSecureToken: true}')

    # Make the API request
    response=$(curl -s -X POST -H "Content-Type: application/json" -d "$json_payload" "$api_url")

    # Get the current timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Check if the account creation was successful
    if echo "$response" | jq -e '.idToken' > /dev/null; then
        echo -e "\033[32m[$timestamp] Account created: $email with password: $password\033[0m"  # Green color
        echo "[$timestamp] Account created: $email with password: $password" >> account_creation.log
    else
        echo -e "\033[31m[$timestamp] Failed to create account: $email - $(echo "$response" | jq -r '.error.message')\033[0m"  # Red color
        echo -e "\033[31m[$timestamp] Retrying in 5 seconds...\033[0m"  # Red color for retry message
        sleep 5  # Wait for 5 seconds before next attempt
    fi
}

# Clear the terminal window
clear

# ASCII Art Logo
echo -e "\033[1;36m"
cat << "EOF"
███████╗██████╗░███████╗███████╗███████╗██████╗░
██╔════╝██╔══██╗██╔════╝██╔════╝██╔════╝██╔══██╗
█████╗░░██████╔╝█████╗░░█████╗░░█████╗░░██████╦╝
██╔══╝░░██╔══██╗██╔══╝░░██╔══╝░░██╔══╝░░██╔══██╗
██║░░░░░██║░░██║███████╗███████╗██║░░░░░██████╦╝
╚═╝░░░░░╚═╝░░╚═╝╚══════╝╚══════╝╚═╝░░░░░╚═════╝░
EOF
echo -e "\033[0m"

# Main script execution
echo "Welcome to FreeFB!"

# Prompt user for API key
read -p "Please enter your Firebase API key: " api_key

# Check if API key is provided
if [[ -z "$api_key" ]]; then
    echo -e "\033[31mAPI key is required. Exiting.\033[0m"  # Red color
    exit 1
fi

# Prompt user for the number of accounts to create
read -p "Enter the number of accounts to create: " num_accounts

# Create or clear the log file
echo "Log file created: account_creation.log"
> account_creation.log

# Loop to create specified number of accounts
for ((i=1; i<=num_accounts; i++)); do
    random_email="$(generate_random_string 8)@gmail.com"
    random_password="$(generate_random_string 8)$(tr -dc '0-9' < /dev/urandom | head -c 1)"
    create_account "$random_email" "$random_password" "$api_key"
done

echo -e "\033[1;34mAccount creation process completed. Check account_creation.log for details.\033[0m"  # Blue color
