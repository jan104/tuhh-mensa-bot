# tuhh-mensa-bot

Find something inexpensive and (hopefully) healthy to eat at TU Hamburg,
via Telegram. This code powers [@MensaTUHH_Bot][tg-link].

[tg-link]: https://t.me/MensaTUHH_Bot

## Development setup

1. Create a new Telegram bot.
2. Copy `config.sample.yaml` to `config.yaml` and fill in the blanks.
3. Run `bin/start`.

## Production setup (Ubuntu, systemd)

Create a user for the bot to run on.
```
sudo useradd -d /home/service/tuhh-mensa-bot -m -s /bin/bash tuhh-mensa-bot
sudo su -l tuhh-mensa-bot
```

Clone the repository, and install Ruby 2.6.0 via rbenv.
```
git clone 'https://github.com/martinborchert/tuhh-mensa-bot.git' app
curl -fsSLo rbenv-installer 'https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-installer'
# (... inspect whether rbenv-installer is trustworthy, then ...)
bash rbenv-installer
echo "export PATH=$HOME/.rbenv/bin:$PATH" >> .bashrc
echo 'eval "$(rbenv init -)"' >> .bashrc
source .bashrc
rbenv install 2.6.0
rbenv global 2.6.0
rbenv shell 2.6.0
```

Configure the bot, and install its dependencies.
```
cd app
cp config.sample.yaml config.yaml
vim config.yaml # Editing ...
bundle install
exit
```

Install the systemd unit.
```
sudo cp /home/service/tuhh-mensa-bot/app/dist/tuhh-mensa-bot.service /etc/systemd/system/
sudo systemctl daemon-reload

sudo systemctl start tuhh-mensa-bot
sudo systemctl status tuhh-mensa-bot # Verify that everything is working ...
sudo systemctl enable tuhh-mensa-bot # Everything is fine!
```

## Todo

- Implement caching
- Implement multi-language support

## License

This software is Copyright (c) 2019 by Martin Borchert.  
This is free software, licensed under The MIT (X11) License.
