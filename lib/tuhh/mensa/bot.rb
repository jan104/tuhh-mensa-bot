require "psych"

require "telegram_bot"

module TUHH::Mensa::Bot; end

require "tuhh/mensa/bot/handlers"

class TUHH::Mensa::Bot::Interface
  def initialize(config_pt)
    @config = Psych.load(IO.read(config_pt), symbolize_names: 1)
    @tg_bot = TelegramBot.new(token: @config.fetch(:token))
    @handler = TUHH::Mensa::Bot::Handlers::Default.new(@config)
  end

  def run
    @tg_bot.get_updates(fail_silently: 1) { |m| on_message(m) }
  end

  def on_message(message)
    puts "@#{message.from.username}: #{message.text}"
    command = message.get_command_for(@tg_bot)

    if command =~ %r@^/([\w_]+)@i
      desired_method = "on_#{$1}".to_sym
    else
      desired_method = ''.to_sym
    end
    puts "desired_method -> `#{desired_method}`"

    if @handler.respond_to?(desired_method)
      @handler.public_send(desired_method, @tg_bot, message)
    else
      @handler.public_send(:default, @tg_bot, message)
    end
  end
end
