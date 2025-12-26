# Deploying the AVL Telegram Bot on a Raspberry Pi

This guide explains how to deploy the bot as a resilient `systemd` service on a Raspberry Pi (or any other Linux system). This ensures the bot starts automatically on boot and restarts if it crashes.

## 1. Prerequisites

- A Raspberry Pi with Raspberry Pi OS (or another Debian-based Linux).
- The Dart SDK is installed. You can follow the official guide to install Dart.
- Your project code is cloned to a directory (e.g., `/home/spriggan/src_git/AVL_Telegram_Bot`).
- All dependencies are installed (`dart pub get`).

## 2. Compile the Application

For a production environment, it's best to compile the application into a self-contained native executable. This improves performance and simplifies running the process.

Navigate to your project directory and run the following command:

```bash
cd /home/spriggan/src_git/AVL_Telegram_Bot
dart compile exe bin/main.dart -o build/avl_bot
```

This command creates an executable file at `/home/spriggan/src_git/AVL_Telegram_Bot/build/avl_bot`.

## 3. Create the `systemd` Service

A `systemd` service will manage the bot's process, handling automatic starts and restarts.

### Step 3.1: Create the Service File

Create a new service definition file using a text editor like `nano`:

```bash
sudo nano /etc/systemd/system/avl-telegram-bot.service
```

### Step 3.2: Add the Service Configuration

Paste the following content into the file.

**Important:** Make sure the `User`, `WorkingDirectory`, and `ExecStart` paths match your specific setup.

```ini
[Unit]
Description=AVL Telegram Bot
After=network.target

[Service]
Type=simple

# Replace 'spriggan' with your actual username if it's different
User=spriggan

# The absolute path to your project's root directory
WorkingDirectory=/home/spriggan/src_git/AVL_Telegram_Bot

# The command to run the compiled executable
ExecStart=/home/spriggan/src_git/AVL_Telegram_Bot/build/avl_bot

# Restart the service if it fails
Restart=on-failure
RestartSec=10s

[Install]
WantedBy=multi-user.target
```

Save the file and exit the editor (in `nano`, press `Ctrl+X`, then `Y`, then `Enter`).

## 4. Manage the Service

Now you can control your bot using `systemctl` commands.

- **Reload `systemd`** to make it aware of your new service:
  ```bash
  sudo systemctl daemon-reload
  ```
- **Enable the service** to start automatically on boot:
  ```bash
  sudo systemctl enable avl-telegram-bot.service
  ```
- **Start the service** immediately:
  ```bash
  sudo systemctl start avl-telegram-bot.service
  ```
- **Check the status** of your service:
  ```bash
  systemctl status avl-telegram-bot.service
  ```
- **View the logs** in real-time:
  ```bash
  journalctl -u avl-telegram-bot -f
  ```
- **Stop the service**:
  ```bash
  sudo systemctl stop avl-telegram-bot.service
  ```