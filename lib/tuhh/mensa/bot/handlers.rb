require "tuhh/mensa/scraper"

module TUHH::Mensa::Bot::Handlers; end

class TUHH::Mensa::Bot::Handlers::Default
  def initialize(config)
    @config = config
    @scraper = TUHH::Mensa::Scraper.new(config)
  end

  def on_start(tg, message)
    message.reply { |reply|
      reply.text = <<~"EOF"
        Hello.

        Type /now to display the current menu.
        Type /next to display the upcoming menu.

        If shit hits the fan, please inform #{@config.fetch(:owner)}.
        EOF

      reply.send_with(tg)
    }
  end

  def on_now(tg, message)
    message.reply { |reply|
      reply.text = @scraper.show(:now)
      reply.send_with(tg)
    }
  end

  def on_next(tg, message)
    message.reply { |reply|
      reply.text = @scraper.show(:next)
      reply.send_with(tg)
    }
  end

  def default(tg, message)
    message.reply { |reply|
      reply.text = "I am unable to understand you :/"
      reply.send_with(tg)
    }
  end
end
