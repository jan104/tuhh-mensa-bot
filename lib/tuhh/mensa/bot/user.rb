class TUHH::Mensa::Bot::User
  def initialize(tg_id)
    @id = tg_id
    @prefs = load_prefs

    puts "initialized user"
    p self
  end

  def load_prefs
    return default_prefs
  end

  def lang=(choice)
    @prefs[:lang] = choice
    save!
  end

  def lang
    @prefs[:lang]
  end

  def save!
    puts "[stub] saving user"
    p self
  end

  private
  def default_prefs
    {
      lang: :en
    }
  end
end
