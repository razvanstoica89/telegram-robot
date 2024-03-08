# Telegram Robot

The Telegram Robot is a Telegram SH Script designed to efficiently send notifications to a curated list of registered chats.

It's purpose is to streamline communication within a home lab environment, ensuring that important updates, alerts, or announcements reach the designated recipients promptly.

With a simple setup process, users can register their chat IDs with the bot, enabling seamless delivery of notifications directly to their Telegram accounts.

Whether it's system status updates, security alerts, or personalized reminders, the Telegram Robot acts as a reliable and convenient notification hub, enhancing the communication infrastructure within home lab environments.

## Installation instructions for Telegram Robot

1. Clone the repository to your local machine:

    ```bash
    git clone <repository_url>
    ```

1. Navigate to the cloned repository:

    ```bash
    cd <repository_name>
    ```

1. Copy the .env-example file and rename it to .env:

    ```bash
    cp .env-example .env
    ```

1. Open Telegram app.

1. Open [BotFather](https://t.me/BotFather) in your Telegram App.

1. Type ```/mybots``` in the chat to list your bots.

1. Select your desired bot from the list.

1. Tap on the ```API Token``` option.

1. Copy the provided API Token.

1. Set the API token in the ```.env``` file using the ```TOKEN``` variable like this:

    ```bash
    TOKEN=<paste_your_api_token_here>
    ```

1. Save the ```.env``` file.

1. Set proper permission for ```.env``` file

    ```bash
    chmod 600 .env
    ```

1. You are now ready to use the Telegram Robot for sending notifications using your custom bot to the registered chats.

## Usage

Telegram Telegram Robot 0.0.1

The Telegram Robot is a Telegram Bot designed to efficiently send notifications to a curated list of registered chats.

Usage: ./telegram.sh [OPTIONS] [Arguments]

Example:

```bash
./telegram.sh --msg-all "Hello audience"
```

Options:

```--register-chat```                 Register a new chat ID

```--print-chats```                   Print registered chats IDs

```--delete-chats```                  Delete all registered chats IDs

```--msg-all <message>```             Send a message to all registered chats

```--msg-id <chat_id> <message>```    Send a message to the specified chat id

```--help```                          Show this help message

## Installation for how you can register a new chat

1. Run Telegram Robot shell script.

  ```bash
  ./telegram.sh --register-chat
  ```

1. Open Telegram app.

1. Open your bot.

1. Tap Start button.

1. Send to the bot the secret message that script is printing.

1. Confirm that you will continue to execute the script only after sending the above message to your bot.

## Dependencies

The Telegram Robot script relies on several essential dependencies to function effectively.

1. ```printf```: Used for formatted printing, essential for displaying information in a structured manner within the script.

1. ```cat```: Necessary for concatenating and displaying the contents of files, a fundamental operation for handling input and output.

1. ```shuf```: Enables shuffling or randomization of data, contributing to the dynamic behavior of the script.

1. ```tr```: Used for character replacement, crucial for manipulating text and ensuring compatibility.

1. ```wc```: Provides line count functionality, aiding in analyzing and processing textual information within the script.

1. ```sed```: A stream editor, employed for text manipulation and substitution, contributing to the script's data processing capabilities.

1. ```jq```: A lightweight and flexible JSON processor, essential for handling JSON data structures within the script.

1. ```curl```: An indispensable tool for making HTTP requests, allowing the script to interact with Telegram API.

1. ```sha256sum```: Used for generating SHA-256 checksums, ensuring data integrity and security by verifying the integrity of downloaded files.

You should verify the availability and proper installation of these dependencies to guarantee the script's optimal performance in managing Telegram interactions and related functionalities.

## To do

- [ ] For each option it should be checked whether the expected number of arguments has been provided.
- [ ] Escape problematic characters in the message text.
- [ ] Reduce the number of dependencies needed.
- [ ] Check the script with [ShellCheck
](https://www.shellcheck.net) and resolve the remaining issues.

- [ ] Add the possibility for autocomplete options.

```bash
complete -W "--register-chat --print-chats --delete-chats --msg-all --msg-id --help" "<relative_path_to_script>"
```

- [ ] Add possibility to subscribe to one or more topics.
- [ ] Migrate to Go programming language.

## License

This project is licensed under GNU General Public License v3.0.
