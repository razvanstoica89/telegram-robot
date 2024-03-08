#!/bin/sh

# Global variables
VERSION="0.0.1"

SCRIPT_NAME="${0}"
SCRIPT_PATH="${PWD}/"
ENV_FILE_PATH="${SCRIPT_PATH}.env"
MAXIMUM_RETRY_LIMIT="5"

# Define script dependency
DEPENDENCY_LIST="which printf cat shuf tr wc sed jq curl sha256sum"

# Loop through each dependency
for dependency in ${DEPENDENCY_LIST}; do
    # Check if the dependency is not installed
    if ! which "${dependency}" >/dev/null; then
        printf "Dependency %s is not installed.\n" "${dependency}"
        exit 1
    fi
done

# Validate the integrity of the words.txt file used for generating the secret passphrase
actual_sha256sum="$(sha256sum "${SCRIPT_PATH}words.txt" | cut -d' ' -f1)"
expected_sha256sum="c4e2082205376047f563863730627d578a89dc7fae6ddcf0f5dac490435141f5"

if [ "${actual_sha256sum}" != "${expected_sha256sum}" ]; then
    printf "ERROR: The words.txt file has been modified.\n"
    exit 1
fi

# Check if the .env file does not exist
if [ ! -e "${ENV_FILE_PATH}" ]; then
    printf "ERROR: The .env file does not exist. Please create it in %s location based on .env-example file.\n" "${ENV_FILE_PATH}"
    exit 1
fi

# Check if the .env file is empty
if [ ! -s "${ENV_FILE_PATH}" ]; then
    printf "The .env file form %s location is empty. Please populate it based on .env-example file." "${ENV_FILE_PATH}"
    exit 1
fi

# Source the .env file
. "${ENV_FILE_PATH}"

# Check if the environment variable is empty
if [ -z "${API_TOKEN}" ]; then
    cat <<EOF
ERROR: API_TOKEN is empty.

Provide an API_TOKEN following this steps:
1. Open BotFather (https://t.me/BotFather) in your Telegram App.
2. Type "/mybots" in the chat to list your bots.
3. Select your bot from the list.
4. Tap on the "API Token" option.
5. Copy the provided API Token.
6. Paste the API token into the .env file for the variable "API_TOKEN".
EOF
    exit 1
    fi

# Define usage function
usage() {
  cat <<EOF
Telegram Telegram Robot ${VERSION}
The Telegram Robot is a Telegram Bot designed to efficiently send notifications to a curated list of registered chats.

Usage: ${SCRIPT_NAME} [OPTIONS] [Arguments]

Example:
${SCRIPT_NAME} --msg-all "Hello audience"

Options:
  --register-chat                 Register a new chat ID
  --print-chats                   Print registered chats IDs
  --delete-chats                  Delete all registered chats IDs
  --msg-all <message>             Send a message to all registered chats
  --msg-id <chat_id> <message>    Send a message to the specified chat id
  --help                          Show this help message
EOF
}

# Function to prompt the user for confirmation
prompt_confirmation() {
    printf "Continue? [Y/n]: "
    read -r response

    case "${response}" in
        [yY]|[yY][eE][sS]) 
            ;;
        [nN]|[nN][oO])
            printf "Cancelled by user.\n"
            exit 1
            ;;
        *)
            printf "Invalid response. Please enter Y/y or N/n."
            prompt_confirmation
            ;;
    esac
}

generate_passphrase() {
    # Usage: generate_passphrase <number_of_words>
    # Example: generate_passphrase 3
    # Options: number_of_words default value 7

    number_of_words="${1:-7}"

    shuf -n "${number_of_words}" < "${SCRIPT_PATH}words.txt" | tr '\n' '-' | sed 's/-$//'
}

register_chat() {
    secret_passphrase="$(generate_passphrase 7)"

    cat <<EOF
Open https://t.me/HomeLabRobot
Tap Start button
Send this secret message: ${secret_passphrase}
Confirm only after you send the above secret message.
EOF
    prompt_confirmation

    chats_url="https://api.telegram.org/bot${API_TOKEN}/getUpdates"
    jq_filter=".result[] | select(.message.text == \"${secret_passphrase}\") | .message.chat.id"

    # Get chat IDs
    new_chat_id="$(curl -s -X GET "${chats_url}" | jq "${jq_filter}" | sort | uniq)"

    # Check if no chat id found
    if [ -z "${new_chat_id}" ]; then
        printf "ERROR: No chat id found. Please check that you have typed your passphrase correctly.\n"
        exit 1
    fi

    chat_id_list="${CHAT_IDS} ${new_chat_id}"
    CHAT_IDS="$(printf "%s" "${chat_id_list}" | tr ' ' '\n' | sort | uniq | tr '\n' ' ')"

    # Trim leading whitespace
    CHAT_IDS=$(printf "%s" "${CHAT_IDS}" | sed 's/^[[:space:]]*//')

    # Trim trailing whitespace
    CHAT_IDS=$(printf "%s" "${CHAT_IDS}" | sed 's/[[:space:]]*$//')

    sed -i "s/^CHAT_IDS=.*/CHAT_IDS=\"${CHAT_IDS}\"/" "${ENV_FILE_PATH}"
    
    exit 0
}

print_chats() {
    ids="$(printf '%s' "${CHAT_IDS}" | tr ' ' '\n')"
    total="$(printf '%s\n' "${ids}" | wc -l)"
    printf "Total %s chat ids are registered:\n%s\n" "${total}" "${ids}"
    exit 0
}

delete_chats() {
    sed -i "s/^CHAT_IDS=.*/CHAT_IDS=\"\"/" "${ENV_FILE_PATH}"
    exit 0
}

msg_id() {
    url="https://api.telegram.org/bot${API_TOKEN}/sendMessage"
    chat_id="${1}"
    message="${2}"
    retry_counter="${3:-0}"

    while [ "${retry_counter}" -lt "${MAXIMUM_RETRY_LIMIT}" ]; do
        # Execute the curl command
        if curl -sf -X POST "${url}" -d "chat_id=${chat_id}" -d "text=${message}" -d "protect_content=1"> /dev/null; then
            printf "Message was successfully sent to chat id %s.\n" "${chat_id}"
            break
        fi
            
        # Wait for one second
        sleep 1
        # Increment the retry counter
        retry_counter=$((retry_counter + 1))
    done

    if [ "${retry_counter}" -ge "${MAXIMUM_RETRY_LIMIT}" ]; then
        printf "ERROR: Maximum retry limit has been reached for chat id %s.\n" "${chat_id}"
    fi
}

msg_all() {
    message="${2}"

    # Split the CHAT_IDS variable into positional parameters based on spaces
    set -- ${CHAT_IDS}

    # Loop through each chat ID and perform the curl request
    while [ "${#}" -gt 0 ]; do
        msg_id "${1}" "${message}" &
        shift  # Move to the next positional parameter
    done

    wait
}

# Parse arguments
parse_args() {
    if [ "${#}" -gt 0 ]; then
        case "${1}" in
            --register-chat)
                register_chat
                ;;
            --print-chats)
                print_chats
                ;;
            --delete-chats)
                delete_chats
                ;;
            --msg-all)
                msg_all "${@}"
                ;;
            --msg-id)
                msg_id "${2}" "${3}"
                ;;
            --help)
                usage
                exit 0
                ;;
            *)
                printf 'ERROR: Unknown option "%s".\n\n' "${1}"
                usage
                exit 1
                ;;
        esac
    fi
}

# Check if the number of positional arguments is not greater than 0
if [ "${#}" -gt 0 ]; then
    parse_args "${@}"
else
    printf "ERROR: No option specified.\n\n"
    usage
    exit 1
fi
