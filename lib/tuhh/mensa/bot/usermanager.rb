require "tuhh/mensa/bot/user"

class TUHH::Mensa::Bot::UserManager
  def initialize(config)
    @config = config
    @users = Hash.new
  end

  def get(tg_id)
    unless @users[tg_id]
      @users[tg_id] = TUHH::Mensa::Bot::User.new(tg_id)
    end

    return @users[tg_id]
  end
end
