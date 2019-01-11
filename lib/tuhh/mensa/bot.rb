require "pathname"
require "psych"

require "telegram_bot"

module TUHH::Mensa::Bot; end

require "tuhh/mensa/bot/handlers"
require "tuhh/mensa/bot/usermanager"

class TUHH::Mensa::Bot::Interface
  def initialize(config_pt)
    @config = Psych.load(IO.read(config_pt), symbolize_names: 1)
    @config = process_config(@config)
    @tg_bot = TelegramBot.new(token: @config.fetch(:token))
    @handler = TUHH::Mensa::Bot::Handlers::Default.new(@config)
    @users = TUHH::Mensa::Bot::UserManager.new(@config)
  end

  def run
    @tg_bot.get_updates(fail_silently: 1) { |m| on_message(m) }
  end

  def on_message(message)
    puts "@#{message.from.username}: #{message.text}"
    user = @users.get(message.from.id)
    command = message.get_command_for(@tg_bot)

    if command =~ %r@^/([\w_]+)@i
      desired_method = "on_#{$1}".to_sym
    else
      desired_method = ''.to_sym
    end
    puts "desired_method -> `#{desired_method}`"

    if @handler.respond_to?(desired_method)
      response = @handler.public_send(desired_method, user, message)
    else
      response = @handler.public_send(:default, user, message)
    end

    message.reply { |reply|
      reply.text = response[user.lang]
      reply.send_with(@tg_bot)
    }
  end

  private
  def process_config(config)
    config[:cache] = Pathname.new(config[:cache])
    config[:cache].mkpath
    config
  end
end
