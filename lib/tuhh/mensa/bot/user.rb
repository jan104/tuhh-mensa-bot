require "psych"

class TUHH::Mensa::Bot::User
  def initialize(tg_id, config)
    @id = tg_id
    @config = config
    @prefs = load_prefs
  end

  def lang=(choice)
    @prefs[:lang] = choice
    save_prefs!(@prefs)
  end

  def lang
    @prefs[:lang]
  end

  private
  def default_prefs
    {
      lang: :en
    }
  end

  def cache_path
    # .cache/1234567.yaml
    @config[:cache].join("#{@id}.yaml")
  end

  def load_prefs
    if cache_path.file?
      Psych.load(IO.read(cache_path), symbolize_names: 1)
    else
      prefs = default_prefs
      save_prefs!(prefs)
    end
  end

  def save_prefs!(prefs)
    puts "saving user #{@id}"
    IO.write(cache_path, Psych.dump(prefs))
    prefs
  end
end
